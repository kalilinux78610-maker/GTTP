import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/presentation/providers/reports_provider.dart';
import 'package:intl/intl.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
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
      case ReportStatus.approved:
      case ReportStatus.resolved: color = Colors.green; break;
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
              onPressed: () => _showOverrideDialog(context, ref, report.id),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Override', style: TextStyle(color: Colors.blue)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final success = await ref.read(flaggedReportsProvider.notifier).resolveReport(report.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Report resolved' : 'Failed to resolve report'),
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
              child: const Text('Resolve'),
            ),
          ),
        ],
      ),
    );
  }

  void _showOverrideDialog(BuildContext context, WidgetRef ref, String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Override Report'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter reason for override...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(ctx);
              final success = await ref.read(flaggedReportsProvider.notifier).overrideReport(id, controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Report overridden' : 'Failed to override report'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) context.pop();
              }
            },
            child: const Text('Confirm Override'),
          ),
        ],
      ),
    );
  }
}
