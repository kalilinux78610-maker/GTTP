import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:gttp/features/courses/domain/entities/course_session.dart';
import 'package:gttp/features/courses/data/models/course_module_model.dart';

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
  final bool requiresProofUpload;
  final String? instructions;
  final String? referenceMaterialUrl;
  final String? videoUrl;
  final String? linkVisibleFrom;
  final String? submissionStatus;
  final List<dynamic> mcqQuestions;

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
    this.requiresProofUpload = true,
    this.instructions,
    this.referenceMaterialUrl,
    this.videoUrl,
    this.linkVisibleFrom,
    this.submissionStatus,
    this.mcqQuestions = const [],
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
            json['url'] ??
            json['external_url'],
      ),
      requiresProofUpload: json.containsKey('requires_proof_upload') 
          ? ApiJsonParser.asBool(json['requires_proof_upload'])
          : json.containsKey('requiresProofUpload')
              ? ApiJsonParser.asBool(json['requiresProofUpload'])
              : true, // Default to true if not provided for safety
      instructions: str(json['instructions'] ?? json['activity_instructions'] ?? json['instruction'] ?? json['overview'] ?? json['description'] ?? json['details']).isEmpty ? null : str(json['instructions'] ?? json['activity_instructions'] ?? json['instruction'] ?? json['overview'] ?? json['description'] ?? json['details']),
      referenceMaterialUrl: CourseAssetUrl.resolve(json['reference_material_url'] ?? json['material_url']),
      videoUrl: str(json['video_url'] ?? json['external_url']).isEmpty ? null : str(json['video_url'] ?? json['external_url']),
      linkVisibleFrom: str(json['link_visible_from']).isEmpty ? null : str(json['link_visible_from']),
      submissionStatus: str(json['submission_status']).isEmpty ? null : str(json['submission_status']),
      mcqQuestions: (json['mcq_questions'] as List<dynamic>?)?.map((q) => CourseModuleMcqQuestionModel.fromJson(q as Map<String, dynamic>)).toList() ?? [],
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
      requiresProofUpload: requiresProofUpload,
      instructions: instructions,
      referenceMaterialUrl: referenceMaterialUrl,
      videoUrl: videoUrl,
      linkVisibleFrom: linkVisibleFrom,
      submissionStatus: submissionStatus,
      mcqQuestions: mcqQuestions.whereType<CourseModuleMcqQuestionModel>().map((q) => q.toEntity()).toList(),
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
      'requires_proof_upload': requiresProofUpload,
      'instructions': instructions,
      'reference_material_url': referenceMaterialUrl,
      'video_url': videoUrl,
      'link_visible_from': linkVisibleFrom,
    };
  }
}
