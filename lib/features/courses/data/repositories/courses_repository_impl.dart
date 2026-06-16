import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import '../../domain/repositories/courses_repository.dart';
import '../datasources/courses_remote_datasource.dart';
import '../models/course_model.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  final remoteDataSource = ref.watch(coursesRemoteDataSourceProvider);
  return CoursesRepositoryImpl(remoteDataSource);
});

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesRemoteDataSource _remoteDataSource;

  CoursesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      return await _remoteDataSource.getCourses();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch courses: $e');
    }
  }

  @override
  Future<CourseModel?> getCourseDetails(String id) async {
    try {
      return await _remoteDataSource.getCourseDetails(id);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch course details: $e');
    }
  }

  @override
  Future<void> enrollCourse(String id) async {
    try {
      await _remoteDataSource.enrollCourse(id);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to enroll in course: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseEnrolledStudents(String id) async {
    try {
      return await _remoteDataSource.getCourseEnrolledStudents(id);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get enrolled students: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSubmissions(String courseId) async {
    try {
      return await _remoteDataSource.getPendingSubmissions(courseId);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get pending submissions: $e');
    }
  }

  @override
  Future<void> submitQuiz(String courseId, String moduleId, int scorePercentage, bool passed) async {
    try {
      await _remoteDataSource.submitQuiz(courseId, moduleId, scorePercentage, passed);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit quiz: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> markModuleComplete(String courseId, String moduleId) async {
    try {
      return await _remoteDataSource.markModuleComplete(courseId, moduleId);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to mark module as complete: $e');
    }
  }
}
