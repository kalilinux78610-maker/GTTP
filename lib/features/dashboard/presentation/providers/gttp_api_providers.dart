import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/data/datasources/gttp_remote_datasource.dart';

void _setupPolling(Ref ref) {
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    if (ref.read(isOnlineProvider)) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(timer.cancel);
}

final certificatesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getCertificates();
});

final schedulesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getSchedules();
});

final subjectsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getSubjects();
});

final syllabusProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getSyllabus();
});

final timetableProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getTimetable();
});

final noticesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getNotices();
});

final schoolsApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getSchools();
});

final studentsApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  // Pass the school name if the user is a teacher/coordinator
  return ref.read(gttpRemoteDataSourceProvider).getStudents();
});


final myStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final allStudents = await ref.watch(studentsApiProvider.future);
  final user = await ref.watch(userModelProvider.future);
  
  if (user != null && user.institute != null && user.institute!.isNotEmpty) {
    // Check if user is a teacher or coordinator
    final role = await ref.watch(currentUserRoleProvider.future);
    if (role == AppUserRole.faculty || role == AppUserRole.coordinator) {
      final userSchool = user.institute!.toLowerCase().trim();
      return allStudents.where((student) {
        final studentSchool = StudentRowParser.school(student).toLowerCase().trim();
        // If student school is empty, we might exclude them or include them. We exclude them for strict filtering.
        if (studentSchool.isEmpty || studentSchool == 'unknown school') return false;
        
        // Exact match or partial match (e.g. "St. John's" matches "St. John's High School")
        return studentSchool.contains(userSchool) || userSchool.contains(studentSchool);
      }).toList();
    }
  }
  
  // Admins or users without a school see all students
  return allStudents;
});

final classesApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getClasses();
});

final coursesApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getCourses();
});

final facultyApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _setupPolling(ref);
  return ref.read(gttpRemoteDataSourceProvider).getFaculty();
});
