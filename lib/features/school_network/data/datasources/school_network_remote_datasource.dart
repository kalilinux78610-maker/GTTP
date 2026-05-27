import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';

class SchoolNetworkRemoteDataSource {
  SchoolNetworkRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getSchools() async {
    try {
      final response = await _apiClient.get('/schools', requiresAuth: true);
      return _extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch schools: $e');
    }
  }

  Future<Map<String, dynamic>> getSchoolDetail(String id) async {
    try {
      final response = await _apiClient.get('/schools/$id', requiresAuth: true);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch school detail: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final response = await _apiClient.get('/students', requiresAuth: true);
      return _extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch students: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await _apiClient.get('/classes', requiresAuth: true);
      return _extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch classes: $e');
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    // Handle various response shapes
    if (response['data'] is List) {
      return (response['data'] as List).cast<Map<String, dynamic>>();
    }
    if (response['schools'] is List) {
      return (response['schools'] as List).cast<Map<String, dynamic>>();
    }
    if (response['items'] is List) {
      return (response['items'] as List).cast<Map<String, dynamic>>();
    }
    if (response['results'] is List) {
      return (response['results'] as List).cast<Map<String, dynamic>>();
    }
    // Fallback: find first list value
    for (final value in response.values) {
      if (value is List) {
        return value.cast<Map<String, dynamic>>();
      }
    }
    if (kDebugMode) debugPrint('[SchoolNetwork] No list found in response.');
    return [];
  }
}
