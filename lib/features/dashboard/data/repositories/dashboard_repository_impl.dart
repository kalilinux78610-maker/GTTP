import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/auth/user_profile_sync.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:gttp/core/cache/cache_service.dart';
import 'package:gttp/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.read(dashboardRemoteDataSourceProvider),
    ref.read(secureStorageProvider),
  );
});

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  DashboardRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<DashboardModel> getDashboardData() async {
    const cacheKey = 'dashboard_cache';
    try {
      final raw = await _remoteDataSource.fetchDashboardResponse();
      try {
        await UserProfileSync.mergeFromApiResponse(_storage, raw);
      } catch (_) {}
      final data = await _remoteDataSource.getDashboardData(preloadedResponse: raw);
      await CacheService.instance.put(cacheKey, data.toJson());
      return data;
    } catch (_) {
      final cachedJson = CacheService.instance.get<Map<String, dynamic>>(
        cacheKey,
        fromJson: (json) => json,
      );
      if (cachedJson != null) return DashboardModel.fromJson(cachedJson);
      rethrow;
    }
  }
}
