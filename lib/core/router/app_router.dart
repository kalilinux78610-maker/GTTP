import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/core/shell/main_shell_screen.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:gttp/features/auth/presentation/screens/login_screen.dart';
import 'package:gttp/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:gttp/features/auth/presentation/screens/splash_screen.dart';
import 'package:gttp/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:gttp/features/certificates/presentation/screens/certificates_screen.dart';
import 'package:gttp/features/courses/presentation/screens/assignment_review_screen.dart';
import 'package:gttp/features/courses/presentation/screens/course_details_proxy_screen.dart';
import 'package:gttp/features/courses/presentation/screens/course_module_detail_screen.dart';
import 'package:gttp/features/courses/presentation/screens/course_quiz_screen.dart';
import 'package:gttp/features/courses/presentation/screens/courses_screen.dart';
import 'package:gttp/features/courses/presentation/screens/pending_submissions_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/dashboard_proxy_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/faculty_members_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/my_students_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/edit_profile_screen.dart';
import 'package:gttp/features/dashboard/presentation/screens/teacher_student_detail_screen.dart';
import 'package:gttp/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:gttp/features/notices/presentation/screens/notices_screen.dart';
import 'package:gttp/features/notices/presentation/screens/notice_detail_screen.dart';
import 'package:gttp/features/notices/presentation/screens/create_notice_screen.dart';
import 'package:gttp/features/reports/presentation/screens/data_export_screen.dart';
import 'package:gttp/features/reports/presentation/screens/report_detail_screen.dart';
import 'package:gttp/features/reports/presentation/screens/report_list_screen.dart';
import 'package:gttp/features/reports/presentation/screens/student_progress_screen.dart';
import 'package:gttp/features/reports/presentation/screens/submit_report_screen.dart';
import 'package:gttp/features/school_network/presentation/screens/school_network_screen.dart';
import 'package:gttp/features/events/presentation/screens/events_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final loc = state.uri.path;
      if (loc == '/school-network') return '/dashboard/school-network';
      if (loc == '/data-export') return '/dashboard/data-export';

      final isAuthRoute =
          loc == '/' ||
          loc == '/login' ||
          loc == '/forgot-password' ||
          loc == '/verify-otp' ||
          loc == '/reset-password';
      final isProtectedRoute =
          loc == '/dashboard' ||
          loc.startsWith('/dashboard/') ||
          loc == '/reports' ||
          loc.startsWith('/reports/') ||
          loc == '/notices' ||
          loc == '/courses' ||
          loc.startsWith('/courses/') ||
          loc == '/profile';

      if (!isProtectedRoute) return null;

      final storage = ref.read(secureStorageProvider);
      final pendingUserId = await storage.getPendingUserId();
      if (pendingUserId != null && loc != '/verify-otp') {
        return '/verify-otp';
      }

      final accessToken = await storage.getAccessToken();
      final isAuthenticated = accessToken != null && accessToken.isNotEmpty;
      if (!isAuthenticated && !isAuthRoute) return '/login';

      if (isAuthenticated && loc == '/dashboard/data-export') {
        final user = await storage.getUserModel();
        final role = AppUserRole.fromApi(user?.effectiveRole);
        if (!role.canAccessDataExport) return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final extra = state.extra;
          final sessionExpired =
              (extra is Map<String, dynamic> ? extra['sessionExpired'] : false)
                  as bool? ??
              false;
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
          final email =
              (extra is Map<String, dynamic> ? extra['email'] : null)
                  as String? ??
              '';
          final isPasswordReset =
              (extra is Map<String, dynamic> ? extra['isPasswordReset'] : false)
                  as bool? ??
              false;
          return VerifyOtpScreen(
            email: email,
            isPasswordReset: isPasswordReset,
          );
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
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final reportId = state.pathParameters['id'] ?? '';
              return ReportDetailScreen(reportId: reportId);
            },
          ),
        ],
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
                builder: (context, state) => const DashboardProxyScreen(),
                routes: [
                  GoRoute(
                    path: 'school-network',
                    builder: (context, state) => const SchoolNetworkScreen(),
                  ),
                  GoRoute(
                    path: 'data-export',
                    builder: (context, state) => const DataExportCenterScreen(),
                  ),
                  GoRoute(
                    path: 'certificates',
                    builder: (context, state) => const CertificatesScreen(),
                  ),
                  GoRoute(
                    path: 'events',
                    builder: (context, state) => const EventsScreen(),
                  ),
                  GoRoute(
                    path: 'student-progress',
                    builder: (context, state) => const StudentProgressScreen(),
                  ),
                  GoRoute(
                    path: 'gallery',
                    builder: (context, state) => const GalleryScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notices',
                builder: (context, state) => const NoticesScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreateNoticeScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final noticeId = state.pathParameters['id'] ?? '';
                      return NoticeDetailScreen(noticeId: noticeId);
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
                builder: (context, state) => const CoursesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final courseId = state.pathParameters['id'] ?? '';
                      return CourseDetailsProxyScreen(courseId: courseId);
                    },
                    routes: [
                      GoRoute(
                        path: 'modules/:moduleId',
                        builder: (context, state) {
                          final courseId = state.pathParameters['id'] ?? '';
                          final moduleId =
                              state.pathParameters['moduleId'] ?? '';
                          return CourseModuleDetailScreen(
                            courseId: courseId,
                            moduleId: moduleId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'submit-report',
                            builder: (context, state) {
                              final courseId = state.pathParameters['id'] ?? '';
                              final moduleId =
                                  state.pathParameters['moduleId'] ?? '';
                              final submoduleId =
                                  state.uri.queryParameters['submoduleId'];
                              return SubmitReportScreen(
                                courseId: courseId,
                                moduleId: moduleId,
                                submoduleId: submoduleId,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'quiz',
                            builder: (context, state) {
                              final courseId = state.pathParameters['id'] ?? '';
                              final moduleId =
                                  state.pathParameters['moduleId'] ?? '';
                              return CourseQuizScreen(
                                courseId: courseId,
                                moduleId: moduleId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':id/pending-submissions',
                    builder: (context, state) {
                      final courseId = state.pathParameters['id'] ?? '';
                      return PendingSubmissionsScreen(courseId: courseId);
                    },
                  ),
                  GoRoute(
                    path: ':id/submissions/:submissionId',
                    builder: (context, state) {
                      final courseId = state.pathParameters['id'] ?? '';
                      final submissionId =
                          state.pathParameters['submissionId'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;

                      return AssignmentReviewScreen(
                        courseId: courseId,
                        submissionId: submissionId,
                        submissionData: extra,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: '/dashboard/my-students',
                builder: (context, state) => const MyStudentsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TeacherStudentDetailScreen(
                      studentId: state.pathParameters['id'] ?? '',
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/dashboard/faculty-members',
                builder: (context, state) => const FacultyMembersScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
