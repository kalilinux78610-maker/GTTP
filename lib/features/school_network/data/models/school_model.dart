class SchoolModel {
  final String id;
  final String title;
  final String location;
  final int facultyCount;
  final int studentCount;
  final String principalName;
  final String coordinatorName;
  final String phone;
  final String email;
  final String establishedYear;
  final int activeCourses;

  SchoolModel({
    required this.id,
    required this.title,
    required this.location,
    required this.facultyCount,
    required this.studentCount,
    required this.principalName,
    required this.coordinatorName,
    required this.phone,
    required this.email,
    required this.establishedYear,
    required this.activeCourses,
  });

  // Example factory for later JSON parsing
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    int? toIntFromValue(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      if (value is List) return value.length;
      if (value is Map) {
        for (final nestedKey in const ['count', 'total', 'length']) {
          final nested = value[nestedKey];
          final parsed = toIntFromValue(nested);
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    int? findCountByKeywords(List<String> keywords) {
      int? walk(dynamic node) {
        if (node is Map) {
          for (final entry in node.entries) {
            final keyText = entry.key.toString().toLowerCase();
            final matches = keywords.any(keyText.contains);
            if (matches) {
              final parsed = toIntFromValue(entry.value);
              if (parsed != null) return parsed;
            }
            final deep = walk(entry.value);
            if (deep != null) return deep;
          }
        } else if (node is List) {
          for (final item in node) {
            final deep = walk(item);
            if (deep != null) return deep;
          }
        }
        return null;
      }

      return walk(json);
    }

    dynamic valueByPath(String path) {
      dynamic current = json;
      for (final part in path.split('.')) {
        if (current is Map && current.containsKey(part)) {
          current = current[part];
        } else {
          return null;
        }
      }
      return current;
    }

    int parseInt(List<String> keys, {int fallback = 0}) {
      int? extractFromDynamic(dynamic value) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
        if (value is List) return value.length;
        if (value is Map) {
          const nestedCountKeys = [
            'count',
            'total',
            'length',
            'faculty_count',
            'students_count',
          ];
          for (final nested in nestedCountKeys) {
            final nestedValue = value[nested];
            final nestedCount = extractFromDynamic(nestedValue);
            if (nestedCount != null) return nestedCount;
          }
        }
        return null;
      }

      for (final key in keys) {
        final value = key.contains('.') ? valueByPath(key) : json[key];
        final parsed = extractFromDynamic(value);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    String parseString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = key.contains('.') ? valueByPath(key) : json[key];
        if (value == null) continue;
        final parsed = value.toString().trim();
        if (parsed.isNotEmpty) return parsed;
      }
      return fallback;
    }

    return SchoolModel(
      id: parseString(['id', 'school_id']),
      title: parseString(
        ['title', 'name', 'school_name', 'schoolName', 'institute', 'institute_name'],
        fallback: 'Unnamed School',
      ),
      location: parseString(
        ['location', 'city', 'address', 'district', 'state'],
        fallback: 'Unknown location',
      ),
      facultyCount: parseInt(
        [
          'facultyCount',
          'faculty_count',
          'total_faculty',
          'total_faculties',
          'teachers_count',
          'teacher_count',
          'total_teachers',
          'faculty',
          'faculties',
          'teachers',
          'staff_count',
          'total_staff',
        ],
        fallback: findCountByKeywords(['faculty', 'teacher', 'staff']) ?? 0,
      ),
      studentCount: parseInt([
        'studentCount',
        'student_count',
        'total_students',
        'students_count',
        'no_of_students',
        'students',
      ], fallback: findCountByKeywords(['student', 'learner', 'pupil']) ?? 0),
      principalName: parseString(
        [
          'principalName',
          'principal_name',
          'principal',
          'principal_incharge',
          'principal.name',
          'principal.full_name',
          'principalName.name',
        ],
        fallback: '-',
      ),
      coordinatorName: parseString(
        [
          'coordinatorName',
          'coordinator_name',
          'coordinator',
          'school_coordinator',
          'coordinator_incharge',
          'coordinator.name',
          'coordinator.full_name',
          'school_coordinator.name',
        ],
        fallback: '-',
      ),
      phone: parseString(
        ['phone', 'mobile', 'contact_no', 'principal.phone', 'coordinator.phone'],
        fallback: '-',
      ),
      email: parseString(
        ['email', 'contact_email', 'principal.email', 'coordinator.email'],
        fallback: '-',
      ),
      establishedYear: parseString(
        ['establishedYear', 'established_year', 'established', 'year_established', 'since'],
        fallback: '-',
      ),
      activeCourses: parseInt(['activeCourses', 'active_courses', 'courses_count']),
    );
  }
}
