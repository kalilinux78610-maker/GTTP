import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/dashboard/data/datasources/gttp_remote_datasource.dart';
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
  final classes = await ref.watch(classesApiProvider.future);
  final schoolNameById = _buildNameByIdMap(
    schools,
    nameKeys: ['name', 'title', 'school_name', 'schoolName', 'institute_name'],
  );
  final classNameById = _buildNameByIdMap(
    classes,
    nameKeys: ['name', 'title', 'class_name', 'course_name', 'school_class'],
  );
  return rawStudents
      .map(
        (row) => _studentFromApi(
          row,
          schoolNameById: schoolNameById,
          classNameById: classNameById,
        ),
      )
      .toList();
});

final filteredExportStudentsProvider = FutureProvider.family<List<StudentModel>, StudentFilterParams>((ref, params) async {
  final gttpDataSource = ref.read(gttpRemoteDataSourceProvider);
  final apiRows = await gttpDataSource.getStudents(
    year: params.year,
    school: params.school == 'All Schools' ? null : params.school,
    course: params.course == 'All Courses' ? null : params.course,
  );
  return apiRows.map(_studentFromApi).toList();
});

// --- State Class ---

class ExportState {
  final bool isLoading;
  final String? savedPath;
  final String? error;

  ExportState({
    this.isLoading = false,
    this.savedPath,
    this.error,
  });

  ExportState copyWith({
    bool? isLoading,
    String? savedPath,
    String? error,
  }) {
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
    bool includeAcademic = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null, savedPath: null);
    try {
      final exportService = ref.read(exportServiceProvider);

      final path = await exportService.exportData(
        students, 
        format,
        includePassport: includePassport,
        includePillars: includePillars,
        includeAcademic: includeAcademic,
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
    final id = (row['id'] ?? row['school_id'] ?? row['class_id'])?.toString().trim();
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
      final value = k.contains('.') ? valueByPath(k) : json[k];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  int numVal(List<String> keys, {int fallback = 0}) {
    for (final k in keys) {
      final value = k.contains('.') ? valueByPath(k) : json[k];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  final expiry = str(['passport_expiry', 'passportExpiry']);
  final expiryDate = DateTime.tryParse(expiry);
  final isExpiring = expiryDate != null &&
      expiryDate.isBefore(DateTime.now().add(const Duration(days: 90)));

  return StudentModel(
    id: str(['id', 'student_id'], fallback: DateTime.now().microsecondsSinceEpoch.toString()),
    name: str(['name', 'student_name'], fallback: 'Unknown'),
    studentCode: str(['student_code', 'studentCode', 'code', 'admission_number', 'roll_number']),
    city: str(['city', 'location', 'address', 'district'], fallback: '-'),
    passportNumber: str(['passport_number', 'passportNumber', 'passport_no', 'passport'], fallback: '-'),
    passportExpiry: expiry,
    schoolName: str(
      [
        'school_name',
        'schoolName',
        'school',
        'institute',
        'institute_name',
        'branch_name',
        'school.name',
        'school.title',
        'school.school_name',
      ],
      fallback: schoolNameById[str(['school_id', 'schoolId'])] ?? '-',
    ),
    courseName: str(
      [
      'course_name',
      'courseName',
      'course',
      'class_name',
      'class.name',
      'class.title',
      'school_class.name',
      'schoolClass.name',
      ],
      fallback: classNameById[str(['class_id', 'classId', 'school_class_id'])] ?? '-',
    ),
    theoryCompletion: numVal(['theory_completion', 'theoryCompletion']),
    practicalCompletion: numVal(['practical_completion', 'practicalCompletion']),
    internshipCompletion: numVal(['internship_completion', 'internshipCompletion']),
    visitsCompletion: numVal(['visits_completion', 'visitsCompletion']),
    isPassportExpiring: isExpiring,
  );
}
