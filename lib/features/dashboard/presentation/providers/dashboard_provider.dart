import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:gttp/features/dashboard/data/repositories/dashboard_repository_impl.dart';

final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  final repository = ref.read(dashboardRepositoryProvider);
  return repository.getDashboardData();
});
