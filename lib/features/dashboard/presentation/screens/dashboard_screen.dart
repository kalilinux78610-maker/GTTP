import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/courses/presentation/providers/courses_provider.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  String _displayName = '';

  String _timeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _headerGreeting() {
    final time = _timeOfDayGreeting();
    final name = _displayName.trim();
    if (name.isEmpty) return time;
    return '$time, $name';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh dashboard data slightly on init
    Future.microtask(() => ref.refresh(dashboardDataProvider));
    Future.microtask(_loadDisplayName);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(dashboardDataProvider);
      _loadDisplayName();
    }
  }

  Future<void> _loadDisplayName() async {
    final secureStorage = ref.read(secureStorageProvider);
    final storedName = await secureStorage.getDisplayName();
    if (!mounted) return;
    final value = storedName?.trim();
    if (value != null && value.isNotEmpty) {
      setState(() => _displayName = value);
    }
  }

  String get _initials {
    if (_displayName.trim().isEmpty) return 'U';
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0];
      final last = parts.last;
      if (first.isNotEmpty && last.isNotEmpty) {
        return (first[0] + last[0]).toUpperCase();
      }
    }
    return _displayName.substring(0, 1).toUpperCase();
  }

  List<Color> _getGradientColors() {
    final userAsync = ref.watch(userModelProvider);
    final role = AppUserRole.fromApi(userAsync.value?.effectiveRole);
    
    if (role == AppUserRole.faculty) {
      return const [Color(0xFF8B5CF6), Color(0xFF7C3AED)]; // Teacher/Faculty Purple
    } else if (role == AppUserRole.principal) {
      return const [Color(0xFFE65C00), Color(0xFFCC5200)]; // Principal Orange
    } else {
      return const [Color(0xFF3286C9), Color(0xFF1B639E)]; // Student/Coordinator Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<DashboardModel>>(dashboardDataProvider, (previous, next) {
      next.whenData((data) {
        final fromApi = data.currentUserDisplayName?.trim();
        if (fromApi == null || fromApi.isEmpty) return;
        if (fromApi == _displayName) return;
        ref.read(secureStorageProvider).saveDisplayName(fromApi);
        if (mounted) setState(() => _displayName = fromApi);
      });
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background filler for top overscroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300, // Enough to cover overscroll
            child: Container(
              color: _getGradientColors(isDark)[0],
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardDataProvider);
              await ref.read(dashboardDataProvider.future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeaderAndOverview(_getGradientColors(isDark)),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickAccessList(),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndOverview(List<Color> gradientColors) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Top Gradient Background
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png', // Assuming exists
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.language,
                                      color: Color(0xFF3286C9), size: 32),
                            ),
                          ),
                      // Profile Avatar
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final userAsync = ref.watch(userModelProvider);
                            final avatarUrl = userAsync.value?.avatar;
                            
                            Widget placeholder = Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE65C00),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  _initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );

                            if (avatarUrl != null && avatarUrl.isNotEmpty) {
                              return Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: avatarUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => placeholder,
                                    errorWidget: (context, url, error) => placeholder,
                                  ),
                                ),
                              );
                            }
                            return placeholder;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _headerGreeting(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(userModelProvider);
                      return userAsync.when(
                        data: (user) {
                          final role = AppUserRole.fromApi(user?.effectiveRole);
                          return Text(
                            role.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Overview Card (Overlapping)
        Positioned(
          top: 240,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Overview',
                  style: TextStyle(
                    color: Color(0xFF2A3A4A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                dashboardAsync.when(
                  data: (data) {
                    // Fallback logic: if dashboard returns 0, try to count from the actual lists
                    final coursesFallback = ref.watch(coursesProvider).value?.length ?? 0;
                    final schedulesFallback = ref.watch(schedulesProvider).value?.length ?? 0;
                    final certsFallback = ref.watch(certificatesProvider).value?.length ?? 0;

                    final displayCourses = coursesFallback > 0 ? coursesFallback : (data.totalCourses > 0 ? data.totalCourses : data.totalClasses);
                    final displaySchedules = data.totalSchedules > 0 ? data.totalSchedules : schedulesFallback;
                    final displayCerts = data.totalCertificates > 0 ? data.totalCertificates : certsFallback;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          '$displayCourses',
                          'Total Courses',
                          const Color(0xFF3286C9),
                        ),
                        _buildStatItem(
                          '$displaySchedules',
                          'Schedules',
                          const Color(0xFFE65C00),
                        ),
                        _buildStatItem(
                          '$displayCerts',
                          'Certificates',
                          const Color(0xFF209E5A),
                        ),
                      ],
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('000', 'Total Courses', const Color(0xFF3286C9)),
                        _buildStatItem('000', 'Schedules', const Color(0xFFE65C00)),
                        _buildStatItem('000', 'Certificates', const Color(0xFF209E5A)),
                      ],
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8692A6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessList() {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final certsFallback = ref.watch(certificatesProvider).value?.length ?? 0;
    
    final certCount = dashboardAsync.maybeWhen(
      data: (d) => d.totalCertificates > 0 ? d.totalCertificates : certsFallback,
      orElse: () => certsFallback,
    );
    
    final certTrailing = '$certCount Earned';

    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A4A),
            ),
          ),
          const SizedBox(height: 16),

          _buildQuickAccessCard(
            title: 'Certificates',
            subtitle: 'View all your earned certificates',
            trailing: certTrailing,
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFF209E5A),
            onTap: () => context.go('/dashboard/certificates'),
          ),
          _buildQuickAccessCard(
            title: 'Gallery',
            subtitle: 'View school events & competitions',
            icon: Icons.photo_library_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFFEA3A3D),
            onTap: () => context.go('/dashboard/gallery'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    String? trailing,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
               BoxShadow(
                 color: iconBg.withValues(alpha: 0.3),
                 blurRadius: 8,
                 offset: const Offset(0, 4),
               )
            ]
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3A4A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8692A6),
              height: 1.3,
            ),
          ),
        ),
        trailing: trailing != null
            ? Text(
                trailing,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8692A6),
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
