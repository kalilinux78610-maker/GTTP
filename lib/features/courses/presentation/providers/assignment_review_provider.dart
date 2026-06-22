import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/courses_repository.dart';
import '../../data/repositories/courses_repository_impl.dart';

final assignmentReviewProvider = AsyncNotifierProvider<AssignmentReviewNotifier, void>(
  AssignmentReviewNotifier.new,
);

class AssignmentReviewNotifier extends AsyncNotifier<void> {
  late final CoursesRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(coursesRepositoryProvider);
  }

  Future<void> submitReview(String submissionId, String status, String notes) async {
    state = const AsyncValue.loading();
    try {
      await _repository.reviewSubmission(submissionId, status, notes);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
