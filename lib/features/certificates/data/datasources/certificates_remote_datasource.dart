import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';

class CertificatesRemoteDataSource {
  CertificatesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      final response = await _apiClient.get(
        '/certificates',
        requiresAuth: true,
      );
      return _extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch certificates: $e');
    }
  }

  Future<Map<String, dynamic>> getCertificateDetail(String id) async {
    try {
      final response = await _apiClient.get(
        '/certificates/$id',
        requiresAuth: true,
      );
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch certificate detail: $e');
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    // Handle various response shapes
    if (response['data'] is List) {
      return (response['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (response['certificates'] is List) {
      return (response['certificates'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (response['items'] is List) {
      return (response['items'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    // Fallback: find first list value
    for (final value in response.values) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    if (kDebugMode) debugPrint('[Certificates] No list found in response.');
    return [];
  }
}
