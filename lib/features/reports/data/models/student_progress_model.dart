import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/courses/data/models/course_module_model.dart';

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
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;

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
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
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
      dateOfBirth: ApiJsonParser.tryString(json['date_of_birth']),
      gender: ApiJsonParser.tryString(json['gender']),
      bloodGroup: ApiJsonParser.tryString(json['blood_group']),
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
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'blood_group': bloodGroup,
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
  final List<StudentModuleModel> submodules;
  final String type;
  final String typeLabel;
  final String? deliveryMode;
  final String? deliveryModeLabel;
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
  final String status;
  final String? submissionId;
  final String? proofUrl;
  final String? submittedAt;
  final List<CourseModuleMcqQuestionModel> mcqQuestions;
  final List<CourseModuleRequirementModel> criterias;

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
    this.deliveryMode,
    this.deliveryModeLabel,
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
    this.status = 'pending',
    this.submissionId,
    this.proofUrl,
    this.submittedAt,
    this.mcqQuestions = const [],
    this.criterias = const [],
  });

  factory StudentModuleModel.fromJson(Map<String, dynamic> json) {
    return StudentModuleModel(
      id: ApiJsonParser.asInt(json['id']),
      courseId: ApiJsonParser.asString(json['course_id'] ?? json['module_id']),
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
      submodules: () {
        final data = json['submodules'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => StudentModuleModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return const <StudentModuleModel>[];
      }(),
      type: ApiJsonParser.asString(json['type']),
      typeLabel: ApiJsonParser.asString(json['type_label']),
      deliveryMode: ApiJsonParser.tryString(json['delivery_mode']),
      deliveryModeLabel: ApiJsonParser.tryString(json['delivery_mode_label']),
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
      status: ApiJsonParser.asString(json['status']).isEmpty ? 'pending' : ApiJsonParser.asString(json['status']),
      submissionId: ApiJsonParser.tryString(json['submission_id']),
      proofUrl: ApiJsonParser.tryString(json['proof_url']),
      submittedAt: ApiJsonParser.tryString(json['submitted_at']),
      mcqQuestions: () {
        final raw = json['mcq_questions'];
        if (raw is List) {
          return raw.whereType<Map>().map((e) => CourseModuleMcqQuestionModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
        return const <CourseModuleMcqQuestionModel>[];
      }(),
      criterias: () {
        final raw = json['criterias'];
        if (raw is List) {
          return raw.whereType<Map>().map((e) => CourseModuleRequirementModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
        return const <CourseModuleRequirementModel>[];
      }(),
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
      'submodules': submodules.map((e) => e.toJson()).toList(),
      'type': type,
      'type_label': typeLabel,
      'delivery_mode': deliveryMode,
      'delivery_mode_label': deliveryModeLabel,
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
      'status': status,
      'submission_id': submissionId,
      'proof_url': proofUrl,
      'submitted_at': submittedAt,
      'mcq_questions': mcqQuestions.map((e) => e.toJson()).toList(),
      'criterias': criterias.map((e) => e.toJson()).toList(),
    };
  }
}
