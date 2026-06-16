import 'package:gttp/features/courses/domain/entities/course_module.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String htmlDescription;
  final String? thumbnailUrl;
  final String? instructor;
  final String? duration;
  final String? level;
  final String? startDate;
  final String? endDate;
  final String? enrollmentType;
  final String? status;
  final String? passPercentage;
  final bool isEnrollable;
  final bool isEnrolled;
  final int? progressPercent;
  final String? pdfUrl;
  final List<CourseModule> modules;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.htmlDescription = '',
    this.thumbnailUrl,
    this.instructor,
    this.duration,
    this.level,
    this.startDate,
    this.endDate,
    this.enrollmentType,
    this.status,
    this.passPercentage,
    this.isEnrollable = false,
    this.isEnrolled = false,
    this.progressPercent,
    this.pdfUrl,
    this.modules = const [],
  });

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? htmlDescription,
    String? thumbnailUrl,
    String? instructor,
    String? duration,
    String? level,
    String? startDate,
    String? endDate,
    String? enrollmentType,
    String? status,
    String? passPercentage,
    bool? isEnrollable,
    bool? isEnrolled,
    int? progressPercent,
    String? pdfUrl,
    List<CourseModule>? modules,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      htmlDescription: htmlDescription ?? this.htmlDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructor: instructor ?? this.instructor,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      enrollmentType: enrollmentType ?? this.enrollmentType,
      status: status ?? this.status,
      passPercentage: passPercentage ?? this.passPercentage,
      isEnrollable: isEnrollable ?? this.isEnrollable,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      progressPercent: progressPercent ?? this.progressPercent,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      modules: modules ?? this.modules,
    );
  }
}
