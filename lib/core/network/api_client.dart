import 'package:dio/dio.dart';
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
        // Accept: application/json makes Laravel return JSON errors and resources
        // instead of redirecting to HTML login pages on 401/validation failures.
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Local variable for refresh state (closure captures this)
    bool isRefreshing = false;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await secureStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Only handle 401 Unauthorized errors
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          // Prevent refresh loop
          if (isRefreshing) {
            return handler.next(error);
          }

          isRefreshing = true;
          try {
            final refreshToken = await secureStorage.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              // No refresh token, need to re-login
              await secureStorage.clearTokens();
              return handler.next(error);
            }

            // Attempt to refresh the token
            final refreshResponse = await dio.post<dynamic>(
              '/refresh',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $refreshToken',
                },
              ),
            );

            final body = refreshResponse.data;
            String? newAccessToken;
            String? newRefreshToken;

            if (body is Map<String, dynamic>) {
              // Try various token key names
              newAccessToken = _tryGetString(body, [
                'accessToken', 'token', 'access_token', 'jwt', 'bearerToken',
              ]);
              newRefreshToken = _tryGetString(body, [
                'refreshToken', 'refresh_token', 'refreshJwt',
              ]);
            }

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              // Save new tokens
              await secureStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry the original request with new token
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final response = await dio.fetch<dynamic>(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            if (kDebugMode) debugPrint('[API] Token refresh failed: $e');
            // Clear tokens on refresh failure
            await secureStorage.clearTokens();
          } finally {
            isRefreshing = false;
          }

          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
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
      throw ApiException(_extractErrorMessage(e), statusCode: e.response?.statusCode);
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
      throw ApiException(_extractErrorMessage(e), statusCode: e.response?.statusCode);
    }
  }

  String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ?? responseData['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

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
