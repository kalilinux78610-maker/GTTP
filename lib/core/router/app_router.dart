import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/shell/main_shell_screen.dart';
import 'package:gttp/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:gttp/features/auth/presentation/screens/login_screen.dart';
import 'package:gttp/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:gttp/features/auth/presentation/screens/splash_screen.dart';
import 'package:gttp/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:gttp/features/courses/presentation/screens/courses_placeholder_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:gttp/core/widgets/coming_soon_screen.dart';
import 'package:gttp/features/reports/presentation/screens/data_export_screen.dart';
import 'package:gttp/features/school_network/presentation/screens/school_network_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.uri.path;
      if (loc == '/school-network') return '/dashboard/school-network';
      if (loc == '/data-export') return '/dashboard/data-export';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final extra = state.extra;
          final sessionExpired = (extra is Map<String, dynamic> ? extra['sessionExpired'] : false) as bool? ?? false;
          return LoginScreen(sessionExpired: sessionExpired);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final extra = state.extra;
          final email = (extra is Map<String, dynamic> ? extra['email'] : null) as String? ?? '';
          final isPasswordReset =
              (extra is Map<String, dynamic> ? extra['isPasswordReset'] : false) as bool? ?? false;
          return VerifyOtpScreen(email: email, isPasswordReset: isPasswordReset);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final otp = extra['otp'] as String? ?? '';
          return ResetPasswordScreen(email: email, otp: otp);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'school-network',
                    builder: (context, state) => const SchoolNetworkScreen(),
                  ),
                  GoRoute(
                    path: 'data-export',
                    builder: (context, state) => const DataExportCenterScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ComingSoonScreen(title: 'Flagged Reports Review'),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      return const ComingSoonScreen(title: 'Flagged Reports Review');
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) => const CoursesPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
