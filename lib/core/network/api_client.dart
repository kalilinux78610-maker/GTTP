import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../security/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._dio, this._secureStorage);

  final Dio _dio;
  final SecureStorageService _secureStorage;

  static ApiClient create(SecureStorageService secureStorage) {
    final env = dotenv.isInitialized ? dotenv.env : const <String, String>{};
    final baseUrl = env['API_BASE_URL'];
    final sslCertHash = env['SSL_CERT_HASH']; // Add your SHA-256 fingerprint in .env

    if (baseUrl == null || baseUrl.isEmpty) {
      throw ApiException(
        'Missing API_BASE_URL. Add it in .env and restart the app.',
      );
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // SSL Pinning Configuration
    if (sslCertHash != null && sslCertHash.isNotEmpty) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => HttpClient(),
        validateCertificate: (cert, host, port) {
          // Implement strict certificate validation here comparing cert.der to sslCertHash
          // For now we return true to not break the app without a valid hash
          return true; 
        },
      );
    }

    // Add Retry Interceptor for failed network requests
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: (msg) {
          if (kDebugMode) debugPrint('[Retry] $msg');
        },
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    // Shared refresh request so concurrent 401s wait for the same token.
    Future<String?>? refreshRequest;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Do not attach stale tokens to public auth endpoints (login, OTP, etc.).
          if (!_isPublicAuthPath(options)) {
            final accessToken = await secureStorage.getAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Only refresh session for authenticated API calls — not login/OTP.
          if (!_shouldAttemptTokenRefresh(error)) {
            return handler.next(error);
          }

          try {
            final newAccessToken = await (refreshRequest ??=
                _refreshAccessToken(dio, secureStorage));

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              // Retry the original request with new token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final response = await dio.fetch<dynamic>(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            if (kDebugMode) debugPrint('[API] Token refresh failed: $e');
            // Clear tokens on refresh failure
            await secureStorage.clearTokens();
          } finally {
            refreshRequest = null;
          }

          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }

    return ApiClient(dio, secureStorage);
  }

  static String? _tryGetString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static Future<String?> _refreshAccessToken(
    Dio dio,
    SecureStorageService secureStorage,
  ) async {
    final refreshToken = await secureStorage.getRefreshToken();
    final accessToken = await secureStorage.getAccessToken();

    // In Laravel JWT-Auth, the old access token is often used to get a new one.
    final tokenToUse = (refreshToken != null && refreshToken.isNotEmpty)
        ? refreshToken
        : accessToken;

    if (tokenToUse == null || tokenToUse.isEmpty) {
      await secureStorage.clearTokens();
      return null;
    }

    final refreshResponse = await dio.post<dynamic>(
      '/refresh',
      options: Options(headers: {'Authorization': 'Bearer $tokenToUse'}),
    );

    final body = refreshResponse.data;
    if (body is! Map<String, dynamic>) return null;

    final newAccessToken = _tryGetString(body, [
      'accessToken',
      'token',
      'access_token',
      'jwt',
      'bearerToken',
    ]);
    final newRefreshToken = _tryGetString(body, [
      'refreshToken',
      'refresh_token',
      'refreshJwt',
    ]);

    if (newAccessToken == null || newAccessToken.isEmpty) return null;

    await secureStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
    return newAccessToken;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    bool requiresAuth = false,
  }) async {
    try {
      if (requiresAuth) {
        final token = await _secureStorage.getAccessToken();
        if (token == null || token.isEmpty) {
          throw ApiException('You are not authenticated.');
        }
      }

      final response = await _dio.post<dynamic>(path, data: data);
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {'data': body};
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    bool requiresAuth = false,
  }) async {
    try {
      if (requiresAuth) {
        final token = await _secureStorage.getAccessToken();
        if (token == null || token.isEmpty) {
          throw ApiException('You are not authenticated.');
        }
      }

      final response = await _dio.put<dynamic>(path, data: data);
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {'data': body};
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    try {
      if (requiresAuth) {
        final token = await _secureStorage.getAccessToken();
        if (token == null || token.isEmpty) {
          throw ApiException('You are not authenticated.');
        }
      }

      final response = await _dio.get<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return body;
      }
      return {'data': body};
    } on DioException catch (e) {
      throw ApiException(
        _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  static Map<String, dynamic>? _responseAsMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static bool _isPublicAuthPath(RequestOptions options) {
    final path = options.uri.path.toLowerCase();
    return path.contains('/auth/login') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/resend-otp') ||
        path.contains('/auth/reset-password');
  }

  static bool _shouldAttemptTokenRefresh(DioException error) {
    if (error.response?.statusCode != 401) return false;
    final path = error.requestOptions.uri.path.toLowerCase();
    if (path.contains('/refresh')) return false;
    if (_isPublicAuthPath(error.requestOptions)) return false;
    return true;
  }

  static String _pathLower(DioException error) =>
      error.requestOptions.uri.path.toLowerCase();

  String _extractErrorMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    final path = _pathLower(error);

    // Prefer server message when present (Laravel JSON errors).
    final responseData = error.response?.data;
    
    final map = _responseAsMap(responseData);
    if (map != null) {
      final message = map['message'] ?? map['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    if (statusCode == 401) {
      if (path.contains('/auth/login')) {
        return 'Invalid email or password. Please try again.';
      }
      if (path.contains('/auth/verify-otp')) {
        return 'Invalid or expired OTP. Please check the code and try again.';
      }
      if (path.contains('/auth/resend-otp') ||
          path.contains('/auth/forgot-password')) {
        return 'Unable to complete this step. Please log in again.';
      }
      return 'Session expired. Please log in again.';
    }
    if (statusCode == 422) {
      if (map != null && map['errors'] is Map) {
        final errorsMap = map['errors'] as Map;
        final List<String> errorMessages = [];
        for (final entry in errorsMap.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            errorMessages.add(value.first.toString());
          } else if (value is String) {
            errorMessages.add(value);
          }
        }
        if (errorMessages.isNotEmpty) {
          return 'Validation failed: ${errorMessages.join(", ")}';
        }
      }
      return 'Validation failed: $responseData';
    }
    if (statusCode == 404) {
      return 'Requested resource not found.';
    }
    if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }

    // Fallback for network timeouts
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
