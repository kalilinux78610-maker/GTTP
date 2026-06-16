import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/courses_repository_impl.dart';

final courseDetailsProvider =
    FutureProvider.autoDispose.family<CourseModel?, String>((ref, id) async {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getCourseDetails(id);
});

final courseEnrolledStudentsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getCourseEnrolledStudents(id);
});

final coursePendingSubmissionsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getPendingSubmissions(id);
});
