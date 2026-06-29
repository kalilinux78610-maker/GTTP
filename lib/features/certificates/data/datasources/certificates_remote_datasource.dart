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

  Future<Map<String, dynamic>> getCertificateBuilder() async {
    try {
      final response = await _apiClient.get(
        '/v1/certificatebuilder',
        requiresAuth: true,
      );
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch certificate builder: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCourseCertificate(String courseId) async {
    try {
      final response = await _apiClient.get(
        '/courses/$courseId/certificate',
        requiresAuth: true,
      );
      
      // Handle the specific shape: response['data']['certificates'][i]['certificate']
      if (response['data'] is Map && (response['data'] as Map).containsKey('certificates')) {
        final list = response['data']['certificates'] as List;
        return list.whereType<Map>().map((item) {
          final map = Map<String, dynamic>.from(item);
          if (map['certificate'] is Map) {
            return Map<String, dynamic>.from(map['certificate']);
          }
          return null;
        }).whereType<Map<String, dynamic>>().toList();
      }
      
      return _extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch certificate for course $courseId: $e');
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    List<Map<String, dynamic>> extractAndUnwrap(List rawList) {
      return rawList.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['certificate'] is Map) {
          return Map<String, dynamic>.from(map['certificate']);
        }
        return map;
      }).toList();
    }

    // Handle various response shapes
    if (response['data'] is List) {
      return extractAndUnwrap(response['data'] as List);
    }
    if (response['certificates'] is List) {
      return extractAndUnwrap(response['certificates'] as List);
    }
    if (response['items'] is List) {
      return extractAndUnwrap(response['items'] as List);
    }
    // Fallback: find first list value
    for (final value in response.values) {
      if (value is List) {
        return extractAndUnwrap(value);
      }
    }
    if (kDebugMode) debugPrint('[Certificates] No list found in response.');
    return [];
  }
}
