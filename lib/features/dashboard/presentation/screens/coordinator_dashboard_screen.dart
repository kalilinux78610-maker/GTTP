import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CoordinatorDashboardScreen extends ConsumerStatefulWidget {
  final String displayName;
  const CoordinatorDashboardScreen({super.key, required this.displayName});

  @override
  ConsumerState<CoordinatorDashboardScreen> createState() => _CoordinatorDashboardScreenState();
}

class _CoordinatorDashboardScreenState extends ConsumerState<CoordinatorDashboardScreen> {
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
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
                      'QUICK ACCESS',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildPremiumQuickAccessCard(
                      icon: Icons.business,
                      iconColor: const Color(0xFF3286C9),
                      title: 'Institute Records',
                      subtitle: 'View assigned schools &\ncollege students',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => '${data.totalSchools} Institutes',
                        orElse: () => 'Institutes',
                      ),
                      onTap: () => context.push('/dashboard/school-network'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumQuickAccessCard(
                      icon: Icons.photo_library_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: 'Gallery',
                      subtitle: 'Manage photos & event\ndocumentation',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => data.totalGallery > 0 ? '${data.totalGallery} Photos' : 'View Photos',
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
              child: Container(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFF3286C9),
              ),
            ),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF3286C9), const Color(0xFF1B639E)],
                ),
              ),
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
                              String? avatarUrl = CourseAssetUrl.resolve(userAsync.value?.avatar);
                              final schoolLogo = dashboardAsync.value?.schoolLogo;
                              // No longer falling back to schoolLogo, use user initials instead
                              
                              Widget placeholder = Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: const Color(0xFFE65100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
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
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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
                      const Text(
                        'National Coordinator',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2235) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Region Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPremiumStatItem('Institutes', institutes, const Color(0xFF3B82F6), isDark),
              _buildPremiumStatItem('Active Courses', activeCourses, const Color(0xFFF97316), isDark),
              _buildPremiumStatItem('Total Students', totalStudents, const Color(0xFF22C55E), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatItem(String label, String value, Color color, bool isDark) {
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
          label.replaceAll(' ', '\n'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white60 : Colors.grey[600],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2235) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
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
                color: iconColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
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
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Text(
                trailingText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

