import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_client.dart';
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
    
    final data = response['data'];
    if (data is List) {
      return data.map((json) => CourseModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
