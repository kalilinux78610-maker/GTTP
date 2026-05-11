import 'package:gttp/features/reports/data/models/report_model.dart';

abstract class ReportsRepository {
  Future<List<ReportModel>> getFlaggedReports();
  Future<ReportModel> getReportDetail(String id);
  Future<void> overrideReport({
    required String id,
    required String comments,
  });
  Future<void> resolveReport(String id);
  Future<void> rejectReport(String id, {String? reason});
}
