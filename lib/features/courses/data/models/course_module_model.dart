import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';

class CourseModuleRequirement {
  final String id;
  final String title;
  final String description;
  final String status;
  final bool needsAdminApproval;
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? submittedAt;
  final String? fileUrl;

  const CourseModuleRequirement({
    required this.id,
    required this.title,
    required this.description,
    this.status = 'pending_review',
    this.needsAdminApproval = false,
    this.studentName,
    this.rollNo,
    this.className,
    this.submittedAt,
    this.fileUrl,
  });

  factory CourseModuleRequirement.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => ApiJsonParser.asString(v);

    final submission = ApiJsonParser.asMap(json['submission'] ?? json['student_submission']);
    final student = ApiJsonParser.asMap(json['student'] ?? submission?['student']);

    return CourseModuleRequirement(
      id: str(json['id'] ?? json['criteria_id'] ?? json['requirement_id']),
      title: str(json['title'] ?? json['name'] ?? json['criteria_title']),
      description: str(json['description'] ?? json['details'] ?? json['instruction']),
      status: str(json['status'] ?? json['review_status'] ?? json['approval_status']).isEmpty
          ? 'pending_review'
          : str(json['status'] ?? json['review_status'] ?? json['approval_status']).toLowerCase(),
      needsAdminApproval: ApiJsonParser.asBool(
        json['needs_admin_approval'] ?? json['requires_admin_approval'] ?? json['admin_approval'],
      ),
      studentName: str(
        json['student_name'] ??
            json['submitted_by'] ??
            student?['name'] ??
            submission?['student_name'],
      ).isEmpty
          ? null
          : str(
              json['student_name'] ??
                  json['submitted_by'] ??
                  student?['name'] ??
                  submission?['student_name'],
            ),
      rollNo: str(json['roll_no'] ?? json['roll_number'] ?? student?['roll_no']).isEmpty
          ? null
          : str(json['roll_no'] ?? json['roll_number'] ?? student?['roll_no']),
      className: str(json['class'] ?? json['class_name'] ?? student?['class']).isEmpty
          ? null
          : str(json['class'] ?? json['class_name'] ?? student?['class']),
      submittedAt: str(
        json['submitted_at'] ?? json['submitted_date'] ?? submission?['submitted_at'],
      ).isEmpty
          ? null
          : str(json['submitted_at'] ?? json['submitted_date'] ?? submission?['submitted_at']),
      fileUrl: CourseAssetUrl.resolve(
        json['file_url'] ??
            json['file_path'] ??
            json['submission_url'] ??
            submission?['file_url'] ??
            submission?['file_path'],
      ),
    );
  }

  bool get isApproved {
    final s = status.toLowerCase();
    return s.contains('approved') || s == 'complete' || s == 'completed';
  }

  bool get isPending {
    final s = status.toLowerCase();
    return s.contains('pending') || s.contains('awaiting') || s.contains('review');
  }
}

class CourseModuleModel {
  final String id;
  final String courseId;
  final String title;
  final String type;
  final String typeLabel;
  final String? durationHours;
  final String? dueDate;
  final List<String> tags;
  final bool isCompleted;
  final bool isSequential;
  final bool isLocked;
  final String? externalUrl;
  final String? materialUrl;
  final String? materialLabel;
  final List<CourseModuleRequirement> requirements;
  final int order;

  const CourseModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.typeLabel,
    this.durationHours,
    this.dueDate,
    this.tags = const [],
    this.isCompleted = false,
    this.isSequential = true,
    this.isLocked = false,
    this.externalUrl,
    this.materialUrl,
    this.materialLabel,
    this.requirements = const [],
    this.order = 0,
  });

  factory CourseModuleModel.fromJson(
    Map<String, dynamic> json, {
    int index = 0,
    bool lockedBySequence = false,
  }) {
    String str(dynamic v) => ApiJsonParser.asString(v);

    final type = str(json['type'] ?? json['module_type']).toLowerCase();
    final tags = _buildTags(json, type);

    final requirementsRaw = json['criterias'] ?? json['criteria'] ?? json['requirements'];
    final requirements = <CourseModuleRequirement>[];
    if (requirementsRaw is List) {
      for (final item in requirementsRaw) {
        if (item is Map) {
          requirements.add(
            CourseModuleRequirement.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return CourseModuleModel(
      id: str(json['id'] ?? json['module_id']).isEmpty ? 'module_$index' : str(json['id']),
      courseId: str(json['course_id'] ?? json['courseId']),
      title: str(json['title'] ?? json['name'] ?? json['module_name']),
      type: type,
      typeLabel: _humanizeType(type),
      durationHours: str(json['duration_hours'] ?? json['duration']).isEmpty
          ? null
          : str(json['duration_hours'] ?? json['duration']),
      dueDate: _formatApiDate(str(json['deadline_date'] ?? json['due_date'] ?? json['dueDate'])),
      tags: tags,
      isCompleted: ApiJsonParser.asBool(json['is_completed'] ?? json['isCompleted'] ?? json['completed']),
      isSequential: ApiJsonParser.asBool(json['is_sequential'] ?? json['isSequential'] ?? '1'),
      isLocked: lockedBySequence,
      externalUrl: str(json['external_url'] ?? json['externalUrl']).isEmpty
          ? null
          : str(json['external_url'] ?? json['externalUrl']),
      materialUrl: CourseAssetUrl.resolve(json['file_path'] ?? json['material_url'] ?? json['file_url']),
      materialLabel: str(json['material_label']).isEmpty ? 'Guidelines Document' : str(json['material_label']),
      requirements: requirements,
      order: int.tryParse(str(json['order'])) ?? index,
    );
  }

  String? get submissionStatus {
    if (requirements.isEmpty) return null;
    final pending = requirements.where((r) => r.isPending && !r.isApproved).length;
    if (pending > 0) return 'Submitted — Awaiting Review';
    if (requirements.every((r) => r.isApproved)) return 'All requirements approved';
    return null;
  }

  static List<String> _buildTags(Map<String, dynamic> json, String type) {
    final tags = <String>[];

    if (ApiJsonParser.asBool(json['requires_proof_upload'] ?? json['requiresProofUpload'])) {
      tags.add('Upload Required');
    }
    if (ApiJsonParser.asBool(json['mcq_enabled'] ?? json['mcqEnabled'])) {
      tags.add('Quiz');
    }
    if (ApiJsonParser.asBool(
      json['provide_completion_certificate'] ?? json['provideCompletionCertificate'],
    )) {
      tags.add('Certificate');
    }
    if (ApiJsonParser.asBool(
      json['provide_participation_certificate'] ?? json['provideParticipationCertificate'],
    )) {
      tags.add('Participation');
    }

    final rawTags = json['tags'] ?? json['badges'];
    if (rawTags is List) {
      for (final t in rawTags) {
        final label = ApiJsonParser.asString(t);
        if (label.isNotEmpty && !tags.contains(label)) tags.add(label);
      }
    }

    return tags.toSet().toList();
  }

  static String _humanizeType(String type) {
    if (type.isEmpty) return '';
    return type
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String? _formatApiDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
