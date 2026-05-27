import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/network/api_json_parser.dart';

class NoticesRemoteDataSource {
  NoticesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getNotices() async {
    try {
      final response = await _apiClient.get('/notices', requiresAuth: true);
      ApiJsonParser.throwIfErrorResponse(response);
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
      ApiJsonParser.throwIfErrorResponse(response);
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

  Future<Map<String, dynamic>> createNotice({
    required String title,
    required String content,
    required String category,
    required String priority,
    required bool isPinned,
    required String targetAudience,
  }) async {
    try {
      final response = await _apiClient.post(
        '/notices',
        requiresAuth: true,
        data: {
          'title': title,
          'content': content,
          'category': category,
          'priority': priority,
          'is_pinned': isPinned,
          'target_audience': targetAudience,
        },
      );
      ApiJsonParser.throwIfErrorResponse(response);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to create notice: $e');
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    final list = ApiJsonParser.extractList(response);
    if (list.isEmpty && kDebugMode) {
      debugPrint('[Notices] No list found in response.');
    }
    return list;
  }
}
