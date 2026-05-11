import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/data/repositories/reports_repository_impl.dart';

/// Provider for the list of flagged reports
final flaggedReportsProvider = AsyncNotifierProvider<FlaggedReportsNotifier, List<ReportModel>>(
  FlaggedReportsNotifier.new,
);

class FlaggedReportsNotifier extends AsyncNotifier<List<ReportModel>> {
  @override
  Future<List<ReportModel>> build() async {
    return ref.read(reportsRepositoryProvider).getFlaggedReports();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(reportsRepositoryProvider).getFlaggedReports(),
    );
  }

  Future<bool> resolveReport(String id) async {
    try {
      await ref.read(reportsRepositoryProvider).resolveReport(id);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> overrideReport(String id, String comments) async {
    try {
      await ref.read(reportsRepositoryProvider).overrideReport(id: id, comments: comments);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectReport(String id, {String? reason}) async {
    try {
      await ref.read(reportsRepositoryProvider).rejectReport(id, reason: reason);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for selected category filter
final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, ReportCategory?>(
  SelectedCategoryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<ReportCategory?> {
  @override
  ReportCategory? build() => null;
  void set(ReportCategory? category) => state = category;
}

/// Provider for selected status filter
final selectedStatusProvider = NotifierProvider<SelectedStatusNotifier, ReportStatus?>(
  SelectedStatusNotifier.new,
);

class SelectedStatusNotifier extends Notifier<ReportStatus?> {
  @override
  ReportStatus? build() => null;
  void set(ReportStatus? status) => state = status;
}

/// Provider for the filtered list of reports
final filteredReportsProvider = Provider<AsyncValue<List<ReportModel>>>((ref) {
  final reportsAsync = ref.watch(flaggedReportsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final status = ref.watch(selectedStatusProvider);

  return reportsAsync.whenData((reports) {
    return reports.where((report) {
      final matchesCategory = category == null || report.category == category;
      final matchesStatus = status == null || report.status == status;
      return matchesCategory && matchesStatus;
    }).toList();
  });
});

/// Provider for individual report detail
final reportDetailProvider = FutureProvider.family<ReportModel, String>((ref, id) {
  return ref.read(reportsRepositoryProvider).getReportDetail(id);
});
