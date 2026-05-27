import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course_module_model.dart';
import 'course_details_provider.dart';

/// Loads module from real API: `GET /courses/{courseId}` → `data.modules[]`.
final courseModuleProvider = FutureProvider.autoDispose
    .family<CourseModuleModel?, ({String courseId, String moduleId})>((ref, params) async {
  final course = await ref.watch(courseDetailsProvider(params.courseId).future);
  if (course == null) return null;
  for (final module in course.modules) {
    if (module.id == params.moduleId) return module;
  }
  return null;
});
