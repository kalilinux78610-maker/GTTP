import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gttp/features/downloads/domain/services/pdf_download_service.dart';
import '../../../../core/router/navigation_utils.dart';
import 'offline_pdf_viewer_screen.dart';
import 'material_viewer_screen.dart';
import '../../data/models/course_model.dart';
import '../../data/models/course_module_model.dart';
import '../providers/course_details_provider.dart';
import '../providers/courses_provider.dart';
import '../../data/repositories/courses_repository_impl.dart';
import 'package:gttp/features/certificates/presentation/providers/certificates_provider.dart';
import 'package:gttp/features/certificates/data/models/certificate_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

import '../widgets/course_cover_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
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
    final roleAsync = ref.watch(currentUserRoleProvider);
    final isStudent = roleAsync.value == AppUserRole.student;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: detailsAsync.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Container(color: Colors.grey),
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 24, width: 250, color: Colors.grey),
                          const SizedBox(height: 10),
                          Container(
                            height: 14,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 14,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Container(height: 14, width: 200, color: Colors.grey),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                height: 24,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 24,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                height: 16,
                                width: 120,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 16),
                              Container(
                                height: 16,
                                width: 120,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 14,
                                width: 100,
                                color: Colors.grey,
                              ),
                              Container(
                                height: 14,
                                width: 50,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(height: 20, width: 150, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load course',
                style: TextStyle(color: Colors.red.shade400),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(courseDetailsProvider(widget.courseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (course) {
          if (course == null) {
            return const Center(child: Text('Course not found.'));
          }

          final progress = (course.progressPercent ?? 0).clamp(0, 100);
          final hasDates =
              (course.startDate?.isNotEmpty ?? false) ||
              (course.endDate?.isNotEmpty ?? false);

          return SafeArea(
            top: true,
            bottom: true,
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(courseDetailsProvider(widget.courseId)),
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
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
                        isStudent: isStudent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          isStudent: isStudent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
            top: 16,
            left: 16,
            child: _overlayIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => NavigationUtils.safePop(context),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _overlayIconButton(
              icon: Icons.share_outlined,
              onTap: () {
                SharePlus.instance.share(ShareParams(
                  text: 'Check out this course: ${course.title}\n\nDownload the GTTP app to learn more!',
                  subject: course.title,
                ));
              },
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildInfoCard({
    required CourseModel course,
    required int progress,
    required bool hasDates,
    required bool isStudent,
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
          if (!_readMoreExpanded)
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            )
          else
            Html(
              data: course.htmlDescription.isNotEmpty
                  ? course.htmlDescription
                  : description,
              style: {
                "body": Style(
                  fontSize: FontSize(14),
                  color: const Color(0xFF6B7280),
                  lineHeight: const LineHeight(1.5),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(
                  margin: Margins.only(bottom: 8),
                  padding: HtmlPaddings.zero,
                ),
                "ul": Style(
                  margin: Margins.only(bottom: 8, top: 0),
                  padding: HtmlPaddings.only(left: 20),
                ),
                "li": Style(margin: Margins.only(bottom: 4)),
              },
            ),
          if (showReadMore)
            GestureDetector(
              onTap: () =>
                  setState(() => _readMoreExpanded = !_readMoreExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
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
              if (course.enrollmentType != null &&
                  course.enrollmentType!.isNotEmpty)
                _outlineBadge(
                  _enrollmentLabel(course.enrollmentType!),
                  const Color(0xFF1F9254),
                ),
              if (course.status != null && course.status!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
          _buildCourseMetaGrid(course),
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
          if (course.pdfUrl != null && course.pdfUrl!.isNotEmpty)
            _PdfDownloadButton(
              courseId: course.id,
              pdfUrl: course.pdfUrl!,
              title: course.title,
            ),
          const SizedBox(height: 20),
          if (course.isEnrolled && isStudent) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                Text(
                  '${progress.toInt()}% Complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181C1F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8ECF0),
                color: const Color(0xFF398FDE),
              ),
            ),
            const SizedBox(height: 16),
            _CourseCertificatesSection(courseId: course.id),
          ] else if (course.isEnrollable && isStudent)
            _EnrollButton(courseId: course.id),
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

  Widget _buildCourseMetaGrid(CourseModel course) {
    final List<Widget> items = [];

    if (course.instructor != null && course.instructor!.isNotEmpty) {
      items.add(_metaItem(Icons.person_outline, 'Instructor', course.instructor!));
    }
    if (course.level != null && course.level!.isNotEmpty) {
      items.add(_metaItem(Icons.bar_chart_outlined, 'Level', course.level!));
    }
    if (course.duration != null && course.duration!.isNotEmpty) {
      items.add(_metaItem(Icons.schedule, 'Duration', course.duration!));
    }
    if (course.passPercentage != null && course.passPercentage!.isNotEmpty) {
      final val = course.passPercentage!.endsWith('%') ? course.passPercentage! : '${course.passPercentage}%';
      items.add(_metaItem(Icons.verified_outlined, 'Pass Criteria', val));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(color: Color(0xFFF3F4F6), height: 1),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: EdgeInsets.zero,
          children: items,
        ),
      ],
    );
  }

  Widget _metaItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF4B5563)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
    required bool isStudent,
  }) {
    final accent = _moduleAccentColors[index % _moduleAccentColors.length];
    final typeStyle = _typeBadgeStyle(module.typeLabel);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (!course.isEnrolled && isStudent)
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enroll to view this module.'),
                  ),
                );
              }
            : (module.isLocked && isStudent)
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complete previous modules to unlock.'),
                  ),
                );
              }
            : () => context.push('/courses/${course.id}/modules/${module.id}'),
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
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${module.durationHours} hours',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (module.dueDate != null) ...[
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: module.isExpired ? Colors.red.shade400 : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        module.isExpired ? 'Expired: ${module.dueDate}' : 'Due: ${module.dueDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: module.isExpired ? Colors.red.shade400 : const Color(0xFF6B7280),
                        ),
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
    if (module.isLocked) {
      return const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF), size: 22);
    }
    if (module.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Color(0xFF1F9254),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
      ),
    );
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: style.fg,
        ),
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
}

class _PdfDownloadButton extends ConsumerStatefulWidget {
  final String courseId;
  final String pdfUrl;
  final String title;

  const _PdfDownloadButton({
    required this.courseId,
    required this.pdfUrl,
    required this.title,
  });

  @override
  ConsumerState<_PdfDownloadButton> createState() => _PdfDownloadButtonState();
}

class _PdfDownloadButtonState extends ConsumerState<_PdfDownloadButton> {
  bool _isDownloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final service = ref.read(pdfDownloadServiceProvider);
    final path = await service.getOfflinePdfPath(widget.courseId);
    if (mounted) {
      setState(() {
        _localPath = path;
      });
    }
  }

  Future<void> _download() async {
    setState(() {
      _isDownloading = true;
    });
    final service = ref.read(pdfDownloadServiceProvider);
    final path = await service.downloadCoursePdf(
      widget.courseId,
      widget.pdfUrl,
    );
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _localPath = path;
      });
      if (path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to download PDF')));
      }
    }
  }

  void _openOffline() {
    if (_localPath != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfflinePdfViewerScreen(
            title: widget.title,
            localPath: _localPath!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDownloaded = _localPath != null;

    return Material(
      color: hasDownloaded ? const Color(0xFFE8F5E9) : const Color(0xFFF1F4F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (hasDownloaded) {
            _openOffline();
          } else if (!_isDownloading) {
            _download();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (_isDownloading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  hasDownloaded
                      ? Icons.check_circle_outline
                      : Icons.download_outlined,
                  color: hasDownloaded ? Colors.green : const Color(0xFF398FDE),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isDownloading
                      ? 'Downloading...'
                      : (hasDownloaded
                            ? 'Read Offline'
                            : 'Download Course PDF'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: hasDownloaded
                        ? Colors.green.shade800
                        : const Color(0xFF181C1F),
                  ),
                ),
              ),
              if (!hasDownloaded && !_isDownloading)
                Icon(
                  Icons.cloud_download_outlined,
                  color: Colors.grey.shade500,
                ),
              if (hasDownloaded)
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(pdfDownloadServiceProvider)
                        .deleteOfflinePdf(widget.courseId);
                    _checkStatus();
                  },
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrollButton extends ConsumerStatefulWidget {
  final String courseId;

  const _EnrollButton({required this.courseId});

  @override
  ConsumerState<_EnrollButton> createState() => _EnrollButtonState();
}

class _EnrollButtonState extends ConsumerState<_EnrollButton> {
  bool _isEnrolling = false;

  Future<void> _enroll() async {
    setState(() => _isEnrolling = true);
    try {
      final repository = ref.read(coursesRepositoryProvider);
      await repository.enrollCourse(widget.courseId);

      if (mounted) {
        ref.invalidate(coursesProvider);
        ref.invalidate(courseDetailsProvider(widget.courseId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Successfully enrolled!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isEnrolling ? null : _enroll,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF398FDE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isEnrolling
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Enroll Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _CourseCertificatesSection extends ConsumerWidget {
  final String courseId;

  const _CourseCertificatesSection({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(courseCertificatesProvider(courseId));

    return certificatesAsync.when(
      data: (certificates) {
        if (certificates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Certificates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C1F),
              ),
            ),
            const SizedBox(height: 12),
            ...certificates.map((cert) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cert.type?.toLowerCase() == 'participation'
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.military_tech_outlined,
                    color: cert.type?.toLowerCase() == 'participation'
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF10B981),
                  ),
                ),
                title: Text(
                  cert.type != null ? 'Certificate of ${cert.type}' : 'Course Certificate',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  cert.issuedDate,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF3B82F6)),
                      onPressed: () => _viewCertificate(context, cert),
                      tooltip: 'View Certificate',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined, color: Color(0xFF398FDE)),
                      onPressed: () => _handleCertificate(context, cert),
                      tooltip: 'Download Certificate',
                    ),
                  ],
                ),
              ),
            )),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Future<void> _viewCertificate(BuildContext context, CertificateModel certificate) async {
    if (certificate.base64Pdf != null && certificate.base64Pdf!.isNotEmpty) {
      try {
        final bytes = base64Decode(certificate.base64Pdf!);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/certificate_${certificate.id}.pdf');
        await file.writeAsBytes(bytes);
        
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfflinePdfViewerScreen(
                title: certificate.title,
                localPath: file.path,
              ),
            ),
          );
        }
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open certificate: $e')),
          );
        }
      }
    }

    final urlString = certificate.certificateUrl;
    if (urlString != null && urlString.isNotEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MaterialViewerScreen(
              title: certificate.title,
              url: urlString,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No certificate available to view')),
        );
      }
    }
  }

  Future<void> _handleCertificate(BuildContext context, CertificateModel certificate) async {
    if (certificate.base64Pdf != null && certificate.base64Pdf!.isNotEmpty) {
      try {
        final bytes = base64Decode(certificate.base64Pdf!);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/certificate_${certificate.id}.pdf');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: 'My Certificate for ${certificate.courseName}',
        ));
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open certificate: $e')),
          );
        }
      }
    }

    final urlString = certificate.certificateUrl;
    if (urlString != null && urlString.isNotEmpty) {
      final uri = Uri.tryParse(urlString);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the certificate link')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No certificate available')),
        );
      }
    }
  }
}
