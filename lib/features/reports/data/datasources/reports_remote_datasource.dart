import 'package:flutter/foundation.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/data/models/student_progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/cache/sync_queue_service.dart';
import 'package:dio/dio.dart';

final reportsRemoteDataSourceProvider = Provider<ReportsRemoteDataSource>((
  ref,
) {
  return ReportsRemoteDataSource(ref.read(apiClientProvider));
});

class ReportsRemoteDataSource {
  final ApiClient _apiClient;

  ReportsRemoteDataSource(this._apiClient);

  // ─── Helper: try to parse a single JSON object → ReportModel ───────────
  ReportModel? _parseReport(Map<String, dynamic> json) {
    try {
      // Map common field name variants
      String str(List<String> keys, {String fallback = ''}) {
        for (final k in keys) {
          final v = json[k];
          if (v != null) return '$v';
        }
        return fallback;
      }

      final id = str(['id', 'report_id', 'reportId']);
      final submissionId = str([
        'submission_id',
        'submissionId',
        'code',
      ], fallback: id);
      final schoolName = str([
        'school_name',
        'schoolName',
        'school',
        'institute',
      ]);
      final activityTitle = str([
        'activity_title',
        'activityTitle',
        'title',
        'subject',
      ]);
      final reporterName = str([
        'reporter_name',
        'reporterName',
        'student_name',
        'studentName',
        'name',
      ]);
      final flagReason = str([
        'flag_reason',
        'flagReason',
        'reason',
        'remarks',
      ]);
      final description = str(['description', 'report', 'content', 'detail']);
      final flaggedBy = json['flagged_by'] ?? json['flaggedBy'];

      // Parse status
      final statusRaw = str(['status']).toLowerCase();
      final status =
          const {
            'pending': ReportStatus.pending,
            'completed': ReportStatus.completed,
            'flagged': ReportStatus.flagged,
            'overridden': ReportStatus.overridden,
            'rejected': ReportStatus.rejected,
            'resolved': ReportStatus.resolved,
          }[statusRaw] ??
          ReportStatus.pending;

      // Parse category
      final categoryRaw = str(['category', 'type']).toLowerCase();
      final category =
          const {
            'theory': ReportCategory.theory,
            'practical': ReportCategory.practical,
            'internship': ReportCategory.internship,
            'visits': ReportCategory.visits,
            'visit': ReportCategory.visits,
          }[categoryRaw] ??
          ReportCategory.theory;

      // Parse date
      DateTime createdAt = DateTime.now();
      final dateRaw = json['created_at'] ?? json['createdAt'] ?? json['date'];
      if (dateRaw != null) {
        createdAt = DateTime.tryParse('$dateRaw') ?? DateTime.now();
      }

      final groupCount = json['group_count'] ?? json['groupCount'];

      return ReportModel(
        id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
        submissionId: submissionId,
        schoolName: schoolName,
        activityTitle: activityTitle,
        reporterName: reporterName,
        flagReason: flagReason,
        description: description,
        category: category,
        status: status,
        createdAt: createdAt,
        flaggedBy: flaggedBy?.toString(),
        groupCount: groupCount is int
            ? groupCount
            : int.tryParse('${groupCount ?? ''}'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReportsDataSource] Failed to parse report item: $e');
      }
      return null;
    }
  }

  Future<List<ReportModel>> getProgressReports() async {
    try {
      final response = await _apiClient.get(
        '/reports/progress',
        requiresAuth: true,
      );

      List<dynamic> rawList = [];
      if (response['data'] is List) {
        rawList = response['data'] as List;
      } else if (response['reports'] is List) {
        rawList = response['reports'] as List;
      } else if (response.values.whereType<List>().isNotEmpty) {
        rawList = response.values.whereType<List>().first;
      }

      if (rawList.isNotEmpty) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(_parseReport)
            .whereType<ReportModel>()
            .toList();
      }

      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to fetch progress reports: $e');
    }
  }

  Future<StudentProgressModel> getStudentProgressReports({
    String? studentId,
  }) async {
    try {
      final endpoint = studentId != null
          ? '/reports/progress?studentId=$studentId'
          : '/reports/progress';
      final response = await _apiClient.get(endpoint, requiresAuth: true);

      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return StudentProgressModel.fromJson(data);
      }

      throw ApiException('Invalid response format for student progress.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to fetch student progress reports: $e');
    }
  }

  Future<List<ReportModel>> getFlaggedReports() async {
    try {
      // Try multiple possible endpoints
      final endpoints = [
        '/reports',
        '/reports/flagged',
        '/submissions',
        '/student-reports',
      ];

      for (final endpoint in endpoints) {
        try {
          final response = await _apiClient.get(endpoint, requiresAuth: true);

          if (kDebugMode) {
            debugPrint('[Reports] Trying endpoint: $endpoint');
            debugPrint(
              '[Reports] Raw response keys: ${response.keys.toList()}',
            );
          }

          List<dynamic> rawList = [];

          // Handle various response shapes
          if (response['data'] is List) {
            rawList = response['data'] as List;
          } else if (response['reports'] is List) {
            rawList = response['reports'] as List;
          } else if (response['items'] is List) {
            rawList = response['items'] as List;
          } else if (response['results'] is List) {
            rawList = response['results'] as List;
          } else if (response.values.whereType<List>().isNotEmpty) {
            // Take the first list value we find
            rawList = response.values.whereType<List>().first;
          }

          if (rawList.isNotEmpty) {
            final reports = rawList
                .whereType<Map<String, dynamic>>()
                .map(_parseReport)
                .whereType<ReportModel>()
                .toList();

            if (kDebugMode) {
              debugPrint(
                '[Reports] Parsed ${reports.length} reports from $endpoint',
              );
            }

            if (reports.isNotEmpty) return reports;
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[Reports] Endpoint $endpoint failed: $e');
          // Try next endpoint
        }
      }

      throw ApiException('Unable to fetch reports from API.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to fetch reports: $e');
    }
  }

  Future<ReportModel> getReportDetail(String id) async {
    try {
      final response = await _apiClient.get('/reports/$id', requiresAuth: true);
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        final model = _parseReport(data);
        if (model != null) return model;
      }
      throw ApiException('Report detail response format is invalid.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to fetch report detail: $e');
    }
  }

  Future<void> overrideReport({
    required String id,
    required String comments,
  }) async {
    try {
      await _apiClient.post(
        '/reports/$id/override',
        data: {'comments': comments},
        requiresAuth: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to override report: $e');
    }
  }

  Future<void> resolveReport(String id) async {
    try {
      await _apiClient.post('/reports/$id/resolve', requiresAuth: true);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to resolve report: $e');
    }
  }

  Future<void> approveReport(String submissionId, String targetStatus) async {
    try {
      await _apiClient.post(
        '/reports/approve/$submissionId',
        data: {'status': targetStatus},
        requiresAuth: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to approve report: $e');
    }
  }

  Future<void> rejectReport(String submissionId, {String? reason}) async {
    try {
      await _apiClient.post(
        '/reports/reject/$submissionId',
        data: reason != null ? {'reason': reason} : null,
        requiresAuth: true,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to reject report: $e');
    }
  }

  Future<void> submitReport({
    String? courseId,
    String? moduleId,
    String? submoduleId,
    required String activityTitle,
    required String description,
    required ReportCategory category,
    String? fileName,
    List<int>? fileBytes,
  }) async {
    try {
      final Map<String, dynamic> payloadData = {
        'course_id': ?courseId,
        'module_id': ?moduleId,
        'submodule_id': ?submoduleId,
        'activity_title': activityTitle,
        'description': description,
        'category': category.toString().split('.').last,
      };

      Object payload;
      if (fileBytes != null && fileName != null) {
        payloadData['attachment'] = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
        payload = FormData.fromMap(payloadData);
      } else {
        payload = payloadData;
      }

      await _apiClient.post(
        '/reports/submit',
        data: payload,
        requiresAuth: true,
      );
    } on ApiException catch (e) {
      // Check if it's a network/offline error
      if (e.statusCode == null ||
          e.message.contains('timeout') ||
          e.message.contains('connect')) {
        final payload = {
          'course_id': ?courseId,
          'module_id': ?moduleId,
          'submodule_id': ?submoduleId,
          'activity_title': activityTitle,
          'description': description,
          'category': category.toString().split('.').last,
        };

        await SyncQueueService.instance.enqueue('/reports/submit', payload);
        throw OfflineSavedException();
      }
      rethrow;
    } catch (e) {
      throw ApiException('Failed to submit report: $e');
    }
  }
}
