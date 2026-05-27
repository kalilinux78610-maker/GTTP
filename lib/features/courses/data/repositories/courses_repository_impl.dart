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
}
