import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/dashboard/data/datasources/gttp_remote_datasource.dart';

final certificatesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getCertificates();
});

final schedulesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getSchedules();
});

final subjectsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getSubjects();
});

final syllabusProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getSyllabus();
});

final timetableProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getTimetable();
});

final noticesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getNotices();
});

final schoolsApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getSchools();
});

final studentsApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getStudents();
});

final classesApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(gttpRemoteDataSourceProvider).getClasses();
});
