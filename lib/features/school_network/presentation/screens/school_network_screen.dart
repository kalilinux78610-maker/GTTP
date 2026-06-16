import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/router/navigation_utils.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/school_model.dart';
import '../providers/school_network_provider.dart';
import '../widgets/school_list_card.dart';

class _SchoolRow {
  const _SchoolRow({
    required this.title,
    required this.location,
    required this.facultyCount,
    required this.studentCount,
    required this.principalName,
    required this.coordinatorName,
    required this.phone,
    required this.email,
    required this.establishedYear,
    required this.activeCourses,
  });

  final String title;
  final String location;
  final String facultyCount;
  final String studentCount;
  final String principalName;
  final String coordinatorName;
  final String phone;
  final String email;
  final String establishedYear;
  final String activeCourses;

  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String s) => s.toLowerCase().contains(q);
    return has(title) ||
        has(location) ||
        has(principalName) ||
        has(coordinatorName) ||
        has(phone) ||
        has(email) ||
        has(activeCourses);
  }
}

class SchoolNetworkScreen extends ConsumerStatefulWidget {
  const SchoolNetworkScreen({super.key});

  @override
  ConsumerState<SchoolNetworkScreen> createState() => _SchoolNetworkScreenState();
}

class _SchoolNetworkScreenState extends ConsumerState<SchoolNetworkScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  /// Current query (kept in sync with controller for rebuilds).
  String _searchQuery = '';

  String _displayOrPending(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty || cleaned == '-' || cleaned.toLowerCase() == 'null') {
      return 'Not provided yet';
    }
    return cleaned;
  }

  String _formatDate(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty || cleaned == '-' || cleaned.toLowerCase() == 'null') {
      return 'Not provided yet';
    }
    try {
      final date = DateTime.parse(cleaned);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return cleaned;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Let the provider load naturally — cache kicks in on re-visits.
  }

  List<_SchoolRow> _mapSchools(List<SchoolModel> models) {
    return models
        .map(
          (s) => _SchoolRow(
            title: s.title,
            location: s.location,
            facultyCount: s.facultyCount.toString(),
            studentCount: s.studentCount.toString(),
            principalName: _displayOrPending(s.principalName),
            coordinatorName: _displayOrPending(s.coordinatorName),
            phone: _displayOrPending(s.phone),
            email: _displayOrPending(s.email),
            establishedYear: _formatDate(s.establishedYear),
            activeCourses: '${s.activeCourses} Active Courses',
          ),
        )
        .toList();
  }

  List<_SchoolRow> _filterSchools(List<_SchoolRow> schools) {
    return schools.where((s) => s.matchesSearch(_searchQuery)).toList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Soft refresh — cache handles dedup, won't re-fetch if <5 min old
      ref.invalidate(schoolsProvider);
    }
  }

  /// Pull-to-refresh: clears cache and forces a fresh API call.
  Future<void> _refreshAllData() async {
    forceRefreshSchools(ref);
    ref.invalidate(coursesApiProvider);
    try {
      await ref.read(coursesApiProvider.future);
      // We don't await schoolsProvider.future because it's a stream that
      // yields basic data quickly and then does a heavy background load.
      // Awaiting it would block the pull-to-refresh spinner until the heavy load finishes.
    } catch (e) { if (kDebugMode) debugPrint('Exception: $e'); }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final schoolsAsync = ref.watch(schoolsProvider);
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final dashboardTotalCourses = dashboardAsync.maybeWhen(
      data: (d) => d.totalCourses,
      orElse: () => null,
    );
    final coursesApiCount = ref.watch(coursesApiProvider).maybeWhen(
      data: (list) => list.length,
      orElse: () => null,
    );
    final allSchools = schoolsAsync.maybeWhen(data: _mapSchools, orElse: () => const <_SchoolRow>[]);
    final filteredSchools = _filterSchools(allSchools);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeaderStack(context),
              _buildStatsSection(
                allSchools,
                dashboardTotalCourses: dashboardTotalCourses,
                coursesApiCount: coursesApiCount,
              ),
              _buildSchoolListSection(schoolsAsync, filteredSchools, allSchools.length),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStack(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          color: const Color(0xFFF27121),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () {
                      NavigationUtils.safePop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Institutes Network',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage branch institutes & coordinators',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: double.infinity,
          height: 276,
        ),
        Positioned(
          top: 204,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: const Color(0xFFF27121),
                decoration: InputDecoration(
                  hintText: 'Search by name or location',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(Icons.search, color: Color(0xFF64748B), size: 22),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                          onPressed: _clearSearch,
                        ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    List<_SchoolRow> allSchools, {
    int? dashboardTotalCourses,
    int? coursesApiCount,
  }) {
    final total = allSchools.length;
    final totalFaculty = allSchools.fold<int>(
      0,
      (sum, school) => sum + (int.tryParse(school.facultyCount) ?? 0),
    );
    final totalStudents = allSchools.fold<int>(
      0,
      (sum, school) => sum + (int.tryParse(school.studentCount) ?? 0),
    );
    final avgRaw = total == 0 ? 0.0 : totalStudents / total;
    final avgStudents = avgRaw == avgRaw.roundToDouble()
        ? '${avgRaw.round()}'
        : avgRaw.toStringAsFixed(1);
    final fromSchoolRows = allSchools.fold<int>(
      0,
      (sum, school) =>
          sum + (int.tryParse(school.activeCourses.split(' ').first) ?? 0),
    );
    final totalCourses = coursesApiCount ??
        ((dashboardTotalCourses ?? 0) > 0 ? dashboardTotalCourses! : null) ??
        fromSchoolRows;
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCol(
                icon: Icons.business,
                iconBg: const Color(0xFFF27121),
                value: '$total',
                label: 'Institutes',
                valueColor: const Color(0xFFF27121),
              ),
              _buildDivider(),
              _buildStatCol(
                icon: Icons.people_outline,
                iconBg: const Color(0xFF2E82C3),
                value: '$totalFaculty',
                label: 'Total Faculty',
                valueColor: const Color(0xFF2E82C3),
              ),
              _buildDivider(),
              _buildStatCol(
                icon: Icons.school_outlined,
                iconBg: const Color(0xFF249048),
                value: '$totalStudents',
                label: 'Total Students',
                valueColor: const Color(0xFF249048),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    color: const Color(0xFF8B5CF6),
                    icon: Icons.trending_up,
                    value: avgStudents,
                    label: 'Avg Students/Institute',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    color: const Color(0xFFEC4899),
                    icon: Icons.emoji_events_outlined,
                    value: '$totalCourses',
                    label: 'Total Courses',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCol({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      color: AppTheme.borderLight,
    );
  }

  Widget _buildInfoCard({
    required Color color,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolListSection(
    AsyncValue<List<SchoolModel>> schoolsAsync,
    List<_SchoolRow> filtered, 
    int total,
  ) {
    final subtitle = _searchQuery.trim().isEmpty
        ? null
        : '${filtered.length} of $total institutes';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchQuery.trim().isEmpty
                          ? 'All Institutes ($total)'
                          : 'Results (${filtered.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHeading,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          schoolsAsync.when(
            data: (_) {
              if (filtered.isEmpty) {
                return _buildEmptySearchState();
              }
              return Column(
                children: filtered.map(
                  (s) => SchoolListCard(
                    title: s.title,
                    location: s.location,
                    facultyCount: s.facultyCount,
                    studentCount: s.studentCount,
                    principalName: s.principalName,
                    coordinatorName: s.coordinatorName,
                    phone: s.phone,
                    email: s.email,
                    establishedYear: s.establishedYear,
                    activeCourses: s.activeCourses,
                  ),
                ).toList(),
              );
            },
            loading: () => Skeletonizer(
              enabled: true,
              child: Column(
                children: List.generate(
                  3,
                  (index) => const SchoolListCard(
                    title: 'Loading School Name Here...',
                    location: 'Loading City, State',
                    facultyCount: '00',
                    studentCount: '000',
                    principalName: 'Loading Principal Name',
                    coordinatorName: 'Loading Coordinator Name',
                    phone: '+91-0000000000',
                    email: 'loading@school.com',
                    establishedYear: '01/01/2000',
                    activeCourses: '0 Active Courses',
                  ),
                ),
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load schools:\n$error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade400, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _refreshAllData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppTheme.textMuted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No schools match "${_searchQuery.trim()}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }

}


