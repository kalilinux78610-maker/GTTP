import 'package:gttp/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/domain/repositories/reports_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.read(reportsRemoteDataSourceProvider));
});

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remoteDataSource;

  ReportsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ReportModel>> getFlaggedReports() {
    return _remoteDataSource.getFlaggedReports();
  }

  @override
  Future<ReportModel> getReportDetail(String id) {
    return _remoteDataSource.getReportDetail(id);
  }

  @override
  Future<void> overrideReport({required String id, required String comments}) {
    return _remoteDataSource.overrideReport(id: id, comments: comments);
  }

  @override
  Future<void> resolveReport(String id) {
    return _remoteDataSource.resolveReport(id);
  }
}
