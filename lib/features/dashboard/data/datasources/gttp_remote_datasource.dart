import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

final gttpRemoteDataSourceProvider = Provider<GttpRemoteDataSource>((ref) {
  return GttpRemoteDataSource(ref.read(apiClientProvider));
});

class GttpRemoteDataSource {
  GttpRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getCertificates() async {
    final response = await _apiClient.get('/certificates', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final response = await _apiClient.get('/schedules', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final response = await _apiClient.get('/subjects', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getSyllabus() async {
    final response = await _apiClient.get('/syllabus', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getTimetable() async {
    final response = await _apiClient.get('/timetable', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getNotices() async {
    final response = await _apiClient.get('/notices', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getSchools() async {
    final response = await _apiClient.get('/schools', requiresAuth: true);
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getStudents({
    String? year,
    String? school,
    String? course,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (year != null && year.trim().isNotEmpty) {
      queryParameters['year'] = year.trim();
    }
    if (school != null && school.trim().isNotEmpty) {
      queryParameters['school'] = school.trim();
    }
    if (course != null && course.trim().isNotEmpty) {
      queryParameters['course'] = course.trim();
    }

    final response = await _apiClient.get(
      '/students',
      requiresAuth: true,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    
    final students = _extractList(response);
    
    if (kDebugMode && students.isNotEmpty) {
      debugPrint('[GttpRemoteDataSource] First student raw data: ${students.first}');
    }
    
    return students;
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await _apiClient.get('/classes', requiresAuth: true);
    return _extractList(response);
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    final candidates = <dynamic>[
      response['data'],
      response['items'],
      response['results'],
      response['records'],
      ...response.values,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }
}
