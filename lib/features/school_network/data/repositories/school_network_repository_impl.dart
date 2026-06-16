import 'dart:async';
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

  /// In-memory cache so switching tabs or popping doesn't re-fetch.
  List<SchoolModel>? _cachedSchools;
  DateTime? _cacheTime;

  /// Cache is valid for 5 minutes — avoids hammering the API.
  static const _cacheDuration = Duration(minutes: 5);

  SchoolNetworkRepositoryImpl(this._remoteDataSource);

  bool get _isCacheValid =>
      _cachedSchools != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;

  /// Force-clear the cache (used on pull-to-refresh).
  void clearCache() {
    _cachedSchools = null;
    _cacheTime = null;
  }

  @override
  Future<List<SchoolModel>> getSchools() async {
    // Return cached data instantly if available
    if (_isCacheValid) {
      return _cachedSchools!;
    }
    // Backward compatibility: wait for the stream to emit its first item
    return await watchSchools().first;
  }

  @override
  Stream<List<SchoolModel>> watchSchools() async* {
    if (_isCacheValid) {
      if (kDebugMode) {
        debugPrint('[SchoolNetwork] Returning ${_cachedSchools!.length} cached schools from stream');
      }
      yield _cachedSchools!;
      return;
    }

    try {
      // Phase 1: Fetch schools first (fast, small payload)
      final schoolsData = await _remoteDataSource.getSchools();
      final basicSchools = schoolsData.map((json) => SchoolModel.fromJson(json)).toList();

      // Yield basic schools IMMEDIATELY so the UI renders fast
      yield basicSchools;

      // Phase 2: Enrich with students and classes in background
      try {
        final supplementalResults = await Future.wait([
          _tryReadSupplementalWithTimeout('students', _remoteDataSource.getStudents),
          _tryReadSupplementalWithTimeout('classes', _remoteDataSource.getClasses),
        ]);
        final studentsData = supplementalResults[0];
        final classesData = supplementalResults[1];

        // Build student counts by school name
        final studentCountsBySchoolName = <String, int>{};
        for (final student in studentsData) {
          final schoolName = _extractSchoolName(student);
          if (schoolName.isEmpty) continue;
          studentCountsBySchoolName[schoolName] =
              (studentCountsBySchoolName[schoolName] ?? 0) + 1;
        }

        // Build course counts per school
        final courseCountsBySchoolId = <String, int>{};
        final courseCountsBySchoolName = <String, int>{};
        for (final cls in classesData) {
          final schoolId = (cls['school_id'] ?? cls['schoolId'])?.toString().trim() ?? '';
          if (schoolId.isNotEmpty) {
            courseCountsBySchoolId[schoolId] = (courseCountsBySchoolId[schoolId] ?? 0) + 1;
          }
          final schoolObj = cls['school'];
          if (schoolObj is Map) {
            final sName = (schoolObj['name'] ?? schoolObj['title'] ?? schoolObj['school_name'])?.toString().trim() ?? '';
            if (sName.isNotEmpty) {
              courseCountsBySchoolName[_normalized(sName)] = (courseCountsBySchoolName[_normalized(sName)] ?? 0) + 1;
            }
          }
          final flatSchoolName = (cls['school_name'] ?? cls['schoolName'])?.toString().trim() ?? '';
          if (flatSchoolName.isNotEmpty) {
            courseCountsBySchoolName[_normalized(flatSchoolName)] = (courseCountsBySchoolName[_normalized(flatSchoolName)] ?? 0) + 1;
          }
        }

        // Enrich schools with resolved student/course counts
        bool hasChanges = false;
        final enrichedSchools = List<SchoolModel>.from(basicSchools);

        for (var i = 0; i < enrichedSchools.length; i++) {
          final school = enrichedSchools[i];
          final normalized = _normalized(school.title);

          final resolvedStudentCount = studentCountsBySchoolName[normalized];

          int resolvedCourses = school.activeCourses;
          if (resolvedCourses == 0) {
            final byId = courseCountsBySchoolId[school.id.trim()];
            if (byId != null && byId > 0) {
              resolvedCourses = byId;
            } else {
              final byName = courseCountsBySchoolName[normalized];
              if (byName != null && byName > 0) resolvedCourses = byName;
            }
          }

          if (resolvedStudentCount != null || resolvedCourses != school.activeCourses) {
            enrichedSchools[i] = SchoolModel(
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
            hasChanges = true;
          }
        }

        if (hasChanges) {
          if (kDebugMode) {
            debugPrint('[SchoolNetwork] Yielding enriched schools');
          }
          // Yield the enriched schools
          yield enrichedSchools;
          
          // Update Cache
          _cachedSchools = enrichedSchools;
          _cacheTime = DateTime.now();
        } else {
          // If no changes, just cache the basic ones
          _cachedSchools = basicSchools;
          _cacheTime = DateTime.now();
        }

      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SchoolNetwork] Supplemental enrichment failed (showing basic data): $e');
        }
        // Cache basic data if enrichment fails
        _cachedSchools = basicSchools;
        _cacheTime = DateTime.now();
      }

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

  /// Tries to load supplemental data with a generous timeout.
  /// If it takes longer than 45 seconds, returns empty list instead of blocking.
  Future<List<Map<String, dynamic>>> _tryReadSupplementalWithTimeout(
    String label,
    Future<List<Map<String, dynamic>>> Function() load,
  ) async {
    try {
      return await load().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('[SchoolNetwork] $label timed out after 45s — skipping');
          }
          return const [];
        },
      );
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
}
