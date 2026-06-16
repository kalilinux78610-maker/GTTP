import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/coordinator_dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/principal_dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/teacher_dashboard_screen.dart';

final _fallbackNameProvider = FutureProvider.autoDispose((ref) => ref.read(secureStorageProvider).getDisplayName());

class DashboardProxyScreen extends ConsumerWidget {
  const DashboardProxyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);
    final fallbackNameAsync = ref.watch(_fallbackNameProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF6F8FA),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const DashboardScreen(),
      data: (user) {
        var role = AppUserRole.fromApi(user?.effectiveRole);
        final fallbackName = fallbackNameAsync.value;
        String displayName = user?.name ?? '';
        if (displayName.isEmpty && fallbackName != null) {
          displayName = fallbackName;
        }
        
        final email = user?.email ?? '';

        // Hardcode override since API doesn't return full data
        if (email.toLowerCase().contains('shreyanshvasava@efsouls.com') ||
            email.toLowerCase().contains('superadmin') ||
            displayName.toLowerCase().contains('shreyanshvasava') ||
            displayName.toLowerCase().contains('super admin')) {
          role = AppUserRole.superAdmin;
          if (displayName.isEmpty) displayName = 'Super Admin';
        }

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

        return const DashboardScreen(); // Fallback if no matching role
      },
    );
  }
}
