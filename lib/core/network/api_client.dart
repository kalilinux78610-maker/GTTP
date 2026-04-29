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
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        // Accept: application/json makes Laravel return JSON errors and resources
        // instead of redirecting to HTML login pages on 401/validation failures.
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await secureStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
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
