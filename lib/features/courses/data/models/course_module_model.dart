import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:gttp/features/courses/domain/entities/course_module.dart';
import 'package:gttp/features/courses/data/models/course_session_model.dart';

class CourseModuleRequirementModel {
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
  final String? submissionId;

  const CourseModuleRequirementModel({
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
    this.submissionId,
  });

  factory CourseModuleRequirementModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => ApiJsonParser.asString(v);

    final submission = ApiJsonParser.asMap(json['submission'] ?? json['student_submission']);
    final student = ApiJsonParser.asMap(json['student'] ?? submission?['student']);

    return CourseModuleRequirementModel(
      id: str(json['id'] ?? json['criteria_id'] ?? json['requirement_id']),
      title: str(json['title'] ?? json['name'] ?? json['criteria_title']),
      description: str(json['description'] ?? json['details'] ?? json['instruction']),
      status: str(json['submission_status'] ?? json['status'] ?? json['review_status'] ?? json['approval_status']).isEmpty
          ? 'not_started'
          : str(json['submission_status'] ?? json['status'] ?? json['review_status'] ?? json['approval_status']).toLowerCase(),
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
        json['submitted_at'] ?? json['uploaded_at'] ?? json['submitted_date'] ?? submission?['submitted_at'],
      ).isEmpty
          ? null
          : str(json['submitted_at'] ?? json['uploaded_at'] ?? json['submitted_date'] ?? submission?['submitted_at']),
      fileUrl: CourseAssetUrl.resolve(
        json['uploaded_file_url'] ??
            json['proof_url'] ??
            json['file_url'] ??
            json['file_path'] ??
            json['submission_url'] ??
            submission?['file_url'] ??
            submission?['file_path'],
      ),
      submissionId: str(json['submission_id'] ?? submission?['id'] ?? submission?['submission_id']).isEmpty 
          ? null 
          : str(json['submission_id'] ?? submission?['id'] ?? submission?['submission_id']),
    );
  }

  bool get isApproved {
    final s = status.toLowerCase();
    return s.contains('approved') || s == 'complete' || s == 'completed';
  }

  bool get isPending {
    final s = status.toLowerCase();
    return s.contains('pending') || s.contains('awaiting') || s.contains('review') || s.contains('submitted');
  }

  CourseModuleRequirement toEntity() {
    return CourseModuleRequirement(
      id: id,
      title: title,
      description: description,
      status: status,
      needsAdminApproval: needsAdminApproval,
      studentName: studentName,
      rollNo: rollNo,
      className: className,
      submittedAt: submittedAt,
      fileUrl: fileUrl,
      submissionId: submissionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'needs_admin_approval': needsAdminApproval,
      'student_name': studentName,
      'roll_no': rollNo,
      'class': className,
      'submitted_at': submittedAt,
      'file_url': fileUrl,
    };
  }
}

class CourseModuleMcqOptionModel {
  final String id;
  final String questionId;
  final String optionText;
  final bool isCorrect;
  final int order;

  const CourseModuleMcqOptionModel({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    this.order = 0,
  });

  factory CourseModuleMcqOptionModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => ApiJsonParser.asString(v);
    return CourseModuleMcqOptionModel(
      id: str(json['id']),
      questionId: str(json['question_id']),
      optionText: str(json['option_text']),
      isCorrect: ApiJsonParser.asBool(json['is_correct'] ?? json['isCorrect'] ?? json['correct'] ?? false),
      order: int.tryParse(str(json['order'])) ?? 0,
    );
  }

  CourseModuleMcqOption toEntity() {
    return CourseModuleMcqOption(
      id: id,
      questionId: questionId,
      optionText: optionText,
      isCorrect: isCorrect,
      order: order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect ? 1 : 0,
      'order': order,
    };
  }
}

class CourseModuleMcqQuestionModel {
  final String id;
  final String moduleId;
  final String questionText;
  final String? questionImage;
  final String? explanation;
  final int points;
  final int order;
  final List<CourseModuleMcqOptionModel> options;

  const CourseModuleMcqQuestionModel({
    required this.id,
    required this.moduleId,
    required this.questionText,
    this.questionImage,
    this.explanation,
    this.points = 1,
    this.order = 0,
    this.options = const [],
  });

  factory CourseModuleMcqQuestionModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => ApiJsonParser.asString(v);
    
    final optionsRaw = json['options'] ?? json['mcq_options'];
    final options = <CourseModuleMcqOptionModel>[];
    if (optionsRaw is List) {
      for (final item in optionsRaw) {
        if (item is Map) {
          options.add(CourseModuleMcqOptionModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return CourseModuleMcqQuestionModel(
      id: str(json['id']),
      moduleId: str(json['module_id']),
      questionText: str(json['question_text']),
      questionImage: CourseAssetUrl.resolve(json['question_image']),
      explanation: str(json['explanation']).isEmpty ? null : str(json['explanation']),
      points: int.tryParse(str(json['points'])) ?? 1,
      order: int.tryParse(str(json['order'])) ?? 0,
      options: options,
    );
  }

  CourseModuleMcqQuestion toEntity() {
    return CourseModuleMcqQuestion(
      id: id,
      moduleId: moduleId,
      questionText: questionText,
      questionImage: questionImage,
      explanation: explanation,
      points: points,
      order: order,
      options: options.map((o) => o.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'question_text': questionText,
      'question_image': questionImage,
      'explanation': explanation,
      'points': points,
      'order': order,
      'options': options.map((o) => o.toJson()).toList(),
    };
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
  final bool isExpired;
  final String? externalUrl;
  final String? materialUrl;
  final String? materialLabel;
  final List<CourseModuleRequirementModel> requirements;
  final List<CourseSessionModel> sessions;
  final int order;
  final int completedSubmissionsCount;
  final int pendingSubmissionsCount;

  final bool mcqEnabled;
  final List<CourseModuleMcqQuestionModel> mcqQuestions;

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
    this.isExpired = false,
    this.externalUrl,
    this.materialUrl,
    this.materialLabel,
    this.requirements = const [],
    this.sessions = const [],
    this.order = 0,
    this.completedSubmissionsCount = 0,
    this.pendingSubmissionsCount = 0,
    this.mcqEnabled = false,
    this.mcqQuestions = const [],
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
    final requirements = <CourseModuleRequirementModel>[];
    if (requirementsRaw is List) {
      for (final item in requirementsRaw) {
        if (item is Map) {
          requirements.add(
            CourseModuleRequirementModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final needsUpload = [
      'upload', 'report', 'assignment', 'test_case', 'industry_visit', 'poster'
    ].any((t) => type.contains(t));

    // Fallback for upload modules if backend didn't provide criterias
    if (requirements.isEmpty && needsUpload) {
      String desc = str(json['overview'] ?? json['instructions'] ?? 'Please upload your completed analysis or required document.');
      desc = desc.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      if (desc.isEmpty) desc = 'Please upload your completed analysis or required document.';

      String reqTitle = 'Upload your assignment/report *';
      if (type.contains('visit') || type.contains('poster') || type.contains('image')) {
        reqTitle = 'Upload your photo/image *';
      }

      requirements.add(
        CourseModuleRequirementModel(
          id: str(json['id'] ?? json['module_id'] ?? 'req_1'),
          title: reqTitle,
          description: desc,
          status: str(json['status']).isEmpty ? 'pending' : str(json['status']).toLowerCase(),
          needsAdminApproval: true,
          submittedAt: str(json['submitted_at']).isEmpty ? null : str(json['submitted_at']),
          fileUrl: CourseAssetUrl.resolve(json['proof_url'] ?? json['submission_url']),
        ),
      );
    }

    final sessionsRaw = json['sessions'] ?? json['submodules'];
    final sessions = <CourseSessionModel>[];
    if (sessionsRaw is List) {
      for (final item in sessionsRaw) {
        if (item is Map) {
          sessions.add(
            CourseSessionModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final mcqQuestionsRaw = json['mcq_questions'];
    final mcqQuestions = <CourseModuleMcqQuestionModel>[];
    if (mcqQuestionsRaw is List) {
      for (final item in mcqQuestionsRaw) {
        if (item is Map) {
          mcqQuestions.add(
            CourseModuleMcqQuestionModel.fromJson(Map<String, dynamic>.from(item)),
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
      isExpired: _checkIfExpired(str(json['deadline_date'] ?? json['due_date'] ?? json['dueDate'])),
      externalUrl: str(json['external_url'] ?? json['externalUrl']).isEmpty
          ? null
          : str(json['external_url'] ?? json['externalUrl']),
      materialUrl: CourseAssetUrl.resolve(json['file_path'] ?? json['material_url'] ?? json['file_url']),
      materialLabel: str(json['material_label']).isEmpty ? 'Guidelines Document' : str(json['material_label']),
      requirements: requirements,
      sessions: sessions,
      order: int.tryParse(str(json['order'])) ?? index,
      completedSubmissionsCount: int.tryParse(str(json['completed_submissions_count'] ?? json['completed_submissions'] ?? json['completed_count'])) ?? 0,
      pendingSubmissionsCount: int.tryParse(str(json['pending_submissions_count'] ?? json['pending_submissions'] ?? json['pending_count'])) ?? 0,
      mcqEnabled: ApiJsonParser.asBool(json['mcq_enabled'] ?? json['mcqEnabled']),
      mcqQuestions: mcqQuestions,
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

  static bool _checkIfExpired(String raw) {
    if (raw.isEmpty) return false;
    try {
      final dt = DateTime.parse(raw);
      // Only expired if the deadline is entirely in the past (start of the next day)
      return dt.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    } catch (_) {
      return false;
    }
  }

  CourseModule toEntity() {
    return CourseModule(
      id: id,
      courseId: courseId,
      title: title,
      type: type,
      typeLabel: typeLabel,
      durationHours: durationHours,
      dueDate: dueDate,
      tags: tags,
      isCompleted: isCompleted,
      isSequential: isSequential,
      isLocked: isLocked,
      isExpired: isExpired,
      externalUrl: externalUrl,
      materialUrl: materialUrl,
      materialLabel: materialLabel,
      requirements: requirements.map((r) => r.toEntity()).toList(),
      sessions: sessions.map((s) => s.toEntity()).toList(),
      order: order,
      completedSubmissionsCount: completedSubmissionsCount,
      pendingSubmissionsCount: pendingSubmissionsCount,
      mcqEnabled: mcqEnabled,
      mcqQuestions: mcqQuestions.map((q) => q.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'type': type,
      'typeLabel': typeLabel,
      'duration_hours': durationHours,
      'due_date': dueDate,
      'tags': tags,
      'is_completed': isCompleted,
      'is_sequential': isSequential,
      'isLocked': isLocked,
      'isExpired': isExpired,
      'external_url': externalUrl,
      'material_url': materialUrl,
      'material_label': materialLabel,
      'requirements': requirements.map((r) => r.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'order': order,
      'completed_submissions_count': completedSubmissionsCount,
      'pending_submissions_count': pendingSubmissionsCount,
      'mcq_enabled': mcqEnabled,
      'mcq_questions': mcqQuestions.map((q) => q.toJson()).toList(),
    };
  }
}
