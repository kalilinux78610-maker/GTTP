import 'package:gttp/core/network/api_json_parser.dart';

class StudentProgressModel {
  final StudentDetailsModel student;
  final List<StudentCourseProgressModel> courses;

  const StudentProgressModel({
    required this.student,
    required this.courses,
  });

  factory StudentProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentProgressModel(
      student: StudentDetailsModel.fromJson(json['student'] ?? {}),
      courses: () {
        final data = json['courses'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => StudentCourseProgressModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return const <StudentCourseProgressModel>[];
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'courses': courses.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentDetailsModel {
  final int id;
  final String name;
  final String? image;
  final String? instituteType;
  final String? schoolName;
  final String? rollNumber;
  final String? admissionNumber;
  final String? studentClass;
  final String? section;
  final String? program;
  final String? department;
  final String? semester;
  final String? academicYear;

  const StudentDetailsModel({
    required this.id,
    required this.name,
    this.image,
    this.instituteType,
    this.schoolName,
    this.rollNumber,
    this.admissionNumber,
    this.studentClass,
    this.section,
    this.program,
    this.department,
    this.semester,
    this.academicYear,
  });

  factory StudentDetailsModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailsModel(
      id: ApiJsonParser.asInt(json['id']),
      name: ApiJsonParser.asString(json['name']),
      image: ApiJsonParser.tryString(json['image']),
      instituteType: ApiJsonParser.tryString(json['institute_type']),
      schoolName: ApiJsonParser.tryString(json['school_name']),
      rollNumber: ApiJsonParser.tryString(json['roll_number']),
      admissionNumber: ApiJsonParser.tryString(json['admission_number']),
      studentClass: ApiJsonParser.tryString(json['class']),
      section: ApiJsonParser.tryString(json['section']),
      program: ApiJsonParser.tryString(json['program']),
      department: ApiJsonParser.tryString(json['department']),
      semester: ApiJsonParser.tryString(json['semester']),
      academicYear: ApiJsonParser.tryString(json['academic_year']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'institute_type': instituteType,
      'school_name': schoolName,
      'roll_number': rollNumber,
      'admission_number': admissionNumber,
      'class': studentClass,
      'section': section,
      'program': program,
      'department': department,
      'semester': semester,
      'academic_year': academicYear,
    };
  }
}

class StudentCourseProgressModel {
  final int id;
  final String title;
  final int progressPercentage;
  final List<StudentModuleModel> modules;

  const StudentCourseProgressModel({
    required this.id,
    required this.title,
    required this.progressPercentage,
    required this.modules,
  });

  factory StudentCourseProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentCourseProgressModel(
      id: ApiJsonParser.asInt(json['id']),
      title: ApiJsonParser.asString(json['title']),
      progressPercentage: ApiJsonParser.asInt(json['progress_percentage']),
      modules: () {
        final data = json['modules'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => StudentModuleModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return const <StudentModuleModel>[];
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'progress_percentage': progressPercentage,
      'modules': modules.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentModuleModel {
  final int id;
  final String courseId;
  final String title;
  final String order;
  final bool useSubmodules;
  final String? durationHours;
  final bool isSequential;
  final String? scheduledFrom;
  final String? scheduledTo;
  final String? scheduledMonth;
  final String? deadlineDate;
  final String? reminderDaysBefore;
  final bool isCompleted;
  final List<dynamic> submodules; // Can be typed later if needed
  final String type;
  final String typeLabel;
  final String? overview;
  final String? externalUrl;
  final String? filePath;
  final String? linkVisibleTime;
  final bool requiresProofUpload;
  final bool mcqEnabled;
  final String? mcqPassPercent;
  final String? mcqMaxAttempts;
  final bool mcqShuffle;
  final String? mcqTimeLimitMinutes;
  final String? mcqShowAnswers;

  const StudentModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    required this.useSubmodules,
    this.durationHours,
    required this.isSequential,
    this.scheduledFrom,
    this.scheduledTo,
    this.scheduledMonth,
    this.deadlineDate,
    this.reminderDaysBefore,
    required this.isCompleted,
    required this.submodules,
    required this.type,
    required this.typeLabel,
    this.overview,
    this.externalUrl,
    this.filePath,
    this.linkVisibleTime,
    required this.requiresProofUpload,
    required this.mcqEnabled,
    this.mcqPassPercent,
    this.mcqMaxAttempts,
    required this.mcqShuffle,
    this.mcqTimeLimitMinutes,
    this.mcqShowAnswers,
  });

  factory StudentModuleModel.fromJson(Map<String, dynamic> json) {
    return StudentModuleModel(
      id: ApiJsonParser.asInt(json['id']),
      courseId: ApiJsonParser.asString(json['course_id']),
      title: ApiJsonParser.asString(json['title']),
      order: ApiJsonParser.asString(json['order']),
      useSubmodules: ApiJsonParser.asBool(json['use_submodules']),
      durationHours: ApiJsonParser.tryString(json['duration_hours']),
      isSequential: ApiJsonParser.asBool(json['is_sequential']),
      scheduledFrom: ApiJsonParser.tryString(json['scheduled_from']),
      scheduledTo: ApiJsonParser.tryString(json['scheduled_to']),
      scheduledMonth: ApiJsonParser.tryString(json['scheduled_month']),
      deadlineDate: ApiJsonParser.tryString(json['deadline_date']),
      reminderDaysBefore: ApiJsonParser.tryString(json['reminder_days_before']),
      isCompleted: ApiJsonParser.asBool(json['is_completed']),
      submodules: json['submodules'] as List<dynamic>? ?? const [],
      type: ApiJsonParser.asString(json['type']),
      typeLabel: ApiJsonParser.asString(json['type_label']),
      overview: ApiJsonParser.tryString(json['overview']),
      externalUrl: ApiJsonParser.tryString(json['external_url']),
      filePath: ApiJsonParser.tryString(json['file_path']),
      linkVisibleTime: ApiJsonParser.tryString(json['link_visible_time']),
      requiresProofUpload: ApiJsonParser.asBool(json['requires_proof_upload']),
      mcqEnabled: ApiJsonParser.asBool(json['mcq_enabled']),
      mcqPassPercent: ApiJsonParser.tryString(json['mcq_pass_percent']),
      mcqMaxAttempts: ApiJsonParser.tryString(json['mcq_max_attempts']),
      mcqShuffle: ApiJsonParser.asBool(json['mcq_shuffle']),
      mcqTimeLimitMinutes: ApiJsonParser.tryString(json['mcq_time_limit_minutes']),
      mcqShowAnswers: ApiJsonParser.tryString(json['mcq_show_answers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'order': order,
      'use_submodules': useSubmodules,
      'duration_hours': durationHours,
      'is_sequential': isSequential,
      'scheduled_from': scheduledFrom,
      'scheduled_to': scheduledTo,
      'scheduled_month': scheduledMonth,
      'deadline_date': deadlineDate,
      'reminder_days_before': reminderDaysBefore,
      'is_completed': isCompleted,
      'submodules': submodules,
      'type': type,
      'type_label': typeLabel,
      'overview': overview,
      'external_url': externalUrl,
      'file_path': filePath,
      'link_visible_time': linkVisibleTime,
      'requires_proof_upload': requiresProofUpload,
      'mcq_enabled': mcqEnabled,
      'mcq_pass_percent': mcqPassPercent,
      'mcq_max_attempts': mcqMaxAttempts,
      'mcq_shuffle': mcqShuffle,
      'mcq_time_limit_minutes': mcqTimeLimitMinutes,
      'mcq_show_answers': mcqShowAnswers,
    };
  }
}
