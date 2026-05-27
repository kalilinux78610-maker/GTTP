import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/school_network/data/datasources/school_network_remote_datasource.dart';
import 'package:gttp/features/school_network/data/models/school_model.dart';
import 'package:gttp/features/school_network/domain/repositories/school_network_repository.dart';

final schoolNetworkRemoteDataSourceProvider =
    Provider<SchoolNetworkRemoteDataSource>((ref) {
      return SchoolNetworkRemoteDataSource(ref.read(apiClientProvider));
    });

final schoolNetworkRepositoryProvider = Provider<SchoolNetworkRepository>((
  ref,
) {
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
      // Fetch schools, students, and classes in parallel
      final results = await Future.wait([
        _remoteDataSource.getSchools(),
        _tryReadSupplemental('students', _remoteDataSource.getStudents),
        _tryReadSupplemental('classes', _remoteDataSource.getClasses),
      ]);
      final schoolsData = results[0];
      final studentsData = results[1];
      final classesData = results[2];

      if (kDebugMode && schoolsData.isNotEmpty) {
        debugPrint(
          '[SchoolNetwork] First school keys: ${schoolsData.first.keys.toList()}',
        );
      }
      if (kDebugMode && classesData.isNotEmpty) {
        debugPrint(
          '[SchoolNetwork] First class keys: ${classesData.first.keys.toList()}',
        );
      }

      // Build student counts by school name
      final studentCountsBySchoolName = <String, int>{};
      for (final student in studentsData) {
        final schoolName = _extractSchoolName(student);
        if (schoolName.isEmpty) continue;
        studentCountsBySchoolName[schoolName] =
            (studentCountsBySchoolName[schoolName] ?? 0) + 1;
      }

      // Build course counts per school (by school id, name, or title)
      // Classes typically have: school_id, school_name, or nested school object
      final courseCountsBySchoolId = <String, int>{};
      final courseCountsBySchoolName = <String, int>{};
      for (final cls in classesData) {
        // Try school_id first
        final schoolId =
            (cls['school_id'] ?? cls['schoolId'])?.toString().trim() ?? '';
        if (schoolId.isNotEmpty) {
          courseCountsBySchoolId[schoolId] =
              (courseCountsBySchoolId[schoolId] ?? 0) + 1;
        }
        // Also index by school name from nested school object
        final schoolObj = cls['school'];
        if (schoolObj is Map) {
          final sName =
              (schoolObj['name'] ??
                      schoolObj['title'] ??
                      schoolObj['school_name'])
                  ?.toString()
                  .trim() ??
              '';
          if (sName.isNotEmpty) {
            courseCountsBySchoolName[_normalized(sName)] =
                (courseCountsBySchoolName[_normalized(sName)] ?? 0) + 1;
          }
        }
        // Flat school name on class
        final flatSchoolName =
            (cls['school_name'] ?? cls['schoolName'])?.toString().trim() ?? '';
        if (flatSchoolName.isNotEmpty) {
          courseCountsBySchoolName[_normalized(flatSchoolName)] =
              (courseCountsBySchoolName[_normalized(flatSchoolName)] ?? 0) + 1;
        }
      }

      // Map schools with resolved student counts and course counts
      final schools = schoolsData.map((json) {
        final school = SchoolModel.fromJson(json);
        final normalized = _normalized(school.title);

        // Resolve student count
        final resolvedStudentCount = studentCountsBySchoolName[normalized];

        // Resolve active courses: prefer API field, then count from classes
        int resolvedCourses = school.activeCourses;
        if (resolvedCourses == 0) {
          // Try by school id
          final byId = courseCountsBySchoolId[school.id.trim()];
          if (byId != null && byId > 0) {
            resolvedCourses = byId;
          } else {
            // Try by school name
            final byName = courseCountsBySchoolName[normalized];
            if (byName != null && byName > 0) resolvedCourses = byName;
          }
        }

        return SchoolModel(
          id: school.id,
          title: school.title,
          location: school.location,
          facultyCount: school.facultyCount,
          studentCount: resolvedStudentCount ?? school.studentCount,
          principalName: school.principalName,
          coordinatorName: school.coordinatorName,
          phone: school.phone,
          email: school.email,
          establishedYear: school.establishedYear,
          activeCourses: resolvedCourses,
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

      if (kDebugMode) {
        debugPrint('[SchoolNetwork] Resolved ${mergedByKey.length} schools');
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

  Future<List<Map<String, dynamic>>> _tryReadSupplemental(
    String label,
    Future<List<Map<String, dynamic>>> Function() load,
  ) async {
    try {
      return await load();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SchoolNetwork] Supplemental $label unavailable: $e');
      }
      return const [];
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
      facultyCount: a.facultyCount >= b.facultyCount
          ? a.facultyCount
          : b.facultyCount,
      studentCount: a.studentCount >= b.studentCount
          ? a.studentCount
          : b.studentCount,
      principalName: _pickBetterText(a.principalName, b.principalName),
      coordinatorName: _pickBetterText(a.coordinatorName, b.coordinatorName),
      phone: _pickBetterText(a.phone, b.phone),
      email: _pickBetterText(a.email, b.email),
      establishedYear: _pickBetterText(a.establishedYear, b.establishedYear),
      activeCourses: a.activeCourses >= b.activeCourses
          ? a.activeCourses
          : b.activeCourses,
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
