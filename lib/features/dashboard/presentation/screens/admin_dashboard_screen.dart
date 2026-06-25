import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final String displayName;
  const AdminDashboardScreen({super.key, required this.displayName});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _timeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _headerGreeting() {
    final time = _timeOfDayGreeting();
    final name = widget.displayName.trim();
    if (name.isEmpty) return time;
    return '$time, $name';
  }

  String get _initials {
    if (widget.displayName.trim().isEmpty) return 'U';
    final parts = widget.displayName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0];
      final last = parts.last;
      if (first.isNotEmpty && last.isNotEmpty) {
        return (first[0] + last[0]).toUpperCase();
      }
    }
    return widget.displayName.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF6F8FA),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
          await ref.read(dashboardDataProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeaderWithOverview(dashboardAsync, isDark),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 64),
                    Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumQuickAccessCard(
                      icon: Icons.book_outlined,
                      iconColor: const Color(0xFF209E5A), // Green
                      title: 'Courses',
                      subtitle: 'View enrolled courses',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => '${data.totalCourses} Courses',
                        orElse: () => 'Courses',
                      ),
                      onTap: () => context.push('/courses'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumQuickAccessCard(
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFFF97316),
                      title: 'School Network',
                      subtitle: 'Manage branch schools & coordinators',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => '${data.totalSchools} Schools',
                        orElse: () => 'Schools',
                      ),
                      onTap: () => context.push('/dashboard/school-network'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumQuickAccessCard(
                      icon: Icons.snippet_folder_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Data Export & Analytics',
                      subtitle: 'Download master data with passport info',
                      trailingText: 'Export Excel',
                      onTap: () => context.push('/dashboard/data-export'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumQuickAccessCard(
                      icon: Icons.photo_library_outlined,
                      iconColor: const Color(0xFF22C55E),
                      title: 'Gallery',
                      subtitle: 'View all events, competitions & activities',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => data.totalGallery > 0
                            ? '${data.totalGallery} Photos'
                            : 'View Photos',
                        orElse: () => 'View Photos',
                      ),
                      onTap: () => context.push('/dashboard/gallery'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithOverview(AsyncValue dashboardAsync, bool isDark) {
    final userAsync = ref.watch(userModelProvider);
    final roleLabel = userAsync.maybeWhen(
      data: (user) => AppUserRole.fromApi(user?.effectiveRole).label,
      orElse: () => 'Trust Administrator',
    );

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -1000,
              left: 0,
              right: 0,
              height: 1000,
              child: Container(color: const Color(0xFF357AB6)),
            ),
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFF357AB6)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 86,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                              child: Center(
                                child: Image.asset(
                                  'assets/images/gttp-logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.language, color: Colors.blue, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 86,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                              child: Center(
                                child: Image.asset(
                                  'assets/images/ttet-logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.language, color: Colors.blue, size: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final userAsync = ref.watch(userModelProvider);
                              String? avatarUrl = CourseAssetUrl.resolve(
                                userAsync.value?.avatar,
                              );
                              final schoolLogo =
                                  dashboardAsync.value?.schoolLogo;
                              if ((avatarUrl == null || avatarUrl.isEmpty) &&
                                  schoolLogo != null &&
                                  schoolLogo.isNotEmpty) {
                                avatarUrl = CourseAssetUrl.resolve(schoolLogo);
                              }

                              Widget placeholder = Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  color: const Color(0xFFE65100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );

                              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                return Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: avatarUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          placeholder,
                                      errorWidget: (context, url, error) =>
                                          placeholder,
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
                    const SizedBox(height: 24),
                    Text(
                      _headerGreeting(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      roleLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 230,
              child: dashboardAsync.when(
                data: (data) => _buildPremiumOverviewCard(
                  institutes: '${data.totalSchools}',
                  activeCourses: '${data.totalCourses}',
                  totalStudents: '${data.totalStudents}',
                  isDark: isDark,
                ),
                loading: () => Skeletonizer(
                  enabled: true,
                  child: _buildPremiumOverviewCard(
                    institutes: '000',
                    activeCourses: '000',
                    totalStudents: '000',
                    isDark: isDark,
                  ),
                ),
                error: (_, _) => _buildPremiumOverviewCard(
                  institutes: '—',
                  activeCourses: '—',
                  totalStudents: '—',
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildPremiumOverviewCard({
    required String institutes,
    required String activeCourses,
    required String totalStudents,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trust Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPremiumStatItem(
                'Total Schools',
                institutes,
                const Color(0xFF3B82F6),
                isDark,
              ),
              _buildPremiumStatItem(
                'Total Courses',
                activeCourses,
                const Color(0xFFF97316),
                isDark,
              ),
              _buildPremiumStatItem(
                'Total Students',
                totalStudents,
                const Color(0xFF22C55E),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatItem(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumQuickAccessCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingText,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor.withValues(alpha: 0.8), iconColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 12),
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}
