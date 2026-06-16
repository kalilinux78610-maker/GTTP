import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/reports/presentation/screens/student_progress_screen.dart';
import '../../data/models/course_model.dart';
import '../../data/models/course_module_model.dart';
import '../providers/course_details_provider.dart';
import '../utils/course_links.dart';
import '../widgets/course_cover_image.dart';

class TeacherCourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;

  const TeacherCourseDetailsScreen({super.key, required this.courseId});

  @override
  ConsumerState<TeacherCourseDetailsScreen> createState() => _TeacherCourseDetailsScreenState();
}

class _TeacherCourseDetailsScreenState extends ConsumerState<TeacherCourseDetailsScreen> {
  bool _readMoreExpanded = false;

  static const _moduleAccentColors = [
    Color(0xFF2976C7),
    Color(0xFFE67E22),
    Color(0xFF27AE60),
    Color(0xFF1ABC9C),
  ];

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(courseDetailsProvider(widget.courseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: detailsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF398FDE)),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load course', style: TextStyle(color: Colors.red.shade400)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(courseDetailsProvider(widget.courseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (course) {
          if (course == null) {
            return const Center(child: Text('Course not found.'));
          }

          final bottomPad = MediaQuery.of(context).padding.bottom + 100;
          final progress = (course.progressPercent ?? 0).clamp(0, 100);
          final hasDates = (course.startDate?.isNotEmpty ?? false) ||
              (course.endDate?.isNotEmpty ?? false);

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(context, course),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildInfoCard(
                        course: course,
                        progress: progress,
                        hasDates: hasDates,
                      ),
                    ),
                  ),
                  _buildEnrolledStudentsSection(course.id),
                  if (course.modules.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Course Modules (${course.modules.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181C1F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...course.modules.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: _buildModuleCard(
                              context,
                              course: course,
                              module: e.value,
                              index: e.key,
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, CourseModel course) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CourseCoverImage(
            imageUrl: course.thumbnailUrl,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _overlayIconButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _overlayIconButton(
              icon: Icons.share_outlined,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required CourseModel course,
    required int progress,
    required bool hasDates,
  }) {
    final description = course.description.isNotEmpty
        ? course.description
        : 'No description available for this course.';
    final showReadMore = description.length > 120;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C1F),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            maxLines: _readMoreExpanded ? null : 3,
            overflow: _readMoreExpanded ? null : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          if (showReadMore)
            GestureDetector(
              onTap: () => setState(() => _readMoreExpanded = !_readMoreExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _readMoreExpanded ? 'Read less' : 'Read more',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF398FDE),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (course.enrollmentType != null && course.enrollmentType!.isNotEmpty)
                _outlineBadge(
                  _enrollmentLabel(course.enrollmentType!),
                  const Color(0xFF1F9254),
                ),
              if (course.status != null && course.status!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F9254),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _titleCase(course.status!),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (hasDates) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (course.startDate != null && course.startDate!.isNotEmpty)
                  Expanded(
                    child: _dateColumn(
                      Icons.calendar_today_outlined,
                      'Start: ${course.startDate}',
                    ),
                  ),
                if (course.endDate != null && course.endDate!.isNotEmpty)
                  Expanded(
                    child: _dateColumn(
                      Icons.event_outlined,
                      'End: ${course.endDate}',
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Material(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openCourseUrl(
                context,
                course.pdfUrl,
                errorMessage: 'Course PDF not available.',
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.download_outlined, color: Color(0xFF398FDE)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Download Course PDF',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF181C1F),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _PendingApprovalsWidget(courseId: course.id),

        ],
      ),
    );
  }

  Widget _dateColumn(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _outlineBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required CourseModel course,
    required CourseModuleModel module,
    required int index,
  }) {
    final accent = _moduleAccentColors[index % _moduleAccentColors.length];
    final typeStyle = _typeBadgeStyle(module.typeLabel);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/courses/${course.id}/modules/${module.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF181C1F),
                          ),
                        ),
                        if (module.typeLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeStyle.bg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _titleCase(module.typeLabel),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: typeStyle.fg,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _moduleStatusIcon(module),
                ],
              ),
              if (module.durationHours != null || module.dueDate != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (module.durationHours != null) ...[
                      const Icon(Icons.schedule, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        '${module.durationHours} hours',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (module.dueDate != null) ...[
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${module.dueDate}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ],
                ),
              ],
              if (module.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: module.tags.map((t) => _tagChip(t)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _moduleStatusIcon(CourseModuleModel module) {
    // Teachers and Principals don't have locked modules or personal completion status.
    // They just preview the module content.
    return const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 24);
  }

  Widget _tagChip(String tag) {
    final style = _tagStyle(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: style.fg),
      ),
    );
  }

  ({Color bg, Color fg}) _typeBadgeStyle(String type) {
    final t = type.toLowerCase();
    if (t.contains('report') || t.contains('upload')) {
      return (bg: const Color(0xFFFFF3E8), fg: const Color(0xFFEA7A1A));
    }
    if (t.contains('visit') || t.contains('industry')) {
      return (bg: const Color(0xFFE8F8EF), fg: const Color(0xFF1F9254));
    }
    if (t.contains('assign')) {
      return (bg: const Color(0xFFE8FAF8), fg: const Color(0xFF1ABC9C));
    }
    return (bg: const Color(0xFFE8F4FD), fg: const Color(0xFF2976C7));
  }

  ({Color bg, Color fg}) _tagStyle(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('quiz')) {
      return (bg: const Color(0xFFF3E8FF), fg: const Color(0xFF7C3AED));
    }
    if (t.contains('upload') || t.contains('required')) {
      return (bg: const Color(0xFFFEE8E8), fg: const Color(0xFFDC2626));
    }
    if (t.contains('cert')) {
      return (bg: const Color(0xFFFFF3E8), fg: const Color(0xFFEA7A1A));
    }
    if (t.contains('particip')) {
      return (bg: const Color(0xFFE8F8EF), fg: const Color(0xFF1F9254));
    }
    return (bg: const Color(0xFFF1F4F8), fg: const Color(0xFF6B7280));
  }

  String _enrollmentLabel(String value) {
    final k = value.toLowerCase();
    if (k.contains('open')) return 'Open Enrollment';
    if (k.contains('invite')) return 'Invite Only';
    if (k.contains('batch')) return 'Batch';
    return _titleCase(value);
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(RegExp(r'[\s_]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildEnrolledStudentsSection(String courseId) {
    return Consumer(
      builder: (context, ref, _) {
        final studentsAsync = ref.watch(courseEnrolledStudentsProvider(courseId));

        return studentsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Color(0xFF398FDE)),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Failed to load students: $error',
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ),
          data: (students) {
            if (students.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No students enrolled yet.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Enrolled Students from Your Class (${students.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181C1F),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStudentList(students),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> students) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: students.map((student) {
          final progress = int.tryParse(student['progress_percent']?.toString() ?? '0') ?? 0;
          Color progressColor;
          if (progress >= 75) {
            progressColor = const Color(0xFF10B981); // Green
          } else if (progress >= 50) {
            progressColor = const Color(0xFFF59E0B); // Orange
          } else {
            progressColor = const Color(0xFFEF4444); // Red
          }

          final rawName = student['name']?.toString() ?? 'Student';
          final nameParts = rawName.trim().split(' ');
          final initials = nameParts.length > 1
              ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
              : nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : 'S';

          final roll = student['roll_no']?.toString() ?? 'N/A';
          final className = student['class']?.toString() ?? 'N/A';

          final isLast = student == students.last;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final studentId = student['id']?.toString() ?? student['student_id']?.toString();
                if (studentId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentProgressScreen(studentId: studentId),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF7C3AED),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rawName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF181C1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roll: $roll | Class: $className',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$progress%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: progressColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PendingApprovalsWidget extends ConsumerWidget {
  final String courseId;

  const _PendingApprovalsWidget({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(coursePendingSubmissionsProvider(courseId));

    return pendingAsync.when(
      data: (pendingItems) {
        if (pendingItems.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6), // Light orange background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment_late_outlined,
                  color: Color(0xFFF57C00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pendingItems.length} Items Pending Approval',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/courses/$courseId/pending-submissions');
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFF57C00),
                ),
                child: const Text(
                  'Review Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
