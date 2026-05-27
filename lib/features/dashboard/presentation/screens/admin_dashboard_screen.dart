import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final String displayName;
  const AdminDashboardScreen({super.key, required this.displayName});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
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
                    const SizedBox(height: 32),
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
                      trailingText: 'View Photos',
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
      data: (user) => AppUserRole.fromApi(user?.role).label,
      orElse: () => 'Trust Administrator',
    );

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF0052CC), const Color(0xFF003D99)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.language, color: Colors.white, size: 28),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              radius: 20,
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _headerGreeting(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleLabel.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 220,
              child: dashboardAsync.when(
                data: (data) => _buildPremiumOverviewCard(
                  institutes: '${data.totalSchools}',
                  activeCourses:
                      '${data.totalCourses > 0 ? data.totalCourses : data.totalClasses}',
                  totalStudents: '${data.totalStudents}',
                  isDark: isDark,
                ),
                loading: () => _buildPremiumOverviewCard(
                  institutes: '—',
                  activeCourses: '—',
                  totalStudents: '—',
                  isDark: isDark,
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
        const SizedBox(height: 90),
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
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                'SYSTEM OVERVIEW',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPremiumStatItem('Total Schools', institutes, const Color(0xFF3B82F6), isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
              _buildPremiumStatItem('Active Projects', activeCourses, const Color(0xFFF97316), isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
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
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.replaceAll(' ', '\n'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
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
        padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withValues(alpha: 0.8),
                    iconColor,
                  ],
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
              ),
          ],
        ),
      ),
    );
  }
}
