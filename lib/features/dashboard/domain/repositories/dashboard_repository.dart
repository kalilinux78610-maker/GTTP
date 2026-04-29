import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboardData();
}
