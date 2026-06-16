import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:gttp/features/courses/domain/entities/course_session.dart';

class CourseSessionModel {
  final String id;
  final String title;
  final String? description;
  final String? contentType;
  final String? deliveryMode;
  final String? monthLabel;
  final String? startDate;
  final String? endDate;
  final String? submissionDeadline;
  final bool isCompleted;
  final String? fileUrl;

  const CourseSessionModel({
    required this.id,
    required this.title,
    this.description,
    this.contentType,
    this.deliveryMode,
    this.monthLabel,
    this.startDate,
    this.endDate,
    this.submissionDeadline,
    this.isCompleted = false,
    this.fileUrl,
  });

  factory CourseSessionModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => ApiJsonParser.asString(v);
    
    return CourseSessionModel(
      id: str(json['id'] ?? json['session_id'] ?? json['submodule_id']),
      title: str(json['title'] ?? json['name'] ?? json['session_title']),
      description: str(json['description'] ?? json['details']).isEmpty ? null : str(json['description'] ?? json['details']),
      contentType: str(json['content_type'] ?? json['type']).isEmpty ? null : str(json['content_type'] ?? json['type']),
      deliveryMode: str(json['delivery_mode'] ?? json['mode']).isEmpty ? null : str(json['delivery_mode'] ?? json['mode']),
      monthLabel: str(json['month_label'] ?? json['month']).isEmpty ? null : str(json['month_label'] ?? json['month']),
      startDate: str(json['start_date'] ?? json['startDate']).isEmpty ? null : str(json['start_date'] ?? json['startDate']),
      endDate: str(json['end_date'] ?? json['endDate']).isEmpty ? null : str(json['end_date'] ?? json['endDate']),
      submissionDeadline: str(json['submission_deadline'] ?? json['deadline']).isEmpty ? null : str(json['submission_deadline'] ?? json['deadline']),
      isCompleted: ApiJsonParser.asBool(json['is_completed'] ?? json['isCompleted'] ?? json['completed']),
      fileUrl: CourseAssetUrl.resolve(
        json['file_url'] ??
            json['file_path'] ??
            json['material_url'] ??
            json['url'],
      ),
    );
  }

  CourseSession toEntity() {
    return CourseSession(
      id: id,
      title: title,
      description: description,
      contentType: contentType,
      deliveryMode: deliveryMode,
      monthLabel: monthLabel,
      startDate: startDate,
      endDate: endDate,
      submissionDeadline: submissionDeadline,
      isCompleted: isCompleted,
      fileUrl: fileUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content_type': contentType,
      'delivery_mode': deliveryMode,
      'month_label': monthLabel,
      'start_date': startDate,
      'end_date': endDate,
      'submission_deadline': submissionDeadline,
      'is_completed': isCompleted,
      'file_url': fileUrl,
    };
  }
}
