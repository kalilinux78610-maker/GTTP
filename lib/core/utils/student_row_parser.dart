/// Helpers to read common student fields from GTTP API maps.
class StudentRowParser {
  StudentRowParser._();

  static String id(Map<String, dynamic> row) {
    for (final key in [
      'id',
      'student_id',
      'studentId',
      'user_id',
      'userId',
    ]) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  static String name(Map<String, dynamic> row) {
    for (final key in [
      'name',
      'student_name',
      'studentName',
      'full_name',
      'fullName',
      'display_name',
      'displayName',
    ]) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    final first = row['first_name'] ?? row['firstName'];
    final last = row['last_name'] ?? row['lastName'];
    if (first != null) {
      final f = first.toString().trim();
      final l = last?.toString().trim() ?? '';
      final combined = [f, l].where((s) => s.isNotEmpty).join(' ');
      if (combined.isNotEmpty) return combined;
    }
    return 'Student';
  }

  static String classLabel(Map<String, dynamic> row) {
    for (final key in [
      'class_name',
      'className',
      'class',
      'section',
      'grade',
      'course_name',
      'courseName',
    ]) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    final school = row['school_name'] ?? row['schoolName'];
    if (school != null && school.toString().trim().isNotEmpty) {
      return school.toString().trim();
    }
    return '—';
  }

  static String school(Map<String, dynamic> row) {
    for (final key in [
      'school_name',
      'schoolName',
      'school',
      'institute',
      'college',
      'university',
    ]) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return 'Unknown School';
  }

  static int scorePercent(Map<String, dynamic> row) {
    for (final key in [
      'score',
      'progress',
      'progress_percent',
      'progress_percentage',
      'progressPercent',
      'completion',
      'overall_progress',
    ]) {
      final v = row[key];
      if (v is int) return v.clamp(0, 100);
      if (v is num) return v.toInt().clamp(0, 100);
      if (v is String) {
        final parsed = int.tryParse(v.replaceAll('%', '').trim());
        if (parsed != null) return parsed.clamp(0, 100);
      }
    }
    return 0;
  }

  static String? avatar(Map<String, dynamic> row) {
    for (final key in [
      'avatar',
      'profile_picture',
      'profilePicture',
      'image_url',
      'imageUrl',
      'photo',
    ]) {
      final v = row[key]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }
}
