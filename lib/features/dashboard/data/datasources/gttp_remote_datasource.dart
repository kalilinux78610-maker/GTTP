import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
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

  Future<List<Map<String, dynamic>>> getFaculty() async {
    try {
      final response = await _apiClient.get(
        '/faculties',
        requiresAuth: true,
        queryParameters: {
          'limit': 1000,
          'per_page': 1000,
          'paginate': 0,
          'pagination': false,
          'all': true,
        },
      );
      final faculties = _extractList(response);
      
      // Filter out only obvious dummy accounts
      return faculties.where((faculty) {
        final userObj = faculty['user'] is Map ? Map<String, dynamic>.from(faculty['user']) : faculty;
        final name = (userObj['name'] ?? userObj['faculty_name'] ?? userObj['full_name'] ?? '').toString().toLowerCase();
        final email = (userObj['email'] ?? '').toString().toLowerCase();
        
        return !(name == 'dummy' || name == 'mock' || name == 'test' || 
                 email == 'dummy@dummy.com' || email == 'test@test.com');
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GttpRemoteDataSource] Error fetching faculties: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> getFacultyDetail(String id) async {
    try {
      final response = await _apiClient.get('/faculties/$id', requiresAuth: true);
      return response;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch faculty detail: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSchools() async {
    final response = await _apiClient.get(
      '/schools', 
      requiresAuth: true,
      queryParameters: {
        'limit': 1000, 
        'per_page': 1000,
        'paginate': 0,
        'pagination': false,
        'all': true,
      },
    );
    final schools = _extractList(response);

    // Filter out dummy or test schools to match actual data
    return schools.where((school) {
      final name = (school['name'] ?? school['institute_name'] ?? '').toString().toLowerCase();
      final email = (school['email'] ?? '').toString().toLowerCase();
      
      return !(name.contains('dummy') || name.contains('mock') || name == 'test' || name == 'test school' ||
               email == 'dummy@dummy.com' || email == 'test@test.com');
    }).toList();
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

    if (kDebugMode) {
      debugPrint('[GttpRemoteDataSource] getStudents query: $queryParameters');
    }

    final response = await _apiClient.get(
      '/students',
      requiresAuth: true,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final students = _extractList(response);

    // Filter out only obvious dummy accounts
    final validStudents = students.where((student) {
      final name = (student['name'] ?? student['full_name'] ?? student['first_name'] ?? '').toString().toLowerCase();
      final email = (student['email'] ?? '').toString().toLowerCase();
      
      return !(name == 'dummy' || name == 'mock' || name == 'test' || name == 'test student' ||
               email == 'dummy@dummy.com' || email == 'test@test.com');
    }).toList();

    if (kDebugMode && validStudents.isNotEmpty) {
      debugPrint(
        '[GttpRemoteDataSource] First student keys: ${validStudents.first.keys.toList()}',
      );
    }

    return validStudents;
  }

  Future<List<Map<String, dynamic>>> getStudentCourses(String studentId) async {
    final response = await _apiClient.get(
      '/students/$studentId/courses',
      requiresAuth: true,
    );
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await _apiClient.get('/classes', requiresAuth: true);
    final classes = _extractList(response);
    if (kDebugMode && classes.isNotEmpty) {
      debugPrint('[GttpRemoteDataSource] Total classes: ${classes.length}');
    }
    return classes;
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await _apiClient.get('/courses', requiresAuth: true);
    final courses = _extractList(response);
    if (kDebugMode && courses.isNotEmpty) {
      debugPrint('[GttpRemoteDataSource] Total courses: ${courses.length}');
    }
    return courses;
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    if (kDebugMode) {
      debugPrint('[GttpRemoteDataSource] Raw response keys: ${response.keys.toList()}');
      for (final key in response.keys) {
        final val = response[key];
        debugPrint('[GttpRemoteDataSource]   "$key" => ${val.runtimeType}: '
            '${val is List ? "(${val.length} items)" : val is Map ? "(${Map<String, dynamic>.from(val).keys.toList()})" : val}');
      }
    }

    // Priority order: common wrapper keys, then all values
    final priorityKeys = [
      'data', 'items', 'results', 'records', 'students',
      'schools', 'courses', 'classes', 'list', 'rows',
    ];

    // Check priority keys first
    for (final key in priorityKeys) {
      final val = response[key];
      if (val is List) {
        if (kDebugMode) debugPrint('[GttpRemoteDataSource] Found list under key "$key" (${val.length} items)');
        return val.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
      // Handle paginated: { data: { data: [...], total: N } }
      if (val is Map) {
        final inner = val['data'];
        if (inner is List) {
          if (kDebugMode) debugPrint('[GttpRemoteDataSource] Found paginated list under "$key.data" (${inner.length} items)');
          return inner.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
    }

    // Fallback: scan all values
    for (final val in response.values) {
      if (val is List && val.isNotEmpty) {
        if (kDebugMode) debugPrint('[GttpRemoteDataSource] Fallback: found list in values (${val.length} items)');
        return val.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }

    if (kDebugMode) debugPrint('[GttpRemoteDataSource] WARNING: No list found in response!');
    return const [];
  }
}
