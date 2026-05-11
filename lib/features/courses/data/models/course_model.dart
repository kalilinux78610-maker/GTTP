import 'package:flutter_dotenv/flutter_dotenv.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String? instructor;
  final String? duration;
  final String? level;
  final String? startDate;
  final String? endDate;
  final String? enrollmentType;
  final String? status;
  final String? passPercentage;
  final bool isEnrolled;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.instructor,
    this.duration,
    this.level,
    this.startDate,
    this.endDate,
    this.enrollmentType,
    this.status,
    this.passPercentage,
    this.isEnrolled = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
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

    String? processImageUrl(dynamic value) {
      if (value == null) return null;

      String? url;
      if (value is List && value.isNotEmpty) {
        url = value.first?.toString().trim();
      } else if (value is String) {
        String stringValue = value.trim();
        if (stringValue.startsWith('[') && stringValue.endsWith(']')) {
          stringValue = stringValue.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll('\\', '').trim();
          final parts = stringValue.split(',');
          if (parts.isNotEmpty && parts.first.isNotEmpty) {
            url = parts.first.trim();
          }
        } else {
          url = stringValue;
        }
      } else {
        url = value.toString().trim();
      }

      if (url == null || url.isEmpty) return null;
      if (url.startsWith('http://') || url.startsWith('https://')) return url;
      final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'https://gttp.efsouls.com';
      final normalizedPath = url.startsWith('/')
          ? url.substring(1)
          : url;
      final storageAwarePath = normalizedPath.startsWith('storage/')
          ? normalizedPath
          : 'storage/$normalizedPath';
      return '$baseUrl/$storageAwarePath';
    }

    String stripHtml(String value) {
      final withoutTags = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
      return withoutTags
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    final rawDescription = getString(['description', 'details', 'summary', 'about']);

    return CourseModel(
      id: getString(['id', 'course_id', 'courseId']),
      title: getString(['title', 'name', 'course_name', 'heading']),
      description: stripHtml(rawDescription),
      thumbnailUrl: processImageUrl(
        json['cover_image'] ??
            json['thumbnail_url'] ??
            json['thumbnail'] ??
            json['image_url'] ??
            json['image'],
      ),
      instructor: tryString(json['instructor'] ?? json['teacher'] ?? json['author']),
      duration: tryString(
        json['duration'] ??
            json['total_hours'] ??
            json['length'] ??
            json['time'],
      ),
      level: tryString(json['level'] ?? json['difficulty'] ?? json['grade']),
      startDate: tryString(json['start_date'] ?? json['startDate']),
      endDate: tryString(json['end_date'] ?? json['endDate']),
      enrollmentType: tryString(json['enrollment_type'] ?? json['enrollmentType']),
      status: tryString(json['status'] ?? json['state']),
      passPercentage: tryString(json['pass_percentage'] ?? json['passPercentage']),
      isEnrolled: getBool(['is_enrolled', 'isEnrolled', 'enrolled', 'joined']),
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
}
