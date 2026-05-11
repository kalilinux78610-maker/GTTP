import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/school_network/data/repositories/school_network_repository_impl.dart';
import '../../data/models/school_model.dart';

final schoolsProvider = FutureProvider<List<SchoolModel>>((ref) async {
  return ref.read(schoolNetworkRepositoryProvider).getSchools();
});

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
