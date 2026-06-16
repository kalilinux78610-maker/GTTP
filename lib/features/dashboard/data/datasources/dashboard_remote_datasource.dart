import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/auth/domain/entities/user.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final user = ref.watch(userModelProvider).value;
  return DashboardRemoteDataSource(ref.read(apiClientProvider), user);
});

class DashboardRemoteDataSource {
  final ApiClient _apiClient;
  final User? _currentUser;

  DashboardRemoteDataSource(this._apiClient, [this._currentUser]);

  /// Display name from `user` / `data.user` / `profile` (matches admin "Name" when API sends it).
  static String? _userDisplayNameFromResponse(Map<String, dynamic> response) {
    const keys = [
      'name',
      'full_name',
      'fullName',
      'display_name',
      'displayName',
      'username',
    ];
    final userMaps = <Map<String, dynamic>>[];
    void add(dynamic u) {
      if (u is Map) {
        userMaps.add(Map<String, dynamic>.from(u));
      }
    }

    add(response['user']);
    final data = response['data'];
    if (data is Map) {
      add(data['user']);
      add(data['profile']);
    }
    add(response['profile']);

    for (final map in userMaps) {
      for (final k in keys) {
        final v = map[k];
        if (v is String && v.trim().isNotEmpty) {
          return v.trim();
        }
      }

      // Fallback for first_name and last_name split
      final firstName = map['first_name'] ?? map['firstName'];
      final lastName = map['last_name'] ?? map['lastName'];
      if (firstName is String && firstName.trim().isNotEmpty) {
        final f = firstName.trim();
        final l = (lastName is String) ? lastName.trim() : '';
        return [f, l].where((s) => s.isNotEmpty).join(' ');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchDashboardResponse() async {
    String endpoint = '/dashboard';
    
    if (_currentUser != null) {
      if (_currentUser.roleLevel == 1 || _currentUser.role?.toLowerCase() == 'student') {
        endpoint = '/student/dashboard';
      } else if (_currentUser.role?.toLowerCase() == 'principal') {
        endpoint = '/principal/dashboard';
      } else if (_currentUser.role?.toLowerCase() == 'national coordinator') {
        endpoint = '/national-coordinator/dashboard';
      }
    }
    
    if (kDebugMode) {
      debugPrint('[DashboardRemoteDataSource] Fetching dashboard from $endpoint');
    }
    return _apiClient.get(endpoint, requiresAuth: true);
  }

  Future<DashboardModel> getDashboardData({Map<String, dynamic>? preloadedResponse}) async {
    try {
      // 1. Fetch dashboard data (or use preloaded) and schools concurrently to halve the loading time!
      final dashboardFuture = preloadedResponse != null
          ? Future.value(preloadedResponse)
          : fetchDashboardResponse();
      
      // We don't await immediately, we run them in parallel
      final schoolsFuture = _apiClient.get('/schools', requiresAuth: true);

      final results = await Future.wait([
        dashboardFuture,
        // Catch errors on schools so it doesn't crash the whole dashboard
        schoolsFuture.catchError((e) {
          debugPrint('[DashboardRemoteDataSource] Could not fetch schools data: $e');
          return <String, dynamic>{}; 
        })
      ]);

      final dashboardResponse = results[0];
      final schoolsResponse = results[1];

      var model = await parseDashboardResponse(dashboardResponse);

      // 2. Try merging schools data if available
      try {
        final data = schoolsResponse['data'];
        if (data is List) {
          if (data.length == 1) {
            final school = data.first;
            final totalStudents = int.tryParse(school['total_students'].toString()) ?? model.totalStudents;
            final totalFaculties = int.tryParse(school['total_faculties'].toString()) ?? model.totalUsers;
            final totalPrincipals = int.tryParse(school['total_principals'].toString()) ?? 0;
            final totalCoordinators = int.tryParse(school['total_coordinators'].toString()) ?? 0;
            final schoolLogo = school['logo'] as String?;
            final schoolName = school['name'] as String?;
            final schoolType = school['school_type'] as String? ?? school['type'] as String? ?? school['institute_type'] as String?;

            model = model.copyWith(
              totalStudents: totalStudents,
              totalUsers: totalFaculties + totalPrincipals + totalCoordinators,
              schoolLogo: schoolLogo,
              schoolName: schoolName,
              schoolType: schoolType,
              totalSchools: 1, // Single school context
            );
          }
        }
      } catch (e) {
        debugPrint('[DashboardRemoteDataSource] Error parsing schools data: $e');
      }

      return model;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DashboardRemoteDataSource] Dashboard API failed: $e');
      }
      rethrow;
    }
  }

  Future<DashboardModel> parseDashboardResponse(Map<String, dynamic> response) async {
    try {
      final greetingName = _userDisplayNameFromResponse(response);

      if (kDebugMode) {
        debugPrint(
          '[Dashboard] Raw API response keys: ${response.keys.toList()}',
        );
      }

      // Try nested under 'data' key first
      final data = response['data'];
      if (data is Map) {
        if (kDebugMode) debugPrint('[Dashboard] Parsing from data key');
        return DashboardModel.fromJson(
          Map<String, dynamic>.from(data),
          currentUserDisplayName: greetingName,
        );
      }

      // Try nested under 'stats' key
      final stats = response['stats'];
      if (stats is Map) {
        if (kDebugMode) debugPrint('[Dashboard] Parsing from stats key');
        return DashboardModel.fromJson(
          Map<String, dynamic>.from(stats),
          currentUserDisplayName: greetingName,
        );
      }

      final knownKeys = [
        'total_students',
        'totalStudents',
        'total_classes',
        'totalClasses',
        'total_courses',
        'totalCourses',
        'courses_count',
        'coursesCount',
        'enrolled_courses',
        'enrolledCourses',
        'my_courses',
        'myCourses',
        'total_users',
        'totalUsers',
        'total_notices',
        'totalNotices',
        'total_schools',
        'totalSchools',
        'total_schedules',
        'totalSchedules',
        'schedules_count',
        'schedulesCount',
        'my_schedules',
        'mySchedules',
        'total_certificates',
        'totalCertificates',
        'certificates_count',
        'certificatesCount',
        'my_certificates',
        'myCertificates',
        'earned_certificates',
        'earnedCertificates',
      ];
      if (knownKeys.any((k) => response.containsKey(k))) {
        if (kDebugMode) debugPrint('[Dashboard] Parsing from root keys');
        return DashboardModel.fromJson(
          response,
          currentUserDisplayName: greetingName,
        );
      }

      // ── New: try parsing every nested map value ──
      for (final entry in response.entries) {
        if (entry.value is Map) {
          final nested = Map<String, dynamic>.from(entry.value as Map);
          if (knownKeys.any((k) => nested.containsKey(k))) {
            if (kDebugMode) {
              debugPrint('[Dashboard] Parsing from nested key "${entry.key}"');
            }
            return DashboardModel.fromJson(
              nested,
              currentUserDisplayName: greetingName,
            );
          }
        }
      }

      // Last resort — parse what we have (zeros for missing fields)
      if (kDebugMode) {
        debugPrint(
          '[Dashboard] Warning: no known keys found — returning zeros.',
        );
      }
      return DashboardModel.fromJson(
        response,
        currentUserDisplayName: greetingName,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch dashboard: $e');
    }
  }
}
