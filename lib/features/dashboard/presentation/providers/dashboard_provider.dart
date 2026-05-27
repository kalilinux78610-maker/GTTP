import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:gttp/features/dashboard/data/repositories/dashboard_repository_impl.dart';

final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    if (ref.read(isOnlineProvider)) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(timer.cancel);

  final repository = ref.read(dashboardRepositoryProvider);
  return repository.getDashboardData();
});
