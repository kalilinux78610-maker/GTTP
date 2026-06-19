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
  final bool requiresProofUpload;
  final String? instructions;
  final String? referenceMaterialUrl;
  final String? videoUrl;
  final String? linkVisibleFrom;

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
    this.requiresProofUpload = true,
    this.instructions,
    this.referenceMaterialUrl,
    this.videoUrl,
    this.linkVisibleFrom,
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
    bool? requiresProofUpload,
    String? instructions,
    String? referenceMaterialUrl,
    String? videoUrl,
    String? linkVisibleFrom,
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
      requiresProofUpload: requiresProofUpload ?? this.requiresProofUpload,
      instructions: instructions ?? this.instructions,
      referenceMaterialUrl: referenceMaterialUrl ?? this.referenceMaterialUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      linkVisibleFrom: linkVisibleFrom ?? this.linkVisibleFrom,
    );
  }
}
