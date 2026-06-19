import 'package:gttp/features/reports/data/models/report_model.dart';

import 'package:gttp/features/reports/data/models/student_progress_model.dart';

abstract class ReportsRepository {
  Future<StudentProgressModel> getStudentProgress({String? studentId});
  Future<List<ReportModel>> getProgressReports();
  Future<List<ReportModel>> getFlaggedReports();
  Future<ReportModel> getReportDetail(String id);
  Future<void> overrideReport({
    required String id,
    required String comments,
  });
  Future<void> resolveReport(String id);
  Future<void> approveReport(String submissionId, String nextStatus);
  Future<void> rejectReport(String submissionId, {String? reason});
  Future<void> submitReport({
    String? courseId,
    String? moduleId,
    String? submoduleId,
    required String activityTitle,
    required String description,
    required ReportCategory category,
    String? fileName,
    List<int>? fileBytes,
  });
}
