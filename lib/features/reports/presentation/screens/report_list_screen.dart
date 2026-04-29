import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/presentation/providers/reports_provider.dart';
import 'package:intl/intl.dart';

class ReportListScreen extends ConsumerWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(filteredReportsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilterSection(ref),
              Expanded(
                child: reportsAsync.when(
                  data: (reports) => _buildReportList(reports, ref),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3286C9),
                    ),
                  ),
                  error: (error, _) => _buildErrorState(ref, error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final canPop = context.canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2A3A4A)),
            )
          else
            const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'Report Review & Approval',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildFilterSection(WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip<ReportCategory?>(
                  label: 'All',
                  value: null,
                  selectedValue: selectedCategory,
                  onSelected: (val) => ref.read(selectedCategoryProvider.notifier).set(val),
                ),
                _FilterChip<ReportCategory?>(
                  label: 'Theory',
                  value: ReportCategory.theory,
                  selectedValue: selectedCategory,
                  onSelected: (val) => ref.read(selectedCategoryProvider.notifier).set(val),
                ),
                _FilterChip<ReportCategory?>(
                  label: 'Practical',
                  value: ReportCategory.practical,
                  selectedValue: selectedCategory,
                  onSelected: (val) => ref.read(selectedCategoryProvider.notifier).set(val),
                ),
                _FilterChip<ReportCategory?>(
                  label: 'Internship',
                  value: ReportCategory.internship,
                  selectedValue: selectedCategory,
                  onSelected: (val) => ref.read(selectedCategoryProvider.notifier).set(val),
                ),
                _FilterChip<ReportCategory?>(
                  label: 'Visits',
                  value: ReportCategory.visits,
                  selectedValue: selectedCategory,
                  onSelected: (val) => ref.read(selectedCategoryProvider.notifier).set(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip<ReportStatus?>(
                  label: 'All',
                  value: null,
                  selectedValue: selectedStatus,
                  onSelected: (val) => ref.read(selectedStatusProvider.notifier).set(val),
                  isSecondary: true,
                ),
                _FilterChip<ReportStatus?>(
                  label: 'Pending',
                  value: ReportStatus.pending,
                  selectedValue: selectedStatus,
                  onSelected: (val) => ref.read(selectedStatusProvider.notifier).set(val),
                  isSecondary: true,
                ),
                _FilterChip<ReportStatus?>(
                  label: 'Flagged',
                  value: ReportStatus.flagged,
                  selectedValue: selectedStatus,
                  onSelected: (val) => ref.read(selectedStatusProvider.notifier).set(val),
                  isSecondary: true,
                ),
                _FilterChip<ReportStatus?>(
                  label: 'Approved',
                  value: ReportStatus.approved,
                  selectedValue: selectedStatus,
                  onSelected: (val) => ref.read(selectedStatusProvider.notifier).set(val),
                  isSecondary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(List<ReportModel> reports, WidgetRef ref) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No reports matching current filter',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(selectedCategoryProvider.notifier).set(null);
                ref.read(selectedStatusProvider.notifier).set(null);
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return _ReportCard(report: reports[index]);
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(flaggedReportsProvider.notifier).refresh(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip<T> extends StatelessWidget {
  final String label;
  final T value;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final bool isSecondary;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    final activeColor = isSecondary ? const Color(0xFF1F2937) : const Color(0xFF3286C9);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onSelected(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent strip (Optional, based on status)
              Container(
                width: 4,
                color: _getStatusColor(report.status),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CategoryBadge(category: report.category, groupCount: report.groupCount),
                          _StatusBadge(status: report.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        report.activityTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Metadata
                      Text(
                        report.reporterName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${report.submissionId} • ${_getCategoryString(report.category)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Flagged Box (If applicable)
                      if (report.status == ReportStatus.flagged)
                        _buildFlaggedBox(),

                      const SizedBox(height: 16),
                      // Actions and Footer
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Submitted: ${DateFormat('MMM d, yyyy').format(report.createdAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildActionButtons(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlaggedBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Text(
                'Flagged by ${report.flaggedBy ?? "System"}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              report.flagReason,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (report.status == ReportStatus.flagged) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            label: 'Reject',
            onPressed: () {},
            color: const Color(0xFFFEF2F2),
            textColor: const Color(0xFFDC2626),
          ),
          const SizedBox(width: 8),
          _ActionButton(
            label: 'Override & Approve',
            onPressed: () {},
            color: const Color(0xFF10B981),
            textColor: Colors.white,
          ),
        ],
      );
    } else if (report.status == ReportStatus.pending) {
      return _ActionButton(
        label: 'Approve',
        onPressed: () {},
        color: const Color(0xFF10B981),
        textColor: Colors.white,
      );
    }
    return const SizedBox.shrink();
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.flagged: return const Color(0xFFDC2626);
      case ReportStatus.pending: return const Color(0xFFFBBF24);
      case ReportStatus.approved:
      case ReportStatus.resolved: return const Color(0xFF10B981);
      default: return Colors.transparent;
    }
  }

  String _getCategoryString(ReportCategory? category) {
    if (category == null) return 'General';
    switch (category) {
      case ReportCategory.theory: return 'Tourism Management';
      case ReportCategory.practical: return 'Heritage Studies';
      case ReportCategory.internship: return 'Sustainable Tourism';
      case ReportCategory.visits: return 'Event Management';
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final ReportCategory? category;
  final int? groupCount;

  const _CategoryBadge({required this.category, this.groupCount});

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? textColor;
    IconData? icon;
    String? label;

    if (category == null) {
      return const SizedBox.shrink();
    }

    switch (category!) {
      case ReportCategory.theory:
        bgColor = const Color(0xFFEBF5FF);
        textColor = const Color(0xFF3286C9);
        icon = Icons.menu_book_outlined;
        label = 'Theory';
        break;
      case ReportCategory.practical:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        icon = Icons.assignment_outlined;
        label = 'Practical';
        break;
      case ReportCategory.internship:
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFF97316);
        icon = Icons.home_repair_service_outlined;
        label = 'Internship';
        break;
      case ReportCategory.visits:
        bgColor = const Color(0xFFFDF2F8);
        textColor = const Color(0xFFDB2777);
        icon = Icons.location_on_outlined;
        label = 'Visits';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (groupCount != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Group ($groupCount)',
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReportStatus? status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? textColor;
    IconData? icon;
    String? label;

    if (status == null) {
      return const SizedBox.shrink();
    }

    switch (status!) {
      case ReportStatus.pending:
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        icon = Icons.access_time;
        label = 'Pending Review';
        break;
      case ReportStatus.flagged:
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.outlined_flag;
        label = 'Flagged';
        break;
      case ReportStatus.approved:
      case ReportStatus.resolved:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outline;
        label = 'Approved';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
