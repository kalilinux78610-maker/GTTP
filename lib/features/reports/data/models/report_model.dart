import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_model.freezed.dart';
part 'report_model.g.dart';

@freezed
abstract class ReportModel with _$ReportModel {
  const factory ReportModel({
    required String id,
    required String submissionId,
    required String schoolName,
    required String activityTitle,
    required String flagReason,
    @Default(ReportCategory.theory) ReportCategory category,
    @Default(ReportStatus.pending) ReportStatus status,
    required DateTime createdAt,
    required String description,
    required String reporterName,
    String? flaggedBy,
    int? groupCount,
    String? overrideComments,
  }) = _ReportModel;

  factory ReportModel.fromJson(Map<String, dynamic> json) => _$ReportModelFromJson(json);
}

enum ReportStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('flagged')
  flagged,
  @JsonValue('overridden')
  overridden,
  @JsonValue('rejected')
  rejected,
  @JsonValue('resolved')
  resolved,
}

enum ReportCategory {
  @JsonValue('theory')
  theory,
  @JsonValue('practical')
  practical,
  @JsonValue('internship')
  internship,
  @JsonValue('visits')
  visits,
}
