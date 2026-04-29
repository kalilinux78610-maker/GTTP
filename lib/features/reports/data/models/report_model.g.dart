// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => _ReportModel(
  id: json['id'] as String,
  submissionId: json['submissionId'] as String,
  schoolName: json['schoolName'] as String,
  activityTitle: json['activityTitle'] as String,
  flagReason: json['flagReason'] as String,
  category:
      $enumDecodeNullable(_$ReportCategoryEnumMap, json['category']) ??
      ReportCategory.theory,
  status:
      $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
      ReportStatus.pending,
  createdAt: DateTime.parse(json['createdAt'] as String),
  description: json['description'] as String,
  reporterName: json['reporterName'] as String,
  flaggedBy: json['flaggedBy'] as String?,
  groupCount: (json['groupCount'] as num?)?.toInt(),
  overrideComments: json['overrideComments'] as String?,
);

Map<String, dynamic> _$ReportModelToJson(_ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submissionId': instance.submissionId,
      'schoolName': instance.schoolName,
      'activityTitle': instance.activityTitle,
      'flagReason': instance.flagReason,
      'category': _$ReportCategoryEnumMap[instance.category]!,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'reporterName': instance.reporterName,
      'flaggedBy': instance.flaggedBy,
      'groupCount': instance.groupCount,
      'overrideComments': instance.overrideComments,
    };

const _$ReportCategoryEnumMap = {
  ReportCategory.theory: 'theory',
  ReportCategory.practical: 'practical',
  ReportCategory.internship: 'internship',
  ReportCategory.visits: 'visits',
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'pending',
  ReportStatus.flagged: 'flagged',
  ReportStatus.overridden: 'overridden',
  ReportStatus.approved: 'approved',
  ReportStatus.resolved: 'resolved',
};
