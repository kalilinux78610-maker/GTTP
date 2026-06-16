class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String priority;
  final String authorName;
  final String createdAt;
  final String? attachmentUrl;
  final String? expiryDate;
  final String? targetAudience;
  final List<String> targetInstituteNames;
  final bool isGlobal;
  final bool isPinned;
  final bool isRead;
  final String? schoolId;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.priority,
    required this.authorName,
    required this.createdAt,
    this.attachmentUrl,
    this.expiryDate,
    this.targetAudience,
    this.targetInstituteNames = const [],
    this.isGlobal = false,
    this.isPinned = false,
    this.isRead = false,
    this.schoolId,
  });

  NoticeModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? priority,
    String? authorName,
    String? createdAt,
    String? attachmentUrl,
    String? expiryDate,
    String? targetAudience,
    List<String>? targetInstituteNames,
    bool? isGlobal,
    bool? isPinned,
    bool? isRead,
    String? schoolId,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      expiryDate: expiryDate ?? this.expiryDate,
      targetAudience: targetAudience ?? this.targetAudience,
      targetInstituteNames: targetInstituteNames ?? this.targetInstituteNames,
      isGlobal: isGlobal ?? this.isGlobal,
      isPinned: isPinned ?? this.isPinned,
      isRead: isRead ?? this.isRead,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    String? tryString(dynamic value) {
      if (value == null) return null;
      return value.toString().trim();
    }

    String getString(List<String> keys) {
      for (final key in keys) {
        final value = _getValueByPath(json, key);
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    bool getBool(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is bool) return value;
        if (value is String) {
          return value.toLowerCase() == 'true' || value == '1';
        }
        if (value is int) return value == 1;
      }
      return false;
    }

    final List<String> parsedInstitutes = [];
    if (json['institute_names'] is List) {
      parsedInstitutes.addAll((json['institute_names'] as List).map((e) => e.toString().trim()));
    } else if (json['institute_names'] is String) {
      final str = json['institute_names'] as String;
      if (str.isNotEmpty) {
        parsedInstitutes.addAll(str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      }
    } else if (json['school_name'] is String) {
      final str = json['school_name'] as String;
      if (str.isNotEmpty) {
        parsedInstitutes.addAll(str.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      }
    }

    return NoticeModel(
      id: getString(['id', 'notice_id', 'noticeId', 'notification_id']),
      title: getString(['title', 'subject', 'heading', 'notice_title']),
      content: getString(['content', 'body', 'message', 'description', 'text']),
      category: getString(['category', 'type', 'notice_type', 'noticeType']),
      priority: getString(['priority', 'importance', 'level']),
      authorName: getString(['author', 'author_name', 'authorName', 'posted_by', 'postedBy', 'created_by']),
      createdAt: getString(['created_at', 'createdAt', 'date', 'posted_at', 'published_at', 'publish_at']),
      attachmentUrl: tryString(json['attachment_url'] ?? json['attachment'] ?? json['file_url']),
      expiryDate: tryString(json['expiry_date'] ?? json['expires_at'] ?? json['valid_until']),
      targetAudience: _buildTargetAudience(json),
      targetInstituteNames: parsedInstitutes,
      isGlobal: getBool(['is_global', 'isGlobal', 'global']),
      isPinned: json['is_pinned'] == true || json['is_pinned'] == 1 || json['pinned'] == true || json['pinned'] == 1,
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['read_at'] != null,
      schoolId: tryString(json['school_id'] ?? json['schoolId'] ?? json['institute_id']),
    );
  }

  static String? _buildTargetAudience(Map<String, dynamic> json) {
    String? tryString(dynamic value) {
      if (value == null) return null;
      return value.toString().trim();
    }

    final audienceType = tryString(json['target_audience'] ?? json['targetAudience'] ?? json['target']);
    final targetClass = tryString(json['target_class']);
    final targetSection = tryString(json['target_section']);
    final targetProgram = tryString(json['target_program']);
    final targetDepartment = tryString(json['target_department']);
    final targetSemester = tryString(json['target_semester']);

    List<String> parts = [];
    
    if (targetClass != null && targetClass.isNotEmpty) parts.add(targetClass);
    if (targetSection != null && targetSection.isNotEmpty) parts.add(targetSection);
    if (targetProgram != null && targetProgram.isNotEmpty) parts.add(targetProgram);
    if (targetDepartment != null && targetDepartment.isNotEmpty) parts.add(targetDepartment);
    if (targetSemester != null && targetSemester.isNotEmpty) parts.add(targetSemester);

    if (parts.isNotEmpty) {
      return parts.join(', ');
    } else if (audienceType != null && audienceType.isNotEmpty) {
      if (audienceType.toLowerCase() == 'all') return 'All Members';
      return audienceType;
    }
    return null;
  }

  static dynamic _getValueByPath(Map<String, dynamic> json, String path) {
    if (!path.contains('.')) return json[path];
    
    dynamic current = json;
    for (final part in path.split('.')) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  bool get isHighPriority => priority.toLowerCase() == 'high' || priority.toLowerCase() == 'urgent';
  bool get isAnnouncement => category.toLowerCase() == 'announcement';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'priority': priority,
      'authorName': authorName,
      'createdAt': createdAt,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (targetAudience != null) 'targetAudience': targetAudience,
      'isPinned': isPinned,
      'isRead': isRead,
    };
  }
}
