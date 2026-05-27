import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignmentReviewScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;

  const AssignmentReviewScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  State<AssignmentReviewScreen> createState() => _AssignmentReviewScreenState();
}

class _AssignmentReviewScreenState extends State<AssignmentReviewScreen> {
  String status = 'Pending Review';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tourism Industry Analysis Report',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusBanner(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildMaterialSection(),
            const SizedBox(height: 24),
            _buildRequirementsChecklist(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'Approved':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        text = 'Approved — Great Work!';
        break;
      case 'Rejected':
        color = Colors.red;
        icon = Icons.error_outline;
        text = 'Rejected — Needs Revision';
        break;
      case 'Pending Review':
      default:
        color = Colors.orange;
        icon = Icons.info_outline;
        text = 'Submitted — Awaiting Review';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tourism Industry Analysis Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'Student: Amit Verma',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'Submitted: Oct 20, 2024',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Module Material',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading course material...')),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Download Material'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F62FE),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requirements Checklist (2 items)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        _buildChecklistItem(
          title: 'Submit your analysis report',
          description: 'Minimum 500 words containing your tourism analysis.',
          currentStatus: status,
          statusColor: status == 'Approved' 
              ? Colors.green 
              : status == 'Rejected' 
                  ? Colors.red 
                  : Colors.orange,
          showActions: status == 'Pending Review',
        ),
        const SizedBox(height: 16),
        _buildChecklistItem(
          title: 'Research Data Sources',
          description: 'Provide properly formatted citations.',
          currentStatus: 'Approved',
          statusColor: Colors.green,
          showActions: false,
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required String description,
    required String currentStatus,
    required Color statusColor,
    required bool showActions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Student Submission',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Student Pull Request/Document...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F62FE),
                  side: const BorderSide(color: Color(0xFF0F62FE)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('View PR', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        status = 'Approved';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Assignment Approved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        status = 'Rejected';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Assignment Rejected. Student will be notified.'),
                          backgroundColor: Colors.red.shade600,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
