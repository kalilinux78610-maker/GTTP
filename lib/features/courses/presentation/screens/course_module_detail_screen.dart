import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/course_module_model.dart';
import '../providers/course_module_provider.dart';
import '../utils/course_links.dart';

class CourseModuleDetailScreen extends ConsumerWidget {
  final String courseId;
  final String moduleId;

  const CourseModuleDetailScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleAsync = ref.watch(
      courseModuleProvider((courseId: courseId, moduleId: moduleId)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: moduleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF398FDE)),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load module', style: TextStyle(color: Colors.red.shade400)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(
                  courseModuleProvider((courseId: courseId, moduleId: moduleId)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (module) {
          if (module == null) {
            return const Center(child: Text('Module not found.'));
          }
          return _ModuleBody(module: module);
        },
      ),
    );
  }
}

class _ModuleBody extends StatelessWidget {
  const _ModuleBody({required this.module});

  final CourseModuleModel module;

  @override
  Widget build(BuildContext context) {
    final m = module;
    final bottomPad = MediaQuery.of(context).padding.bottom + 100;
    final typeStyle = _typeBadgeStyle(m.typeLabel);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF181C1F)),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              if (m.typeLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: typeStyle.bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    m.typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: typeStyle.fg,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            m.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C1F),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE8ECF0), height: 1),
          const SizedBox(height: 16),
          if (m.submissionStatus != null && m.submissionStatus!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF5C842)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  const Icon(Icons.emoji_events_outlined, color: Color(0xFFD97706), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.submissionStatus!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (m.submissionStatus != null && m.submissionStatus!.isNotEmpty)
            const SizedBox(height: 16),
          _infoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF181C1F),
                  ),
                ),
                const SizedBox(height: 12),
                if (m.durationHours != null)
                  _metaRow(Icons.schedule, 'Duration: ${m.durationHours} hours'),
                if (m.dueDate != null) ...[
                  const SizedBox(height: 8),
                  _metaRow(Icons.calendar_today_outlined, 'Deadline: ${m.dueDate}'),
                ],
              ],
            ),
          ),
          if (m.externalUrl != null && m.externalUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => openCourseUrl(context, m.externalUrl),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open External Link'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF398FDE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _infoCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download_outlined, color: Color(0xFF398FDE)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.folder_outlined, size: 16, color: Color(0xFF6B7280)),
                              SizedBox(width: 6),
                              Text(
                                'Module Material',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF181C1F),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            m.materialLabel ?? 'Guidelines Document',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => openCourseUrl(
                      context,
                      m.materialUrl,
                      errorMessage: 'Module material not available.',
                    ),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Download Material'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF398FDE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '📋 Requirements Checklist (${m.requirements.length} items)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C1F),
            ),
          ),
          const SizedBox(height: 12),
          if (m.requirements.isEmpty)
            _infoCard(
              child: const Text(
                'No requirements listed for this module.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            )
          else
            ...m.requirements.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequirementCard(requirement: r),
              ),
            ),
          const SizedBox(height: 24),
          if (m.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1F9254)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF1F9254), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Module Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F9254),
                    ),
                  ),
                ],
              ),
            )
          else if (m.requirements.isEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module completion tracking will be connected to the API.'),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Complete'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1F9254),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: child,
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  ({Color bg, Color fg}) _typeBadgeStyle(String type) {
    final t = type.toLowerCase();
    if (t.contains('report') || t.contains('upload')) {
      return (bg: const Color(0xFFFFF3E8), fg: const Color(0xFFEA7A1A));
    }
    return (bg: const Color(0xFFE8F4FD), fg: const Color(0xFF2976C7));
  }
}

class _RequirementCard extends StatelessWidget {
  const _RequirementCard({required this.requirement});

  final CourseModuleRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final approved = requirement.isApproved;
    final pending = requirement.isPending && !approved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${requirement.title} *',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF181C1F),
                  ),
                ),
              ),
              _statusBadge(approved, pending),
            ],
          ),
          if (requirement.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              requirement.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Upload Box UI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF398FDE).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: Color(0xFF398FDE),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Accepted: PDF, DOC, DOCX | Max: 10MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File upload will be integrated with API')),
                    );
                  },
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Choose File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF398FDE),
                    side: const BorderSide(color: Color(0xFF398FDE)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (requirement.needsAdminApproval && pending) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Needs Admin Approval',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEA7A1A),
                ),
              ),
            ),
          ],
          if (requirement.studentName != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student Submission:',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      OutlinedButton.icon(
                        onPressed: requirement.fileUrl != null
                            ? () => openCourseUrl(context, requirement.fileUrl)
                            : null,
                        icon: const Icon(Icons.download_outlined, size: 14),
                        label: const Text('View File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF398FDE),
                          side: const BorderSide(color: Color(0xFF398FDE)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitted by: ${requirement.studentName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF181C1F),
                    ),
                  ),
                  if (requirement.rollNo != null || requirement.className != null)
                    Text(
                      [
                        if (requirement.rollNo != null) 'Roll No: ${requirement.rollNo}',
                        if (requirement.className != null) 'Class: ${requirement.className}',
                      ].join(' | '),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                ],
              ),
            ),
          ],
          if (requirement.submittedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Submitted: ${requirement.submittedAt}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
          const SizedBox(height: 12),
          if (approved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1F9254)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF1F9254), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Approved by Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F9254),
                    ),
                  ),
                ],
              ),
            )
          else if (pending && requirement.studentName != null)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Approve action will connect to API when available.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F9254),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reject action will connect to API when available.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool approved, bool pending) {
    if (approved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFAF1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Color(0xFF1F9254)),
            SizedBox(width: 4),
            Text(
              'Approved',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F9254),
              ),
            ),
          ],
        ),
      );
    }
    if (pending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14, color: Color(0xFFEA7A1A)),
            SizedBox(width: 4),
            Text(
              'Pending Review',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEA7A1A),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
