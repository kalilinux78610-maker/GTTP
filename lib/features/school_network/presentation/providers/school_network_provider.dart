import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import '../../data/models/school_model.dart';

final schoolsProvider = FutureProvider<List<SchoolModel>>((ref) async {
  final schoolsFromApi = await ref.watch(schoolsApiProvider.future);
  final studentsFromApi = await ref.watch(studentsApiProvider.future);

  final studentCountsBySchoolName = <String, int>{};
  for (final rawStudent in studentsFromApi) {
    final schoolName = _studentSchoolName(rawStudent);
    if (schoolName.isEmpty) continue;
    studentCountsBySchoolName[schoolName] =
        (studentCountsBySchoolName[schoolName] ?? 0) + 1;
  }

  final allSchools = schoolsFromApi.map(SchoolModel.fromJson).map((school) {
    final normalized = _normalized(school.title);
    final resolvedStudentCount = studentCountsBySchoolName[normalized];
    if (resolvedStudentCount == null) return school;
    return SchoolModel(
      id: school.id,
      title: school.title,
      location: school.location,
      facultyCount: school.facultyCount,
      studentCount: resolvedStudentCount,
      principalName: school.principalName,
      coordinatorName: school.coordinatorName,
      phone: school.phone,
      email: school.email,
      establishedYear: school.establishedYear,
      activeCourses: school.activeCourses,
    );
  }).toList();
  
  // Merge duplicate schools and keep strongest counts/details.
  final mergedByKey = <String, SchoolModel>{};
  for (final school in allSchools) {
    final dedupeKey = school.id.trim().isNotEmpty
        ? school.id.trim()
        : '${_normalized(school.title)}|${_normalized(school.location)}';
    final existing = mergedByKey[dedupeKey];
    if (existing == null) {
      mergedByKey[dedupeKey] = school;
      continue;
    }
    mergedByKey[dedupeKey] = SchoolModel(
      id: existing.id.isNotEmpty ? existing.id : school.id,
      title: existing.title.isNotEmpty ? existing.title : school.title,
      location: existing.location.isNotEmpty ? existing.location : school.location,
      facultyCount: existing.facultyCount >= school.facultyCount
          ? existing.facultyCount
          : school.facultyCount,
      studentCount: existing.studentCount >= school.studentCount
          ? existing.studentCount
          : school.studentCount,
      principalName: _pickBetterText(existing.principalName, school.principalName),
      coordinatorName: _pickBetterText(existing.coordinatorName, school.coordinatorName),
      phone: _pickBetterText(existing.phone, school.phone),
      email: _pickBetterText(existing.email, school.email),
      establishedYear: _pickBetterText(existing.establishedYear, school.establishedYear),
      activeCourses: existing.activeCourses >= school.activeCourses
          ? existing.activeCourses
          : school.activeCourses,
    );
  }
  return mergedByKey.values.toList();
});

String _normalized(String value) => value.trim().toLowerCase();

String _pickBetterText(String a, String b) {
  final aa = a.trim();
  final bb = b.trim();
  final aEmpty = aa.isEmpty || aa == '-' || aa.toLowerCase() == 'null';
  final bEmpty = bb.isEmpty || bb == '-' || bb.toLowerCase() == 'null';
  if (!aEmpty) return aa;
  if (!bEmpty) return bb;
  return aa.isNotEmpty ? aa : bb;
}

String _studentSchoolName(Map<String, dynamic> student) {
  dynamic valueByPath(String path) {
    dynamic current = student;
    for (final part in path.split('.')) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  const keys = [
    'school_name',
    'schoolName',
    'school',
    'institute',
    'institute_name',
    'branch_name',
    'school.name',
    'school.title',
    'school.school_name',
  ];

  for (final key in keys) {
    final value = key.contains('.') ? valueByPath(key) : student[key];
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return _normalized(text);
  }

  return '';
}

// Search query state
class SchoolSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final schoolSearchQueryProvider = NotifierProvider<SchoolSearchQueryNotifier, String>(() {
  return SchoolSearchQueryNotifier();
});

// Filtered schools based on search
final filteredSchoolsProvider = Provider<AsyncValue<List<SchoolModel>>>((ref) {
  final query = ref.watch(schoolSearchQueryProvider).toLowerCase().trim();
  final asyncSchools = ref.watch(schoolsProvider);

  return asyncSchools.whenData((schools) {
    if (query.isEmpty) return schools;
    return schools.where((school) {
      final nameMatches = school.title.toLowerCase().contains(query);
      final locationMatches = school.location.toLowerCase().contains(query);
      return nameMatches || locationMatches;
    }).toList();
  });
});
