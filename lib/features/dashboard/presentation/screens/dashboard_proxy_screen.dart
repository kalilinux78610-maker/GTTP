import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/coordinator_dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/principal_dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/teacher_dashboard_screen.dart';

class DashboardProxyScreen extends ConsumerWidget {
  const DashboardProxyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF6F8FA),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const DashboardScreen(),
      data: (user) {
        final role = AppUserRole.fromApi(user?.role);
        final displayName = user?.name ?? '';

        if (role.usesAdminDashboard && role != AppUserRole.unknown) {
          return AdminDashboardScreen(displayName: displayName);
        }

        if (role.usesCoordinatorDashboard) {
          return CoordinatorDashboardScreen(displayName: displayName);
        }

        if (role.usesPrincipalDashboard) {
          return PrincipalDashboardScreen(displayName: displayName);
        }

        if (role.usesTeacherDashboard) {
          return TeacherDashboardScreen(displayName: displayName);
        }

        return const DashboardScreen();
      },
    );
  }
}
