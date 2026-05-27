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
            'courses_count',
            'active_courses',
            'classes_count',
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

    // Extract principal name from principals array (API returns array of objects)
    String extractFromArray(String arrayKey, List<String> nameKeys) {
      final arr = json[arrayKey];
      if (arr is List && arr.isNotEmpty) {
        final first = arr.first;
        if (first is Map<String, dynamic>) {
          for (final key in nameKeys) {
            final val = first[key];
            if (val != null && val.toString().trim().isNotEmpty) {
              return val.toString().trim();
            }
          }
        }
      }
      return '-';
    }

    return SchoolModel(
      id: parseString(['id', 'school_id']),
      title: parseString([
        'name',
        'title',
        'school_name',
        'schoolName',
        'institute',
        'institute_name',
      ], fallback: 'Unnamed School'),
      location: parseString([
        'address',
        'location',
        'city',
        'district',
        'state',
      ], fallback: 'Unknown location'),
      facultyCount: parseInt([
        'total_faculties',
        'total_faculty',
        'total_coordinators',
        'facultyCount',
        'faculty_count',
        'teachers_count',
        'teacher_count',
        'total_teachers',
        'staff_count',
        'total_staff',
      ], fallback: 0),
      studentCount: parseInt([
        'total_students',
        'studentCount',
        'student_count',
        'students_count',
        'no_of_students',
      ], fallback: 0),
      principalName: () {
        // First try the principals array (actual API format)
        final fromArr = extractFromArray('principals', [
          'name',
          'full_name',
          'display_name',
        ]);
        if (fromArr != '-') return fromArr;
        // Fallback to flat fields
        return parseString([
          'principalName',
          'principal_name',
          'principal_incharge',
          'principal.name',
          'principal.full_name',
        ], fallback: '-');
      }(),
      coordinatorName: () {
        // First try the coordinators array (actual API format)
        final fromArr = extractFromArray('coordinators', [
          'name',
          'full_name',
          'display_name',
        ]);
        if (fromArr != '-') return fromArr;
        // Fallback to flat fields
        return parseString([
          'coordinatorName',
          'coordinator_name',
          'school_coordinator',
          'coordinator_incharge',
          'coordinator.name',
          'coordinator.full_name',
        ], fallback: '-');
      }(),
      phone: parseString(['phone', 'mobile', 'contact_no'], fallback: '-'),
      email: parseString(['email', 'contact_email'], fallback: '-'),
      establishedYear: parseString([
        'establishedYear',
        'established_year',
        'established',
        'year_established',
        'since',
        'created_at',
      ], fallback: '-'),
      // API does not yet return a courses count — default to 0 but handle future keys
      activeCourses: parseInt([
        'activeCourses',
        'active_courses',
        'courses_count',
        'total_courses',
        'courses',
        'classes',
        'classes_count',
      ]),
    );
  }
}
