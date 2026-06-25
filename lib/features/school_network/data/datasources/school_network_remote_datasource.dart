
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/network/api_json_parser.dart';

class SchoolNetworkRemoteDataSource {
  SchoolNetworkRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getSchools() async {
    try {
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
      return ApiJsonParser.extractList(response);
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
      return ApiJsonParser.extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch students: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await _apiClient.get('/classes', requiresAuth: true);
      return ApiJsonParser.extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch classes: $e');
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

  Future<List<Map<String, dynamic>>> getStudentCourses(String studentId) async {
    try {
      final response = await _apiClient.get('/students/$studentId/courses', requiresAuth: true);
      return ApiJsonParser.extractList(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch courses for student $studentId: $e');
    }
  }

}
