import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:gttp/features/courses/domain/entities/course.dart';
import 'course_module_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description; // Plain text description
  final String htmlDescription; // Raw HTML description
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
  final List<CourseModuleModel> modules;

  CourseModel({
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

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    String? tryString(dynamic value) {
      final s = ApiJsonParser.asString(value);
      return s.isEmpty ? null : s;
    }

    String getString(List<String> keys) {
      for (final key in keys) {
        final value = _getValueByPath(json, key);
        if (value != null) {
          final s = ApiJsonParser.asString(value);
          if (s.isNotEmpty) return s;
        }
      }
      return '';
    }

    bool getBool(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null) return ApiJsonParser.asBool(value);
      }
      return false;
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

    List<CourseModuleModel> parseModules() {
      final raw = json['modules'] ?? json['course_modules'];
      if (raw is! List) return [];

      final sorted = raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
        ..sort((a, b) {
          final ao = int.tryParse(ApiJsonParser.asString(a['order'])) ?? 0;
          final bo = int.tryParse(ApiJsonParser.asString(b['order'])) ?? 0;
          return ao.compareTo(bo);
        });

      final modules = <CourseModuleModel>[];
      for (var i = 0; i < sorted.length; i++) {
        var locked = false;
        final isSequential = ApiJsonParser.asBool(sorted[i]['is_sequential'] ?? sorted[i]['isSequential'] ?? '1');
        if (isSequential) {
          for (var j = 0; j < i; j++) {
            if (!modules[j].isCompleted) {
              locked = true;
              break;
            }
          }
        }
        modules.add(CourseModuleModel.fromJson(sorted[i], index: i, lockedBySequence: locked));
      }
      return modules.where((m) => m.title.isNotEmpty).toList();
    }

    int? parseProgress(List<CourseModuleModel> modules) {
      final raw = json['progress_percentage'] ??
          json['progress_percent'] ??
          json['progressPercent'] ??
          json['overall_progress'] ??
          json['progress'];
      if (raw != null) {
        if (raw is int) return raw.clamp(0, 100);
        if (raw is double) return raw.round().clamp(0, 100);
        final n = int.tryParse(ApiJsonParser.asString(raw).replaceAll('%', ''));
        if (n != null) return n.clamp(0, 100);
      }
      if (modules.isEmpty) return null;
      final done = modules.where((m) => m.isCompleted).length;
      return ((done / modules.length) * 100).round();
    }

    String? formatDate(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      try {
        final dt = DateTime.parse(raw);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      } catch (_) {
        return raw;
      }
    }

    final rawDescription = getString(['description', 'details', 'summary', 'about']);
    final modules = parseModules();

    final idRaw = json['id'] ?? json['course_id'];
    final id = ApiJsonParser.asString(idRaw);

    return CourseModel(
      id: id.isEmpty ? getString(['courseId']) : id,
      title: getString(['title', 'name', 'course_name', 'heading']),
      description: stripHtml(rawDescription),
      htmlDescription: rawDescription,
      thumbnailUrl: CourseAssetUrl.resolve(
        getString([
          'cover_image',
          'cover_image_url',
          'coverImageUrl',
          'thumbnail_url',
          'thumbnail',
          'image_url',
          'image',
          'course_image',
          'featured_image',
          'picture',
          'photo'
        ]),
      ),
      instructor: tryString(json['instructor'] ?? json['teacher'] ?? json['author']),
      duration: tryString(
        json['total_hours'] ?? json['duration'] ?? json['length'] ?? json['time'],
      ),
      level: tryString(json['level'] ?? json['difficulty'] ?? json['grade']),
      startDate: formatDate(tryString(json['start_date'] ?? json['startDate'])),
      endDate: formatDate(tryString(json['end_date'] ?? json['endDate'])),
      enrollmentType: tryString(json['enrollment_type'] ?? json['enrollmentType']),
      status: tryString(json['status'] ?? json['state']),
      passPercentage: tryString(json['pass_percentage'] ?? json['passPercentage']),
      isEnrollable: getBool(['is_enrollable', 'isEnrollable', 'enrollable']),
      isEnrolled: getBool(['is_enrolled', 'isEnrolled', 'enrolled', 'joined']),
      progressPercent: parseProgress(modules),
      pdfUrl: CourseAssetUrl.resolve(
        json['course_details_pdf'] ??
            json['pdf_url'] ??
            json['pdfUrl'] ??
            json['course_pdf_url'],
      ),
      modules: modules,
    );
  }

  CourseModel copyWith({
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
    List<CourseModuleModel>? modules,
  }) {
    return CourseModel(
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

  Course toEntity() {
    return Course(
      id: id,
      title: title,
      description: description,
      htmlDescription: htmlDescription,
      thumbnailUrl: thumbnailUrl,
      instructor: instructor,
      duration: duration,
      level: level,
      startDate: startDate,
      endDate: endDate,
      enrollmentType: enrollmentType,
      status: status,
      passPercentage: passPercentage,
      isEnrollable: isEnrollable,
      isEnrolled: isEnrolled,
      progressPercent: progressPercent,
      pdfUrl: pdfUrl,
      modules: modules.map((m) => m.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'htmlDescription': htmlDescription,
      'thumbnailUrl': thumbnailUrl,
      'instructor': instructor,
      'duration': duration,
      'level': level,
      'start_date': startDate,
      'end_date': endDate,
      'enrollment_type': enrollmentType,
      'status': status,
      'pass_percentage': passPercentage,
      'is_enrollable': isEnrollable,
      'is_enrolled': isEnrolled,
      'progressPercent': progressPercent,
      'pdfUrl': pdfUrl,
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }
}
