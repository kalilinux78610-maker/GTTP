import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/cache/cache_service.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/data/repositories/notices_repository_impl.dart';

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
    
    await ref.read(noticesRepositoryProvider).markAsRead(id);
    await refresh();
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

/// Filtered notices based on search and category
final filteredNoticesProvider = Provider<AsyncValue<List<NoticeModel>>>((ref) {
  final query = ref.watch(noticeSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(noticeCategoryProvider);
  final asyncNotices = ref.watch(noticesNotifierProvider);

  return asyncNotices.whenData((notices) {
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
