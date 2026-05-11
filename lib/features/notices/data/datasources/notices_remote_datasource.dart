import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';

class NoticesRemoteDataSource {
  NoticesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getNotices() async {
    try {
      final response = await _apiClient.get('/notices', requiresAuth: true);
      return _extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch notices: $e');
    }
  }

  Future<Map<String, dynamic>> getNoticeDetail(String id) async {
    try {
      final response = await _apiClient.get('/notices/$id', requiresAuth: true);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch notice detail: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.post('/notices/$id/read', requiresAuth: true);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to mark notice as read: $e');
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    // Handle various response shapes
    if (response['data'] is List) {
      return (response['data'] as List).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (response['notices'] is List) {
      return (response['notices'] as List).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (response['items'] is List) {
      return (response['items'] as List).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    // Fallback: find first list value
    for (final value in response.values) {
      if (value is List) {
        return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
    if (kDebugMode) {
      debugPrint('[Notices] No list found in response: $response');
    }
    return [];
  }
}
