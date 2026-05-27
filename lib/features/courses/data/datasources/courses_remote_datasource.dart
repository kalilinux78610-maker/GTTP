import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import '../models/course_model.dart';

final coursesRemoteDataSourceProvider = Provider<CoursesRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CoursesRemoteDataSource(apiClient);
});

class CoursesRemoteDataSource {
  final ApiClient _apiClient;

  CoursesRemoteDataSource(this._apiClient);

  Future<List<CourseModel>> getCourses() async {
    final response = await _apiClient.get('/courses', requiresAuth: true);
    final list = ApiJsonParser.extractList(response);
    return list.map(CourseModel.fromJson).toList();
  }

  Future<CourseModel?> getCourseDetails(String id) async {
    final response = await _apiClient.get('/courses/$id', requiresAuth: true);
    final object = ApiJsonParser.extractObject(response);
    if (object == null) return null;
    return CourseModel.fromJson(object);
  }
}
