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

  Future<void> enrollCourse(String id) async {
    await _apiClient.post('/courses/$id/enroll', requiresAuth: true);
  }

  Future<List<Map<String, dynamic>>> getCourseEnrolledStudents(String id) async {
    final response = await _apiClient.get('/faculty/courses/$id/students', requiresAuth: true);
    return ApiJsonParser.extractList(response).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingSubmissions(String courseId) async {
    final response = await _apiClient.get('/admin/submissions/pending?courseId=$courseId', requiresAuth: true);
    return ApiJsonParser.extractList(response).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> submitQuiz(String courseId, String moduleId, int scorePercentage, bool passed) async {
    await _apiClient.post(
      '/courses/$courseId/modules/$moduleId/quiz/submit',
      requiresAuth: true,
      data: {
        'score_percentage': scorePercentage,
        'passed': passed,
      },
    );
  }

  Future<void> reviewSubmission(String submissionId, String status, String feedback) async {
    await _apiClient.post(
      '/admin/submissions/$submissionId/review',
      requiresAuth: true,
      data: {
        'status': status,
        'feedback': feedback,
      },
    );
  }

  Future<void> markModuleComplete(String courseId, String moduleId) async {
    await _apiClient.post(
      '/courses/$courseId/modules/$moduleId/complete',
      requiresAuth: true,
    );
  }

  Future<void> createModule({
    required String courseId,
    required String title,
    required String type,
    int? order,
    int? durationHours,
    int? reminderDays,
  }) async {
    final requestData = <String, dynamic>{
      'title': title,
      'type': type,
    };
    if (order != null) requestData['order'] = order;
    if (durationHours != null) requestData['duration_hours'] = durationHours;
    if (reminderDays != null) requestData['reminder_days'] = reminderDays;

    await _apiClient.post(
      '/courses/$courseId/modules',
      requiresAuth: true,
      data: requestData,
    );
  }
}
