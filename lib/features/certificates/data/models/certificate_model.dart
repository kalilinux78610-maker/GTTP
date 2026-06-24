class CertificateModel {
  final String id;
  final String title;
  final String studentName;
  final String schoolName;
  final String courseName;
  final String issuedDate;
  final String expiryDate;
  final String status;
  final String? certificateUrl;
  final String? description;
  final String? type;

  CertificateModel({
    required this.id,
    required this.title,
    required this.studentName,
    required this.schoolName,
    required this.courseName,
    required this.issuedDate,
    required this.expiryDate,
    required this.status,
    this.certificateUrl,
    this.description,
    this.type,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
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

    return CertificateModel(
      id: getString(['id', 'certificate_id', 'certificateId', 'cert_id']),
      title: getString(['title', 'name', 'certificate_name', 'certificateTitle', 'type']),
      studentName: getString(['student_name', 'studentName', 'student', 'user_name', 'userName']),
      schoolName: getString(['school_name', 'schoolName', 'school', 'institute']),
      courseName: getString(['course_name', 'courseName', 'course', 'program']),
      issuedDate: getString(['issued_date', 'issuedDate', 'date', 'created_at', 'createdAt', 'issue_date']),
      expiryDate: getString(['expiry_date', 'expiryDate', 'expires_at', 'expiresAt', 'valid_until']),
      status: getString(['status', 'certificate_status', 'state']),
      certificateUrl: tryString(json['certificate_url'] ?? json['download_url'] ?? json['image_url'] ?? json['url'] ?? json['file_url'] ?? json['pdf_url']),
      description: tryString(json['description'] ?? json['notes'] ?? json['remarks']),
      type: tryString(json['type']),
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

  bool get isValid => status.toLowerCase() == 'valid' || status.toLowerCase() == 'active';
  bool get isExpired => status.toLowerCase() == 'expired';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'studentName': studentName,
      'schoolName': schoolName,
      'courseName': courseName,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'status': status,
      'certificateUrl': certificateUrl,
      'description': description,
      'type': type,
    };
  }
}
