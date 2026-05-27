import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/courses/presentation/screens/coordinator_course_details_screen.dart';
import 'package:gttp/features/courses/presentation/screens/course_details_screen.dart';
import 'package:gttp/features/courses/presentation/screens/teacher_course_details_screen.dart';

class CourseDetailsProxyScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailsProxyScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF4F7FB),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => CourseDetailsScreen(courseId: courseId),
      data: (user) {
        final role = AppUserRole.fromApi(user?.role);
        if (role.isCoordinator) {
          return CoordinatorCourseDetailsScreen(courseId: courseId);
        }

        if (role.usesTeacherDashboard) {
          return TeacherCourseDetailsScreen(courseId: courseId);
        }

        // Standard student view
        return CourseDetailsScreen(courseId: courseId);
      },
    );
  }
}
