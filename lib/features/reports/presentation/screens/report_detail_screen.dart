import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/presentation/providers/reports_provider.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryBlue),
        ),
      ),
      body: reportAsync.when(
        data: (report) => _buildDetail(context, ref, report),
        loading: () => Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 32),
                Container(height: 14, width: 120, color: Colors.grey),
                const SizedBox(height: 16),
                ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 12, width: 80, color: Colors.grey),
                          const SizedBox(height: 4),
                          Container(height: 14, width: 140, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 32),
                Container(height: 14, width: 100, color: Colors.grey),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 12, width: 80, color: Colors.grey),
                          const SizedBox(height: 4),
                          Container(height: 14, width: 140, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 16, width: 150, color: Colors.grey),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: reportAsync.maybeWhen(
        data: (report) => _buildBottomActions(context, ref, report),
        orElse: () => null,
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, ReportModel report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(report),
          const SizedBox(height: 32),
          _buildSectionTitle('School Information'),
          _buildInfoTile(Icons.school, 'School Name', report.schoolName),
          _buildInfoTile(Icons.person, 'Reporter', report.reporterName),
          _buildInfoTile(Icons.calendar_today, 'Date Reported', 
              DateFormat('MMMM dd, yyyy - hh:mm a').format(report.createdAt)),
          const SizedBox(height: 32),
          _buildSectionTitle('Flag Details'),
          _buildInfoTile(Icons.warning, 'Reason', report.flagReason, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Activity Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.1)),
            ),
            child: Text(
              report.description,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textBody,
                height: 1.5,
              ),
            ),
          ),
          if (report.overrideComments != null) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Override Comments'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Text(
                report.overrideComments!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(ReportModel report) {
    Color color;
    switch (report.status) {
      case ReportStatus.pending: color = Colors.orange; break;
      case ReportStatus.flagged: color = Colors.red; break;
      case ReportStatus.overridden: color = Colors.blue; break;
      case ReportStatus.completed:
      case ReportStatus.resolved: color = Colors.green; break;
      default: color = Colors.grey; break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.report_problem, color: color, size: 48),
          const SizedBox(height: 8),
          Text(
            report.status.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color ?? AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref, ReportModel report) {
    if (report.status != ReportStatus.flagged && report.status != ReportStatus.pending) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRejectDialog(context, ref, report.submissionId),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final success = await ref.read(flaggedReportsProvider.notifier).approveReport(report.submissionId, 'completed');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Report approved' : 'Failed to approve report'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) context.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Approve'),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String submissionId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Report'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(ctx);
              final success = await ref.read(flaggedReportsProvider.notifier).rejectReport(submissionId, reason: controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Report rejected' : 'Failed to reject report'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) context.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}
