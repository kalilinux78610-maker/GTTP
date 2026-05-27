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
  final bool isPinned;
  final bool isRead;

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
    this.isPinned = false,
    this.isRead = false,
  });

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

    return NoticeModel(
      id: getString(['id', 'notice_id', 'noticeId', 'notification_id']),
      title: getString(['title', 'subject', 'heading', 'notice_title']),
      content: getString(['content', 'body', 'message', 'description', 'text']),
      category: getString(['category', 'type', 'notice_type', 'noticeType']),
      priority: getString(['priority', 'importance', 'level']),
      authorName: getString(['author', 'author_name', 'authorName', 'posted_by', 'postedBy', 'created_by']),
      createdAt: getString(['created_at', 'createdAt', 'date', 'posted_at', 'published_at']),
      attachmentUrl: tryString(json['attachment_url'] ?? json['attachment'] ?? json['file_url']),
      expiryDate: tryString(json['expiry_date'] ?? json['expires_at'] ?? json['valid_until']),
      targetAudience: tryString(json['target_audience'] ?? json['targetAudience'] ?? json['target']),
      isPinned: getBool(['is_pinned', 'isPinned', 'pinned', 'sticky']),
      isRead: getBool(['is_read', 'isRead', 'read']),
    );
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
