import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import '../../data/models/student_model.dart';
import '../../domain/services/export_service.dart';

// --- Providers ---

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final exportProvider = NotifierProvider<ExportNotifier, ExportState>(() {
  return ExportNotifier();
});

class StudentFilterParams {
  final String year;
  final String school;
  final String course;

  StudentFilterParams({
    required this.year,
    required this.school,
    required this.course,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentFilterParams &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          school == other.school &&
          course == other.course;

  @override
  int get hashCode => year.hashCode ^ school.hashCode ^ course.hashCode;
}

final exportStudentsProvider = FutureProvider<List<StudentModel>>((ref) async {
  final rawStudents = await ref.watch(studentsApiProvider.future);
  final schools = await ref.watch(schoolsApiProvider.future);

  // /classes endpoint may be broken on the backend — fail gracefully
  List<Map<String, dynamic>> classes = [];
  try {
    classes = await ref.watch(classesApiProvider.future);
  } catch (e) {
    debugPrint('[exportStudentsProvider] /classes failed (backend issue): $e');
  }

  final schoolNameById = _buildNameByIdMap(
    schools,
    nameKeys: ['name', 'title', 'school_name', 'schoolName', 'institute_name'],
  );
  final classNameById = _buildNameByIdMap(
    classes,
    nameKeys: ['name', 'title', 'class_name', 'course_name', 'school_class'],
  );
  return await compute(_parseStudents, {
    'rawStudents': rawStudents,
    'schoolNameById': schoolNameById,
    'classNameById': classNameById,
  });
});

List<StudentModel> _parseStudents(Map<String, dynamic> payload) {
  final rawStudents = payload['rawStudents'] as List<dynamic>;
  final schoolNameById = payload['schoolNameById'] as Map<String, String>;
  final classNameById = payload['classNameById'] as Map<String, String>;

  return rawStudents
      .map(
        (row) => _studentFromApi(
          row as Map<String, dynamic>,
          schoolNameById: schoolNameById,
          classNameById: classNameById,
        ),
      )
      .toList();
}

final filteredExportStudentsProvider =
    FutureProvider.family<List<StudentModel>, StudentFilterParams>((
      ref,
      params,
    ) async {
      // Fetch all students without query parameters
      final allStudents = await ref.watch(exportStudentsProvider.future);

      // Filter locally
      return allStudents.where((student) {
        // Filter by school
        if (params.school != 'All Schools') {
          final sName = student.schoolName.toLowerCase().trim();
          final filterSchool = params.school.toLowerCase().trim();
          if (sName.isEmpty || sName == '-' || sName == 'unknown') return false;
          if (!sName.contains(filterSchool) && !filterSchool.contains(sName)) {
            return false;
          }
        }

        // Filter by course
        if (params.course != 'All Courses') {
          final cName = student.courseName.toLowerCase().trim();
          final filterCourse = params.course.toLowerCase().trim();
          if (cName.isEmpty || cName == '-' || cName == 'unknown') return false;
          if (!cName.contains(filterCourse) && !filterCourse.contains(cName)) {
            return false;
          }
        }
        
        // Optionally filter by year if we had a year field in StudentModel
        // For now, if year is not supported in the API or model, we skip it
        // or we could filter by admission date if available.
        return true;
      }).toList();
    });

// --- State Class ---

class ExportState {
  final bool isLoading;
  final String? savedPath;
  final String? error;

  ExportState({this.isLoading = false, this.savedPath, this.error});

  ExportState copyWith({bool? isLoading, String? savedPath, String? error}) {
    return ExportState(
      isLoading: isLoading ?? this.isLoading,
      savedPath: savedPath ?? this.savedPath,
      error: error ?? this.error,
    );
  }
}

// --- Notifier ---

class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() {
    return ExportState();
  }

  void clearStatus() {
    state = ExportState();
  }

  Future<void> exportData({
    required List<StudentModel> students,
    required String format,
    bool includePassport = true,
    bool includePillars = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null, savedPath: null);
    try {
      final exportService = ref.read(exportServiceProvider);

      final path = await exportService.exportData(
        students,
        format,
        includePassport: includePassport,
        includePillars: includePillars,
      );
      state = state.copyWith(isLoading: false, savedPath: path);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

Map<String, String> _buildNameByIdMap(
  List<Map<String, dynamic>> rows, {
  required List<String> nameKeys,
}) {
  final result = <String, String>{};
  for (final row in rows) {
    final id = (row['id'] ?? row['school_id'] ?? row['class_id'])
        ?.toString()
        .trim();
    if (id == null || id.isEmpty) continue;
    for (final key in nameKeys) {
      final value = row[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        result[id] = value;
        break;
      }
    }
  }
  return result;
}

StudentModel _studentFromApi(
  Map<String, dynamic> json, {
  Map<String, String> schoolNameById = const {},
  Map<String, String> classNameById = const {},
}) {
  // Build flattened search sources: root + nested objects
  final sources = <Map<String, dynamic>>[json];
  for (final nestedKey in [
    'data',
    'user',
    'student',
    'profile',
    'school',
    'class',
    'school_class',
    'course',
  ]) {
    final nested = json[nestedKey];
    if (nested is Map<String, dynamic>) {
      sources.add(nested);
    }
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

  String str(List<String> keys, {String fallback = ''}) {
    for (final k in keys) {
      // Search all sources
      for (final source in sources) {
        final value = k.contains('.') ? valueByPath(k) : source[k];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }
    return fallback;
  }

  int numVal(List<String> keys, {int fallback = 0}) {
    for (final k in keys) {
      for (final source in sources) {
        final value = k.contains('.') ? valueByPath(k) : source[k];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
    }
    return fallback;
  }

  // Debug: print raw JSON keys on first parse
  if (kDebugMode) {
    debugPrint('[Export] Student JSON keys: ${json.keys.toList()}');
    // Print nested objects too
    for (final key in json.keys) {
      final val = json[key];
      if (val is Map) {
        debugPrint('[Export]   Nested "$key" keys: ${val.keys.toList()}');
      }
    }
  }

  final expiry = str([
    'passport_expiry',
    'passportExpiry',
    'passport_expiration_date',
    'passportExpiryDate',
  ]);
  final expiryDate = DateTime.tryParse(expiry);
  final isExpiring =
      expiryDate != null &&
      expiryDate.isBefore(DateTime.now().add(const Duration(days: 90)));

  return StudentModel(
    id: str([
      'id',
      'student_id',
      'studentId',
      'user_id',
      'userId',
    ], fallback: DateTime.now().microsecondsSinceEpoch.toString()),
    name: str([
      'name',
      'student_name',
      'studentName',
      'full_name',
      'fullName',
      'display_name',
      'displayName',
      'first_name',
      'firstName',
      'username',
    ], fallback: 'Unknown'),
    studentCode: str([
      'student_code',
      'studentCode',
      'code',
      'admission_number',
      'admissionNumber',
      'roll_number',
      'rollNumber',
      'enrollment_number',
      'enrolment_no',
      'reg_no',
      'registration_number',
    ]),
    city: str([
      'city',
      'location',
      'address',
      'district',
      'state',
      'region',
      'town',
      'place',
    ], fallback: '-'),
    passportNumber: str([
      'passport_number',
      'passportNumber',
      'passport_no',
      'passport',
      'passport_no_',
      'travel_document',
    ], fallback: '-'),
    passportExpiry: expiry,
    schoolName: str([
      'school_name',
      'schoolName',
      'school',
      'institute',
      'institute_name',
      'instituteName',
      'branch_name',
      'branchName',
      'academy_name',
      'center_name',
      'centerName',
      'school.name',
      'school.title',
      'school.school_name',
      'school_name_by_id',
    ], fallback: schoolNameById[str(['school_id', 'schoolId'])] ?? '-'),
    courseName: str(
      [
        'course_name',
        'courseName',
        'course',
        'program',
        'program_name',
        'programName',
        'class_name',
        'className',
        'batch',
        'batch_name',
        'department',
        'discipline',
        'class.name',
        'class.title',
        'school_class.name',
        'schoolClass.name',
        'course_name_by_id',
      ],
      fallback:
          classNameById[str([
            'class_id',
            'classId',
            'school_class_id',
            'course_id',
            'courseId',
          ])] ??
          '-',
    ),
    theoryCompletion: numVal([
      'theory_completion',
      'theoryCompletion',
      'theory',
      'theory_progress',
      'theoryProgress',
      'pillar_1',
      'pillar1',
    ]),
    practicalCompletion: numVal([
      'practical_completion',
      'practicalCompletion',
      'practical',
      'practical_progress',
      'practicalProgress',
      'pillar_2',
      'pillar2',
    ]),
    internshipCompletion: numVal([
      'internship_completion',
      'internshipCompletion',
      'internship',
      'internship_progress',
      'internshipProgress',
      'pillar_3',
      'pillar3',
    ]),
    visitsCompletion: numVal([
      'visits_completion',
      'visitsCompletion',
      'visits',
      'visits_progress',
      'visitsProgress',
      'visit_completion',
      'pillar_4',
      'pillar4',
    ]),
    isPassportExpiring: isExpiring,
  );
}
