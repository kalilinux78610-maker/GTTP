import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

        if (role == AppUserRole.unknown) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FA),
            appBar: AppBar(
              title: const Text('Account Error'),
              backgroundColor: const Color(0xFF3286C9),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      "We couldn't determine your account role — contact support.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Color(0xFF2A3A4A)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3286C9),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const DashboardScreen(); // Fallback for student or normal user

      },
    );
  }
}
