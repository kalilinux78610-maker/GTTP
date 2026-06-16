import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../data/models/course_module_model.dart';
import '../../data/models/course_session_model.dart';
import '../providers/course_module_provider.dart';
import '../providers/course_details_provider.dart';
import '../utils/course_links.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:gttp/features/courses/presentation/widgets/course_module_video_player.dart';
import 'package:gttp/features/courses/data/datasources/courses_remote_datasource.dart';
import 'package:gttp/features/courses/presentation/screens/material_viewer_screen.dart';

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
    final userAsync = ref.watch(userModelProvider);
    final isStudent = userAsync.maybeWhen(
      data: (user) =>
          AppUserRole.fromApi(user?.effectiveRole) == AppUserRole.student,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: moduleAsync.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_back),
                    const Spacer(),
                    Container(height: 24, width: 80, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 28, width: 250, color: Colors.grey),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE8ECF0), height: 1),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8ECF0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, width: 200, color: Colors.grey),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(height: 16, width: 120, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(height: 16, width: 140, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8ECF0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(height: 44, width: 44, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 16, width: 120, color: Colors.grey),
                                const SizedBox(height: 4),
                                Container(height: 14, width: 150, color: Colors.grey),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 48, width: double.infinity, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(height: 24, width: 220, color: Colors.grey),
                const SizedBox(height: 12),
                ...List.generate(2, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8ECF0)),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load module',
                style: TextStyle(color: Colors.red.shade400),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(
                  courseModuleProvider((
                    courseId: courseId,
                    moduleId: moduleId,
                  )),
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
          return _ModuleBody(module: module, isStudent: isStudent);
        },
      ),
    );
  }
}

class _ModuleBody extends ConsumerWidget {
  const _ModuleBody({required this.module, required this.isStudent});

  final CourseModuleModel module;
  final bool isStudent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = module;
    final bottomPad = MediaQuery.of(context).padding.bottom + 100;
    final typeStyle = _typeBadgeStyle(m.typeLabel);

    final displaySessions = m.sessions;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        bottomPad,
      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
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
                  _metaRow(
                    Icons.schedule,
                    'Duration: ${m.durationHours} hours',
                  ),
                if (m.dueDate != null) ...[
                  const SizedBox(height: 8),
                  _metaRow(
                    Icons.calendar_today_outlined,
                    'Deadline: ${m.dueDate}',
                  ),
                ],
              ],
            ),
          ),
          if (m.externalUrl != null && m.externalUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            if (m.externalUrl != null &&
                (m.externalUrl!.contains('youtube.com') ||
                 m.externalUrl!.contains('youtu.be') ||
                 m.externalUrl!.endsWith('.mp4')))
              CourseModuleVideoPlayer(
                videoUrl: m.externalUrl!,
                onVideoCompleted: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video completed! Module marked as finished.'),
                      backgroundColor: Color(0xFF1F9254),
                    ),
                  );
                  // Silently mark module complete in background and refresh course details
                  ref.read(coursesRemoteDataSourceProvider)
                      .markModuleComplete(m.courseId, m.id)
                      .then((data) {
                    ref.invalidate(courseDetailsProvider(m.courseId));
                    ref.invalidate(courseModuleProvider((courseId: m.courseId, moduleId: m.id)));
                  }).catchError((_) {});
                },
              )
            else
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
                      child: const Icon(
                        Icons.download_outlined,
                        color: Color(0xFF398FDE),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
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
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
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
                    onPressed: () {
                      if (m.materialUrl != null && m.materialUrl!.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MaterialViewerScreen(
                            url: m.materialUrl!,
                            title: m.materialLabel ?? 'Module Material',
                          ),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Module material not available.')),
                        );
                      }
                    },
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

          if (displaySessions.isNotEmpty) ...[
            Text(
              'Sessions / Classes (${displaySessions.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C1F),
              ),
            ),
            const SizedBox(height: 12),
            ...displaySessions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionCard(session: s, isStudent: isStudent),
              ),
            ),
          ] else ...[
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
                  'No requirements or sessions listed for this module.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              )
            else
              ...m.requirements.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RequirementCard(requirement: r, isStudent: isStudent),
                ),
              ),
          ],
          const SizedBox(height: 24),
          if (isStudent) ...[
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
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF1F9254),
                      size: 20,
                    ),
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
            else if (m.mcqEnabled)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final cId = GoRouterState.of(context).pathParameters['id'];
                    final mId = GoRouterState.of(context).pathParameters['moduleId'];
                    if (cId != null && mId != null) {
                      context.push('/courses/$cId/modules/$mId/quiz');
                    }
                  },
                  icon: const Icon(Icons.quiz_outlined, size: 18),
                  label: const Text('Take MCQ Quiz'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED), // Purple for quiz
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ] else ...[
            // Teacher / Admin specific Module Design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Module Submissions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatBadge(
                        '12',
                        'Completed',
                        const Color(0xFF1F9254),
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        '5',
                        'Pending Review',
                        const Color(0xFFD97706),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push(
                        '/dashboard/assignment-review/${m.courseId}/${m.id}',
                      ),
                      icon: const Icon(Icons.fact_check_outlined, size: 18),
                      label: const Text('Review Pending Assignments'),
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
          ],
        ],
      ),
    );
  }

  Widget _buildStatBadge(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
  const _RequirementCard({required this.requirement, required this.isStudent});

  final CourseModuleRequirementModel requirement;
  final bool isStudent;

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
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          if (requirement.needsAdminApproval && pending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4ED),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Needs Admin Approval',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEA7A1A),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Upload Box UI (Only for students)
          if (isStudent) ...[
            InkWell(
              onTap: () {
                final cId = GoRouterState.of(context).pathParameters['id'];
                final mId = GoRouterState.of(context).pathParameters['moduleId'];
                if (cId != null && mId != null) {
                  context.push('/courses/$cId/modules/$mId/submit-report');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: DottedBorder(
                options: const RoundedRectDottedBorderOptions(
                  color: Color(0xFFCBD5E1),
                  strokeWidth: 1.5,
                  dashPattern: [6, 4],
                  radius: Radius.circular(12),
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.file_upload_outlined,
                        size: 32,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attach_file, size: 16, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 4),
                          const Text(
                            'Choose File',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Accepted: PDF, DOC, DOCX | Max: 10 MB',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            if (!pending && !approved) ...[
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Submitted: Jun 18, 2026',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
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
                  if (requirement.rollNo != null ||
                      requirement.className != null)
                    Text(
                      [
                        if (requirement.rollNo != null)
                          'Roll No: ${requirement.rollNo}',
                        if (requirement.className != null)
                          'Class: ${requirement.className}',
                      ].join(' | '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
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
                    'Approved by Coordinator',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F9254),
                    ),
                  ),
                ],
              ),
            )
          else if (pending && requirement.studentName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF5C842)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'View only - Approval pending from coordinator',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.isStudent});

  final CourseSessionModel session;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
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
                  session.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF181C1F),
                  ),
                ),
              ),
              if (session.isCompleted)
                Container(
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
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F9254),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (session.contentType != null && session.contentType!.isNotEmpty)
                _buildBadge(session.contentType!, Icons.category_outlined, const Color(0xFF398FDE), const Color(0xFFE8F4FD)),
              if (session.deliveryMode != null && session.deliveryMode!.isNotEmpty)
                _buildBadge(session.deliveryMode!, Icons.videocam_outlined, const Color(0xFFD97706), const Color(0xFFFFF8E6)),
            ],
          ),
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              session.description!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 12),
          if (session.monthLabel != null || session.startDate != null)
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  [
                    if (session.monthLabel != null) session.monthLabel,
                    if (session.startDate != null) 'From: ${session.startDate}',
                    if (session.endDate != null) 'To: ${session.endDate}',
                  ].join(' | '),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          if (session.submissionDeadline != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFEA7A1A)),
                const SizedBox(width: 6),
                Text(
                  'Deadline: ${session.submissionDeadline}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFEA7A1A), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (session.fileUrl != null && session.fileUrl!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => openCourseUrl(context, session.fileUrl),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  session.contentType?.toLowerCase() == 'mcq test' ? 'Take Test' : 'Open Material',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (isStudent)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final cId = GoRouterState.of(context).pathParameters['id'];
                  final mId = GoRouterState.of(context).pathParameters['moduleId'];
                  if (cId != null && mId != null) {
                    context.push('/courses/$cId/modules/$mId/submit-report?submoduleId=${session.id}');
                  }
                },
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: const Text('Submit Report'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF398FDE),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
