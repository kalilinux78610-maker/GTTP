import 'package:gttp/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/data/models/student_progress_model.dart';
import 'package:gttp/features/reports/domain/repositories/reports_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.read(reportsRemoteDataSourceProvider));
});

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remoteDataSource;

  ReportsRepositoryImpl(this._remoteDataSource);

  @override
  Future<StudentProgressModel> getStudentProgress({String? studentId}) {
    return _remoteDataSource.getStudentProgressReports(studentId: studentId);
  }

  @override
  Future<List<ReportModel>> getProgressReports() {
    return _remoteDataSource.getProgressReports();
  }

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

  @override
  Future<void> approveReport(String submissionId, String nextStatus) {
    return _remoteDataSource.approveReport(submissionId, nextStatus);
  }

  @override
  Future<void> rejectReport(String submissionId, {String? reason}) {
    return _remoteDataSource.rejectReport(submissionId, reason: reason);
  }

  @override
  Future<void> submitReport({
    String? courseId,
    String? moduleId,
    String? submoduleId,
    required String activityTitle,
    required String description,
    required ReportCategory category,
    String? fileName,
    List<int>? fileBytes,
  }) {
    return _remoteDataSource.submitReport(
      courseId: courseId,
      moduleId: moduleId,
      submoduleId: submoduleId,
      activityTitle: activityTitle,
      description: description,
      category: category,
      fileName: fileName,
      fileBytes: fileBytes,
    );
  }
}
