import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/features/school_network/data/repositories/school_network_repository_impl.dart';
import '../../data/models/school_model.dart';

final schoolsProvider = StreamProvider<List<SchoolModel>>((ref) {
  // Auto-refresh every 5 minutes if online (repository cache handles dedup)
  final timer = Timer.periodic(const Duration(minutes: 5), (_) {
    if (ref.read(isOnlineProvider)) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(timer.cancel);

  return ref.read(schoolNetworkRepositoryProvider).watchSchools();
});

/// Call this to force a fresh load (clears cache + re-fetches).
void forceRefreshSchools(WidgetRef ref) {
  final repo = ref.read(schoolNetworkRepositoryProvider);
  if (repo is SchoolNetworkRepositoryImpl) {
    repo.clearCache();
  }
  ref.invalidate(schoolsProvider);
}

// Search query state
class SchoolSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final schoolSearchQueryProvider = NotifierProvider<SchoolSearchQueryNotifier, String>(() {
  return SchoolSearchQueryNotifier();
});

// Filtered schools based on search
final filteredSchoolsProvider = Provider<AsyncValue<List<SchoolModel>>>((ref) {
  final query = ref.watch(schoolSearchQueryProvider).toLowerCase().trim();
  final asyncSchools = ref.watch(schoolsProvider);

  return asyncSchools.whenData((schools) {
    if (query.isEmpty) return schools;
    return schools.where((school) {
      final nameMatches = school.title.toLowerCase().contains(query);
      final locationMatches = school.location.toLowerCase().contains(query);
      return nameMatches || locationMatches;
    }).toList();
  });
});
