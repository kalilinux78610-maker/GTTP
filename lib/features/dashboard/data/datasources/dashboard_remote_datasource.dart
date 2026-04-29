import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.read(apiClientProvider));
});

class DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSource(this._apiClient);

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

  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await _apiClient.get('/dashboard', requiresAuth: true);
      final greetingName = _userDisplayNameFromResponse(response);

      // ── Debug: print the raw response so we can see the real field names ──
      if (kDebugMode) {
        debugPrint('[Dashboard] Raw API response keys: ${response.keys.toList()}');
        debugPrint('[Dashboard] Full response: $response');
        if (greetingName != null) {
          debugPrint('[Dashboard] Parsed user display name: $greetingName');
        }
      }

      // Try nested under 'data' key first
      final data = response['data'];
      if (data is Map) {
        if (kDebugMode) debugPrint('[Dashboard] Parsing from data key: $data');
        return DashboardModel.fromJson(
          Map<String, dynamic>.from(data),
          currentUserDisplayName: greetingName,
        );
      }

      // Try nested under 'stats' key
      final stats = response['stats'];
      if (stats is Map) {
        if (kDebugMode) debugPrint('[Dashboard] Parsing from stats key: $stats');
        return DashboardModel.fromJson(
          Map<String, dynamic>.from(stats),
          currentUserDisplayName: greetingName,
        );
      }

      // Try flat root response
      final knownKeys = [
        'total_students', 'totalStudents',
        'total_classes', 'totalClasses',
        'total_users', 'totalUsers',
        'total_notices', 'totalNotices',
        'total_schools', 'totalSchools',
      ];
      if (knownKeys.any((k) => response.containsKey(k))) {
        if (kDebugMode) debugPrint('[Dashboard] Parsing from root: $response');
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
            if (kDebugMode) debugPrint('[Dashboard] Parsing from nested key "${entry.key}": $nested');
            return DashboardModel.fromJson(
              nested,
              currentUserDisplayName: greetingName,
            );
          }
        }
      }

      // Last resort — parse what we have (zeros for missing fields)
      if (kDebugMode) debugPrint('[Dashboard] Warning: no known keys found — returning zeros. Response was: $response');
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
