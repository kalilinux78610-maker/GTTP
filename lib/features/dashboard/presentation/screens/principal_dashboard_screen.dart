import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PrincipalDashboardScreen extends ConsumerStatefulWidget {
  final String displayName;
  const PrincipalDashboardScreen({super.key, required this.displayName});

  @override
  ConsumerState<PrincipalDashboardScreen> createState() => _PrincipalDashboardScreenState();
}

class _PrincipalDashboardScreenState extends ConsumerState<PrincipalDashboardScreen> {
  String _timeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _headerGreeting() {
    final time = _timeOfDayGreeting();
    final name = widget.displayName.trim();
    if (name.isEmpty) return '$time, Principal';
    return '$time, $name';
  }

  String get _initials {
    if (widget.displayName.trim().isEmpty) return 'P';
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
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOldQuickAccessCard(
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'My Students',
                      subtitle: 'View & track student progress',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => '${data.totalStudents} Students',
                        loading: () => '...',
                        orElse: () => 'Students',
                      ),
                      onTap: () => context.push('/dashboard/my-students'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildOldQuickAccessCard(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Faculty Members',
                      subtitle: 'View faculty & teaching staff',
                      trailingText: dashboardAsync.maybeWhen(
                        data: (data) => '${data.totalUsers} Faculty',
                        loading: () => '...',
                        orElse: () => 'Faculty',
                      ),
                      onTap: () => context.push('/dashboard/faculty-members'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildOldQuickAccessCard(
                      icon: Icons.photo_library_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: 'Gallery',
                      subtitle: 'View school events & activities',
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
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE65C00),
              ),
            ),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE65C00),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                              'assets/images/logo.png',
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.language, color: Color(0xFFE65C00), size: 32),
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final userAsync = ref.watch(userModelProvider);
                              final avatarUrl = userAsync.value?.avatar;
                              
                              Widget placeholder = Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: const Color(0xFFE65C00),
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
                                  width: 48,
                                  height: 48,
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
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
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
                      userAsync.when(
                        data: (user) {
                          final schoolName = dashboardAsync.value?.schoolName ?? user?.institute ?? 'School Overview';
                          return Text(
                            schoolName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
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
              top: 240,
              child: dashboardAsync.when(
                data: (data) => _buildOldOverviewCard(
                  totalStudents: '${data.totalStudents}',
                  facultyMembers: '${data.totalUsers}',
                  activeCourses:
                      '${data.totalCourses > 0 ? data.totalCourses : data.totalClasses}',
                  isDark: isDark,
                ),
                loading: () => Skeletonizer(
                  enabled: true,
                  child: _buildOldOverviewCard(
                    totalStudents: '000',
                    facultyMembers: '000',
                    activeCourses: '000',
                    isDark: isDark,
                  ),
                ),
                error: (_, _) => _buildOldOverviewCard(
                  totalStudents: '—',
                  facultyMembers: '—',
                  activeCourses: '—',
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

  Widget _buildOldOverviewCard({
    required String totalStudents,
    required String facultyMembers,
    required String activeCourses,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2235) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOldStatItem('Total Students', totalStudents, const Color(0xFF3B82F6), isDark),
              _buildOldStatItem('Faculty Members', facultyMembers, const Color(0xFFF97316), isDark),
              _buildOldStatItem('Active Courses', activeCourses, const Color(0xFF22C55E), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOldStatItem(String label, String value, Color numberColor, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: numberColor,
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
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldQuickAccessCard({
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
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

