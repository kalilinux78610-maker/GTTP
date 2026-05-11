import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/school_network/data/datasources/school_network_remote_datasource.dart';
import 'package:gttp/features/school_network/data/models/school_model.dart';
import 'package:gttp/features/school_network/domain/repositories/school_network_repository.dart';

final schoolNetworkRemoteDataSourceProvider = Provider<SchoolNetworkRemoteDataSource>((ref) {
  return SchoolNetworkRemoteDataSource(ref.read(apiClientProvider));
});

final schoolNetworkRepositoryProvider = Provider<SchoolNetworkRepository>((ref) {
  return SchoolNetworkRepositoryImpl(
    ref.read(schoolNetworkRemoteDataSourceProvider),
  );
});

class SchoolNetworkRepositoryImpl implements SchoolNetworkRepository {
  final SchoolNetworkRemoteDataSource _remoteDataSource;

  SchoolNetworkRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SchoolModel>> getSchools() async {
    try {
      // Fetch schools and students to compute accurate student counts
      final schoolsData = await _remoteDataSource.getSchools();
      final studentsData = await _remoteDataSource.getStudents();

      // Build student counts by school name
      final studentCountsBySchoolName = <String, int>{};
      for (final student in studentsData) {
        final schoolName = _extractSchoolName(student);
        if (schoolName.isEmpty) continue;
        studentCountsBySchoolName[schoolName] =
            (studentCountsBySchoolName[schoolName] ?? 0) + 1;
      }

      // Map schools with resolved student counts
      final schools = schoolsData.map((json) {
        final school = SchoolModel.fromJson(json);
        final normalized = _normalized(school.title);
        final resolvedStudentCount = studentCountsBySchoolName[normalized];
        if (resolvedStudentCount == null) return school;
        return SchoolModel(
          id: school.id,
          title: school.title,
          location: school.location,
          facultyCount: school.facultyCount,
          studentCount: resolvedStudentCount,
          principalName: school.principalName,
          coordinatorName: school.coordinatorName,
          phone: school.phone,
          email: school.email,
          establishedYear: school.establishedYear,
          activeCourses: school.activeCourses,
        );
      }).toList();

      // Deduplicate and merge schools
      final mergedByKey = <String, SchoolModel>{};
      for (final school in schools) {
        final dedupeKey = school.id.trim().isNotEmpty
            ? school.id.trim()
            : '${_normalized(school.title)}|${_normalized(school.location)}';
        final existing = mergedByKey[dedupeKey];
        if (existing == null) {
          mergedByKey[dedupeKey] = school;
          continue;
        }
        mergedByKey[dedupeKey] = _mergeSchools(existing, school);
      }

      return mergedByKey.values.toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get schools: $e');
    }
  }

  @override
  Future<SchoolModel> getSchoolDetail(String id) async {
    try {
      final response = await _remoteDataSource.getSchoolDetail(id);
      return SchoolModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get school detail: $e');
    }
  }

  String _normalized(String value) => value.trim().toLowerCase();

  String _extractSchoolName(Map<String, dynamic> student) {
    const keys = [
      'school_name',
      'schoolName',
      'school',
      'institute',
      'institute_name',
      'branch_name',
    ];

    for (final key in keys) {
      final value = student[key];
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return _normalized(text);
    }

    // Check nested paths
    final nestedPaths = ['school.name', 'school.title', 'school.school_name'];
    for (final path in nestedPaths) {
      final parts = path.split('.');
      dynamic current = student;
      for (final part in parts) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          current = null;
          break;
        }
      }
      final text = current?.toString().trim() ?? '';
      if (text.isNotEmpty) return _normalized(text);
    }

    return '';
  }

  SchoolModel _mergeSchools(SchoolModel a, SchoolModel b) {
    return SchoolModel(
      id: a.id.isNotEmpty ? a.id : b.id,
      title: a.title.isNotEmpty ? a.title : b.title,
      location: a.location.isNotEmpty ? a.location : b.location,
      facultyCount: a.facultyCount >= b.facultyCount ? a.facultyCount : b.facultyCount,
      studentCount: a.studentCount >= b.studentCount ? a.studentCount : b.studentCount,
      principalName: _pickBetterText(a.principalName, b.principalName),
      coordinatorName: _pickBetterText(a.coordinatorName, b.coordinatorName),
      phone: _pickBetterText(a.phone, b.phone),
      email: _pickBetterText(a.email, b.email),
      establishedYear: _pickBetterText(a.establishedYear, b.establishedYear),
      activeCourses: a.activeCourses >= b.activeCourses ? a.activeCourses : b.activeCourses,
    );
  }

  String _pickBetterText(String a, String b) {
    final aa = a.trim();
    final bb = b.trim();
    final aEmpty = aa.isEmpty || aa == '-' || aa.toLowerCase() == 'null';
    final bEmpty = bb.isEmpty || bb == '-' || bb.toLowerCase() == 'null';
    if (!aEmpty) return aa;
    if (!bEmpty) return bb;
    return aa.isNotEmpty ? aa : bb;
  }
}
