import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
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
  final submissions = await repository.getPendingSubmissions(id);
  
  final currentRole = await ref.watch(currentUserRoleProvider.future);
  
  return submissions.where((sub) {
    final status = sub['status']?.toString().toLowerCase();
    switch (currentRole.name.toLowerCase()) {
      case 'coordinator':
      case 'admin':
      case 'superadmin':
        return status == 'pending';
      default:
        return false;
    }
  }).toList();
});
