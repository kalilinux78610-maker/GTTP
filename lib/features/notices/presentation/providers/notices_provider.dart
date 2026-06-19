import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/cache/cache_service.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/data/repositories/notices_repository_impl.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/features/school_network/presentation/providers/school_network_provider.dart';
import 'package:gttp/core/auth/user_role.dart';

const _noticesCacheKey = 'notices_list';
const _cacheTTL = Duration(minutes: 15);

/// Provider for the list of notices with offline support
final noticesProvider = FutureProvider<List<NoticeModel>>((ref) async {
  final isOnline = ref.read(isOnlineProvider);
  final cache = CacheService.instance;
  final repository = ref.read(noticesRepositoryProvider);
  
  // Try cache first
  final cached = cache.getList<NoticeModel>(
    _noticesCacheKey,
    fromJson: (json) => NoticeModel.fromJson(json),
  );
  
  if (cached != null) {
    // If offline, return cached data
    if (!isOnline) {
      return cached;
    }
  }
  
  // If online and no cache, fetch from API
  if (isOnline) {
    try {
      final notices = await repository.getNotices();
      await cache.putList(_noticesCacheKey, notices, ttl: _cacheTTL);
      return notices;
    } catch (e) {
      // If API fails but we have cache, return cache
      if (cached != null) return cached;
      rethrow;
    }
  }
  
  // No cache and offline
  return cached ?? [];
});

/// Provider for individual notice detail
final noticeDetailProvider = FutureProvider.family<NoticeModel, String>((ref, id) async {
  // First try to find it in the already loaded list to display it instantly
  try {
    final noticesList = await ref.read(noticesNotifierProvider.future);
    final notice = noticesList.firstWhere((n) => n.id == id);
    
    // Optionally mark it as read in the background if it's unread
    if (!notice.isRead) {
      Future.microtask(() => ref.read(noticesNotifierProvider.notifier).markAsRead(id));
    }
    return notice;
  } catch (_) {
    // Fallback to API if it's not in the list (e.g. from a deep link)
    return ref.read(noticesRepositoryProvider).getNoticeDetail(id);
  }
});

/// Notifier for managing notices state with offline support
class NoticesNotifier extends AsyncNotifier<List<NoticeModel>> {
  Timer? _pollingTimer;

  @override
  Future<List<NoticeModel>> build() async {
    final isOnline = ref.read(isOnlineProvider);
    final cache = CacheService.instance;
    final repository = ref.read(noticesRepositoryProvider);
    
    // Set up Smart Polling (every 15 seconds)
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (ref.read(isOnlineProvider)) {
        _pollUpdates();
      }
    });
    
    // Try cache first
    final cached = cache.getList<NoticeModel>(
      _noticesCacheKey,
      fromJson: (json) => NoticeModel.fromJson(json),
    );
    
    // If offline, return cached data
    if (!isOnline) {
      return cached ?? [];
    }
    
    // If online, fetch from API
    try {
      final notices = await repository.getNotices();
      await cache.putList(_noticesCacheKey, notices, ttl: _cacheTTL);
      return notices;
    } catch (e) {
      // If API fails but we have cache, return cache
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Silently fetches updates in the background without causing a loading flicker
  Future<void> _pollUpdates() async {
    try {
      final repository = ref.read(noticesRepositoryProvider);
      final cache = CacheService.instance;
      final notices = await repository.getNotices();
      await cache.putList(_noticesCacheKey, notices, ttl: _cacheTTL);
      
      // Update state if we successfully fetched new data
      state = AsyncData(notices);
    } catch (_) {
      // Ignore polling errors so the UI isn't disrupted
    }
  }

  Future<void> refresh() async {
    final isOnline = ref.read(isOnlineProvider);
    
    if (!isOnline) {
      // Can't refresh when offline
      return;
    }
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(noticesRepositoryProvider);
      final cache = CacheService.instance;
      final notices = await repository.getNotices();
      await cache.putList(_noticesCacheKey, notices, ttl: _cacheTTL);
      return notices;
    });
  }

  Future<void> markAsRead(String id) async {
    final isOnline = ref.read(isOnlineProvider);
    
    if (!isOnline) {
      // Can't mark as read when offline
      return;
    }

    // Optimistic Update: immediately remove the NEW badge in the UI
    if (state.hasValue && state.value != null) {
      final notices = [...state.value!];
      final index = notices.indexWhere((n) => n.id == id);
      if (index != -1 && !notices[index].isRead) {
        notices[index] = notices[index].copyWith(isRead: true);
        state = AsyncData(notices);
        CacheService.instance.putList(_noticesCacheKey, notices, ttl: _cacheTTL);
      }
    }
    
    // Send to backend in the background
    try {
      await ref.read(noticesRepositoryProvider).markAsRead(id);
    } catch (_) {
      // Ignore API errors for read receipts
    }
  }

  Future<void> createNotice({
    required String title,
    required String content,
    required String category,
    required String priority,
    required bool isPinned,
    required String targetAudience,
  }) async {
    await ref.read(noticesRepositoryProvider).createNotice(
      title: title,
      content: content,
      category: category,
      priority: priority,
      isPinned: isPinned,
      targetAudience: targetAudience,
    );
    // Refresh the list so the new notice appears immediately
    await refresh();
  }
}

final noticesNotifierProvider = AsyncNotifierProvider<NoticesNotifier, List<NoticeModel>>(
  NoticesNotifier.new,
);

/// Search query state for notices
class NoticeSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final noticeSearchQueryProvider = NotifierProvider<NoticeSearchQueryNotifier, String>(() {
  return NoticeSearchQueryNotifier();
});

/// Selected category filter for notices
class NoticeCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? category) {
    state = category;
  }
}

final noticeCategoryProvider = NotifierProvider<NoticeCategoryNotifier, String?>(() {
  return NoticeCategoryNotifier();
});

/// Notices filtered only by user role and school, used for accurate badge counts
final roleFilteredNoticesProvider = Provider<AsyncValue<List<NoticeModel>>>((ref) {
  final asyncNotices = ref.watch(noticesNotifierProvider);
  final dashboardDataAsync = ref.watch(dashboardDataProvider);
  final userDataAsync = ref.watch(userModelProvider);

  if (!asyncNotices.hasValue || !dashboardDataAsync.hasValue || !userDataAsync.hasValue) {
    if (asyncNotices.hasError) {
      return AsyncError(asyncNotices.error!, asyncNotices.stackTrace!);
    }
    if (dashboardDataAsync.hasError) {
      return AsyncError(dashboardDataAsync.error!, dashboardDataAsync.stackTrace!);
    }
    if (userDataAsync.hasError) {
      return AsyncError(userDataAsync.error!, userDataAsync.stackTrace!);
    }
    return const AsyncLoading();
  }

  final dashboardData = dashboardDataAsync.value;
  final userData = userDataAsync.value;

  return asyncNotices.whenData((notices) {
    var filtered = List<NoticeModel>.from(notices);
    
    // Strict security: if user context is missing, return nothing.
    if (userData == null || dashboardData == null) {
      return <NoticeModel>[];
    }

    final appRole = AppUserRole.fromApi(userData.role);
      
      // Filter for school/college level roles
      if (appRole.isPrincipal || appRole.usesTeacherDashboard || appRole == AppUserRole.student) {
        final dashboardSchool = dashboardData.schoolName?.toLowerCase() ?? '';
        final userSchool = userData.institute?.toLowerCase() ?? '';
        final userSchoolId = userData.schoolId?.toString() ?? '';
        final schoolName = dashboardSchool.isNotEmpty ? dashboardSchool : userSchool;
        
        filtered = filtered.where((notice) {
          // Bypass school check if it's a global notice
          if (notice.isGlobal) return true;

          if (notice.targetInstituteNames.isNotEmpty) {
            bool targetsSchool = false;
            
            if (schoolName.isNotEmpty) {
              targetsSchool = notice.targetInstituteNames.any((name) => 
                 name.toLowerCase().contains(schoolName) || schoolName.contains(name.toLowerCase())
              );
            }
            
            if (!targetsSchool && notice.schoolId != null && userSchoolId.isNotEmpty) {
              if (notice.schoolId == userSchoolId) targetsSchool = true;
            }
            
            if (!targetsSchool) return false;
          }
          return true;
        }).toList();
      } 
      // Filter for coordinator roles
      else if (appRole.isCoordinator) {
        final assignedSchools = ref.watch(schoolsProvider).value;
        
        filtered = filtered.where((notice) {
          // Bypass school check if it's a global notice
          if (notice.isGlobal) return true;

          if (notice.targetInstituteNames.isNotEmpty) {
            if (assignedSchools == null || assignedSchools.isEmpty) return false;
            
            bool targetsAssignedSchool = notice.targetInstituteNames.any((targetName) => 
               assignedSchools.any((school) => 
                 school.title.toLowerCase().contains(targetName.toLowerCase()) || 
                 targetName.toLowerCase().contains(school.title.toLowerCase())
               )
            );
            if (!targetsAssignedSchool) return false;
          }
          return true;
        }).toList();
      }

      // 2. Global Target Audience Filter (applies to ALL roles)
      filtered = filtered.where((notice) {
        final target = notice.targetAudience?.toLowerCase() ?? '';
        
        if (target.isNotEmpty && target != 'all users' && target != 'all members' && target != 'all') {
          
          // Super Admins and Admins can see ALL notices to manage them
          if (appRole == AppUserRole.superAdmin || appRole == AppUserRole.admin) {
            return true;
          }

          // Strict checking for Students
          if (target == 'students' || target.contains('student only') || target == 'students only') {
            return appRole == AppUserRole.student;
          }

          // Strict checking for Faculty/Teachers
          if (target == 'faculty' || target == 'teacher' || target == 'teachers' || target.contains('faculty only') || target.contains('teacher only')) {
            return appRole == AppUserRole.faculty;
          }

          // Strict checking for Principals
          if (target == 'principal' || target == 'principals' || target.contains('principal only')) {
            return appRole.isPrincipal;
          }

          // Strict checking for Coordinators
          if (target == 'coordinator' || target == 'coordinators' || target.contains('coordinator only') || target.contains('national coordinator')) {
            return appRole.isCoordinator;
          }

          // If target is "staff", faculty, principals, and coordinators can see it (not students)
          if (target == 'staff' || target.contains('staff only')) {
            return appRole == AppUserRole.faculty || appRole.isPrincipal || appRole.isCoordinator;
          }

          // Catch-all: hide any other staff-oriented notices from students
          if (appRole == AppUserRole.student) {
            if (target.contains('faculty') || 
                target.contains('teacher') || 
                target.contains('staff') || 
                target.contains('principal') || 
                target.contains('coordinator')) {
              return false;
            }
          }
        }
        
        return true;
      }).toList();
      
    return filtered;
  });
});

/// Filtered notices based on search and category
final filteredNoticesProvider = Provider<AsyncValue<List<NoticeModel>>>((ref) {
  final query = ref.watch(noticeSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(noticeCategoryProvider);
  final roleFiltered = ref.watch(roleFilteredNoticesProvider);

  return roleFiltered.whenData((notices) {
    var filtered = List<NoticeModel>.from(notices);
    
    // Filter by category
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((notice) => 
        notice.category.toLowerCase() == category.toLowerCase()
      ).toList();
    }
    
    // Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered.where((notice) {
        final titleMatches = notice.title.toLowerCase().contains(query);
        final contentMatches = notice.content.toLowerCase().contains(query);
        final authorMatches = notice.authorName.toLowerCase().contains(query);
        return titleMatches || contentMatches || authorMatches;
      }).toList();
    }
    
    // Sort: pinned first, then by date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filtered;
  });
});

