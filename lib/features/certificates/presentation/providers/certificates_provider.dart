import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/cache/cache_service.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/features/certificates/data/models/certificate_model.dart';
import 'package:gttp/features/certificates/data/repositories/certificates_repository_impl.dart';

const _certificatesCacheKey = 'certificates_list';
const _cacheTTL = Duration(minutes: 30);

/// Provider for the list of certificates with offline support
final certificatesProvider = FutureProvider<List<CertificateModel>>((ref) async {
  final isOnline = ref.read(isOnlineProvider);
  final cache = CacheService.instance;
  final repository = ref.read(certificatesRepositoryProvider);
  
  // Try cache first
  final cached = cache.getList<CertificateModel>(
    _certificatesCacheKey,
    fromJson: (json) => CertificateModel.fromJson(json),
  );
  
  if (cached != null) {
    // If offline, return cached data
    if (!isOnline) {
      return cached;
    }
    // If online, return cached immediately but fetch fresh in background
    // For now, just return cached and let refresh() fetch fresh data
  }
  
  // If online and no cache, fetch from API
  if (isOnline) {
    try {
      final certificates = await repository.getCertificates();
      await cache.putList(_certificatesCacheKey, certificates, ttl: _cacheTTL);
      return certificates;
    } catch (e) {
      // If API fails but we have cache, return cache
      if (cached != null) return cached;
      rethrow;
    }
  }
  
  // No cache and offline
  return cached ?? [];
});

/// Provider for individual certificate detail
final certificateDetailProvider = FutureProvider.family<CertificateModel, String>((ref, id) async {
  return ref.read(certificatesRepositoryProvider).getCertificateDetail(id);
});

/// Notifier for managing certificates state with offline support
class CertificatesNotifier extends AsyncNotifier<List<CertificateModel>> {
  Timer? _pollingTimer;

  @override
  Future<List<CertificateModel>> build() async {
    final isOnline = ref.read(isOnlineProvider);
    final cache = CacheService.instance;
    final repository = ref.read(certificatesRepositoryProvider);
    
    // Set up Smart Polling
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (ref.read(isOnlineProvider)) {
        _pollUpdates();
      }
    });
    
    // Try cache first
    final cached = cache.getList<CertificateModel>(
      _certificatesCacheKey,
      fromJson: (json) => CertificateModel.fromJson(json),
    );
    
    // If offline, return cached data
    if (!isOnline) {
      return cached ?? [];
    }
    
    // If online, fetch from API
    try {
      final certificates = await repository.getCertificates();
      await cache.putList(_certificatesCacheKey, certificates, ttl: _cacheTTL);
      return certificates;
    } catch (e) {
      // If API fails but we have cache, return cache
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Silently fetches updates in the background without causing a loading flicker
  Future<void> _pollUpdates() async {
    try {
      final repository = ref.read(certificatesRepositoryProvider);
      final cache = CacheService.instance;
      final certificates = await repository.getCertificates();
      await cache.putList(_certificatesCacheKey, certificates, ttl: _cacheTTL);
      state = AsyncData(certificates);
    } catch (_) {
      // Ignore polling errors
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
      final repository = ref.read(certificatesRepositoryProvider);
      final cache = CacheService.instance;
      final certificates = await repository.getCertificates();
      await cache.putList(_certificatesCacheKey, certificates, ttl: _cacheTTL);
      return certificates;
    });
  }
}

final certificatesNotifierProvider = AsyncNotifierProvider<CertificatesNotifier, List<CertificateModel>>(
  CertificatesNotifier.new,
);

/// Search query state for certificates
class CertificateSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final certificateSearchQueryProvider = NotifierProvider<CertificateSearchQueryNotifier, String>(() {
  return CertificateSearchQueryNotifier();
});

/// Filtered certificates based on search
final filteredCertificatesProvider = Provider<AsyncValue<List<CertificateModel>>>((ref) {
  final query = ref.watch(certificateSearchQueryProvider).toLowerCase().trim();
  final asyncCertificates = ref.watch(certificatesNotifierProvider);

  return asyncCertificates.whenData((certificates) {
    if (query.isEmpty) return certificates;
    return certificates.where((cert) {
      final titleMatches = cert.title.toLowerCase().contains(query);
      final studentMatches = cert.studentName.toLowerCase().contains(query);
      final schoolMatches = cert.schoolName.toLowerCase().contains(query);
      return titleMatches || studentMatches || schoolMatches;
    }).toList();
  });
});

final certificateBuilderProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(certificatesRepositoryProvider).getCertificateBuilder();
});

final courseCertificatesProvider = FutureProvider.family<List<CertificateModel>, String>((ref, courseId) async {
  return ref.read(certificatesRepositoryProvider).getCourseCertificate(courseId);
});
