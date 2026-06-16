class CourseSession {
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

  const CourseSession({
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

  CourseSession copyWith({
    String? id,
    String? title,
    String? description,
    String? contentType,
    String? deliveryMode,
    String? monthLabel,
    String? startDate,
    String? endDate,
    String? submissionDeadline,
    bool? isCompleted,
    String? fileUrl,
  }) {
    return CourseSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      monthLabel: monthLabel ?? this.monthLabel,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      submissionDeadline: submissionDeadline ?? this.submissionDeadline,
      isCompleted: isCompleted ?? this.isCompleted,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}
