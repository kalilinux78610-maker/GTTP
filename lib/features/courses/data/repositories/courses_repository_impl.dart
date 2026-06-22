import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/cache/cache_service.dart';
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
    const cacheKey = 'courses_list_cache';
    try {
      final courses = await _remoteDataSource.getCourses();
      final coursesJson = courses.map((c) => c.toJson()).toList();
      await CacheService.instance.putList(cacheKey, coursesJson);
      return courses;
    } catch (e) {
      final cachedJsonList = CacheService.instance.getList<Map<String, dynamic>>(
        cacheKey,
        fromJson: (json) => json,
      );
      if (cachedJsonList != null) {
        return cachedJsonList.map((json) => CourseModel.fromJson(json)).toList();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch courses: $e');
    }
  }

  @override
  Future<CourseModel?> getCourseDetails(String id) async {
    final cacheKey = 'course_details_$id';
    try {
      final course = await _remoteDataSource.getCourseDetails(id);
      if (course != null) {
        await CacheService.instance.put(cacheKey, course.toJson());
      }
      return course;
    } catch (e) {
      final cachedJson = CacheService.instance.get<Map<String, dynamic>>(
        cacheKey,
        fromJson: (json) => json,
      );
      if (cachedJson != null) {
        return CourseModel.fromJson(cachedJson);
      }
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
  Future<void> submitQuiz(String courseId, String moduleId, int scorePercentage, bool passed, [String? submoduleId]) async {
    try {
      await _remoteDataSource.submitQuiz(courseId, moduleId, scorePercentage, passed, submoduleId);
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

  @override
  Future<Map<String, dynamic>> markSubmoduleComplete(String courseId, String moduleId, String submoduleId) async {
    try {
      return await _remoteDataSource.markSubmoduleComplete(courseId, moduleId, submoduleId);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to mark submodule as complete: $e');
    }
  }

  @override
  Future<void> submitSessionProof(String courseId, String sessionId, String fileName, List<int> fileBytes) async {
    try {
      await _remoteDataSource.submitSessionProof(courseId, sessionId, fileName, fileBytes);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit session proof: $e');
    }
  }

  @override
  Future<void> reviewSubmission(String submissionId, String status, String reviewNotes) async {
    try {
      await _remoteDataSource.reviewSubmission(submissionId, status, reviewNotes);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to review submission: $e');
    }
  }
}
