import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/courses_repository_impl.dart';

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    if (ref.read(isOnlineProvider)) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(timer.cancel);

  final repository = ref.watch(coursesRepositoryProvider);
  return repository.getCourses();
});

