import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/features/reports/presentation/providers/reports_provider.dart';


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
      backgroundColor: const Color(0xFFF6F8FA),
      body: _buildDashboardBody(),
    );
  }

  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(dashboardDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderAndOverview(),
            _buildQuickAccessList(),
            const SizedBox(height: 100), // padding for shell bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAndOverview() {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Blue Gradient Background
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3286C9), Color(0xFF1B639E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo Box
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png', // Assuming exists
                          width: 45,
                          height: 35,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.travel_explore,
                                  color: Color(0xFF3286C9), size: 35),
                        ),
                      ),
                      // Profile Avatar
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _headerGreeting(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Trust Administrator',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Overview Card (Overlapping)
        Positioned(
          top: 210,
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
                  'Trust Overview',
                  style: TextStyle(
                    color: Color(0xFF2A3A4A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                dashboardAsync.when(
                  data: (data) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        '${data.totalSchools}', // Mapped to Total Schools based on design mock
                        'Total Schools',
                        const Color(0xFF3286C9),
                      ),
                      _buildStatItem(
                        '${data.totalClasses}', // Mapped to Active Projects
                        'Active Projects',
                        const Color(0xFFE65C00),
                      ),
                      _buildStatItem(
                        data.totalStudents > 1000 ? '${(data.totalStudents / 1000).toStringAsFixed(1)}k' : '${data.totalStudents}',
                        'Total Students',
                        const Color(0xFF209E5A),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )),
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
            title: 'Flagged Reports Review',
            subtitle: 'Review & override flagged submissions',
            trailing: ref.watch(flaggedReportsProvider).maybeWhen(
                  data: (reports) => '${reports.length} Flagged',
                  orElse: () => 'Loading...',
                ),
            icon: Icons.business_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFFEA3A3D),
            onTap: () => context.go('/reports'),
          ),
          _buildQuickAccessCard(
            title: 'School Network',
            subtitle: 'Manage branch schools & coordinators',
            trailing: ref.watch(dashboardDataProvider).maybeWhen(
                  data: (data) => '${data.totalSchools} Schools',
                  orElse: () => 'Loading...',
                ),
            icon: Icons.campaign_rounded,
            iconColor: Colors.white,
            iconBg: const Color(0xFFE86924),
            onTap: () => context.push('/dashboard/school-network'),
          ),
          _buildQuickAccessCard(
            title: 'Data Export & Analytics',
            subtitle: 'Download master data with passport info',
            trailing: 'Export Excel',
            icon: Icons.snippet_folder_rounded,
            iconColor: Colors.white,
            iconBg: const Color(0xFF7A4BED),
            onTap: () => context.push('/dashboard/data-export'),
          ),
          _buildQuickAccessCard(
            title: 'Gallery',
            subtitle: 'View all events, competitions & activities',
            trailing: '124 Photos',
            icon: Icons.photo_library_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFF29954C),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required String trailing,
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
        trailing: Text(
          trailing,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8692A6),
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
