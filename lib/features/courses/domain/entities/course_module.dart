import 'package:gttp/features/courses/domain/entities/course_session.dart';

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

  bool get isApproved {
    final s = status.toLowerCase();
    return s.contains('approved') || s == 'complete' || s == 'completed';
  }

  bool get isPending {
    final s = status.toLowerCase();
    return s.contains('pending') || s.contains('awaiting') || s.contains('review');
  }
}

class CourseModule {
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
  final List<CourseSession> sessions;
  final int order;

  final bool mcqEnabled;
  final List<CourseModuleMcqQuestion> mcqQuestions;

  const CourseModule({
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
    this.sessions = const [],
    this.order = 0,
    this.mcqEnabled = false,
    this.mcqQuestions = const [],
  });

  String? get submissionStatus {
    if (requirements.isEmpty) return null;
    final pending = requirements.where((r) => r.isPending && !r.isApproved).length;
    if (pending > 0) return 'Submitted — Awaiting Review';
    if (requirements.every((r) => r.isApproved)) return 'All requirements approved';
    return null;
  }

  CourseModule copyWith({
    String? id,
    String? courseId,
    String? title,
    String? type,
    String? typeLabel,
    String? durationHours,
    String? dueDate,
    List<String>? tags,
    bool? isCompleted,
    bool? isSequential,
    bool? isLocked,
    String? externalUrl,
    String? materialUrl,
    String? materialLabel,
    List<CourseModuleRequirement>? requirements,
    List<CourseSession>? sessions,
    int? order,
    bool? mcqEnabled,
    List<CourseModuleMcqQuestion>? mcqQuestions,
  }) {
    return CourseModule(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      type: type ?? this.type,
      typeLabel: typeLabel ?? this.typeLabel,
      durationHours: durationHours ?? this.durationHours,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      isSequential: isSequential ?? this.isSequential,
      isLocked: isLocked ?? this.isLocked,
      externalUrl: externalUrl ?? this.externalUrl,
      materialUrl: materialUrl ?? this.materialUrl,
      materialLabel: materialLabel ?? this.materialLabel,
      requirements: requirements ?? this.requirements,
      sessions: sessions ?? this.sessions,
      order: order ?? this.order,
      mcqEnabled: mcqEnabled ?? this.mcqEnabled,
      mcqQuestions: mcqQuestions ?? this.mcqQuestions,
    );
  }
}

class CourseModuleMcqQuestion {
  final String id;
  final String moduleId;
  final String questionText;
  final String? questionImage;
  final String? explanation;
  final int points;
  final int order;
  final List<CourseModuleMcqOption> options;

  const CourseModuleMcqQuestion({
    required this.id,
    required this.moduleId,
    required this.questionText,
    this.questionImage,
    this.explanation,
    this.points = 1,
    this.order = 0,
    this.options = const [],
  });
}

class CourseModuleMcqOption {
  final String id;
  final String questionId;
  final String optionText;
  final bool isCorrect;
  final int order;

  const CourseModuleMcqOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    this.order = 0,
  });
}
