import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/data/datasources/gttp_remote_datasource.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:gttp/core/cache/cache_service.dart';

void _setupPolling(Ref ref, {Duration duration = const Duration(minutes: 5)}) {
  final timer = Timer.periodic(duration, (_) {
    if (ref.read(isOnlineProvider)) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(timer.cancel);
}

final _lastFetchTimes = <String, DateTime>{};

Future<List<Map<String, dynamic>>> _cacheFirstNetworkSecondFetch(
  Ref ref,
  String cacheKey,
  Future<List<Map<String, dynamic>>> Function() networkFetch,
) async {
  _setupPolling(ref);

  final cached = CacheService.instance.getList<Map<String, dynamic>>(
    cacheKey,
    fromJson: (json) => json,
  );

  final lastFetch = _lastFetchTimes[cacheKey] ?? DateTime.fromMillisecondsSinceEpoch(0);
  final isFresh = DateTime.now().difference(lastFetch) < const Duration(seconds: 10);

  if (!isFresh) {
    Future.microtask(() async {
      try {
        if (!ref.read(isOnlineProvider)) return;
        _lastFetchTimes[cacheKey] = DateTime.now();
        final newData = await networkFetch();
        
        await CacheService.instance.putList(cacheKey, newData);
        
        if (cached != null) {
          ref.invalidateSelf();
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[Cache-First] Background fetch failed for $cacheKey: $e');
      }
    });
  }

  if (cached != null && cached.isNotEmpty) {
    return cached;
  }

  final data = await networkFetch();
  await CacheService.instance.putList(cacheKey, data);
  _lastFetchTimes[cacheKey] = DateTime.now();
  return data;
}

final certificatesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'certificates_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getCertificates(),
  );
});

final schedulesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'schedules_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getSchedules(),
  );
});

final subjectsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'subjects_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getSubjects(),
  );
});

final syllabusProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'syllabus_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getSyllabus(),
  );
});

final timetableProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'timetable_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getTimetable(),
  );
});

final noticesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'notices_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getNotices(),
  );
});

final schoolsApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'schools_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getSchools(),
  );
});

final studentsApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Watch at root to rebuild if they change
  ref.watch(userModelProvider);
  ref.watch(currentUserRoleProvider);

  final user = await ref.read(userModelProvider.future);
  final role = await ref.read(currentUserRoleProvider.future);
  
  String? schoolQuery;
  if (user != null && (role == AppUserRole.faculty || role == AppUserRole.coordinator || role == AppUserRole.principal || role == AppUserRole.unknown)) {
    if (user.institute != null && user.institute!.isNotEmpty) {
      schoolQuery = user.institute;
    }
  }

  return ref.read(gttpRemoteDataSourceProvider).getStudents(school: schoolQuery);
});

final studentCoursesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  return ref.read(gttpRemoteDataSourceProvider).getStudentCourses(studentId);
});


final myStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final allStudents = await ref.watch(studentsApiProvider.future);
  final user = await ref.watch(userModelProvider.future);
  
  if (user != null && user.institute != null && user.institute!.isNotEmpty) {
    final role = await ref.watch(currentUserRoleProvider.future);
    if (role == AppUserRole.faculty || role == AppUserRole.coordinator || role == AppUserRole.principal || role == AppUserRole.unknown) {
      
      // Get the real school name from dashboard if available synchronously (avoids blocking and infinite loading!)
      final asyncDashboard = ref.read(dashboardDataProvider);
      final dashboard = asyncDashboard.hasValue ? asyncDashboard.value : null;
      final realSchoolName = dashboard?.schoolName?.toLowerCase().trim();
      
      final userSchool = user.institute!.toLowerCase().trim();
      
      return allStudents.where((student) {
        // 1. Try strict ID match
        if (user.schoolId != null) {
          final sId = student['school_id'] ?? student['schoolId'];
          if (sId != null && sId.toString() == user.schoolId.toString()) {
            return true;
          }
        }
        
        final studentSchool = StudentRowParser.school(student).toLowerCase().trim();
        final studentInstituteName = (student['institute_name']?.toString() ?? '').toLowerCase().trim();
        
        final effectiveStudentSchool = studentInstituteName.isNotEmpty ? studentInstituteName : studentSchool;
        
        if (effectiveStudentSchool.isEmpty || effectiveStudentSchool == 'unknown school') return false;
        
        // 2. Try real school name strict match if available
        if (realSchoolName != null && realSchoolName.isNotEmpty) {
           if (effectiveStudentSchool == realSchoolName) return true;
        }
        
        // 3. Exact match with user.institute
        if (effectiveStudentSchool == userSchool) return true;
        
        // 4. Fallback relaxed match if the user institute is long enough (to avoid generic 'school' matching everything)
        if (userSchool != 'school' && userSchool != 'college') {
           return effectiveStudentSchool.contains(userSchool) || userSchool.contains(effectiveStudentSchool);
        }
        
        // If userSchool is just 'school', we only match if the backend literally returned 'school' as the institute_name
        return false;
      }).toList();
    }
  }
  
  return allStudents;
});

final classesApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'classes_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getClasses(),
  );
});

final coursesApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'courses_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getCourses(),
  );
});

final facultyApiProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return _cacheFirstNetworkSecondFetch(
    ref,
    'faculty_cache',
    () => ref.read(gttpRemoteDataSourceProvider).getFaculty(),
  );
});
