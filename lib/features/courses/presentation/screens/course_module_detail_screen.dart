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
import 'package:gttp/features/courses/presentation/screens/course_session_detail_screen.dart';
import 'package:gttp/features/courses/presentation/screens/material_viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gttp/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';

class CourseModuleDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;
  final Map<String, dynamic>? submissionData;

  const CourseModuleDetailScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    this.submissionData,
  });

  @override
  ConsumerState<CourseModuleDetailScreen> createState() => _CourseModuleDetailScreenState();
}

class _CourseModuleDetailScreenState extends ConsumerState<CourseModuleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final moduleAsync = ref.watch(
      courseModuleProvider((courseId: widget.courseId, moduleId: widget.moduleId)),
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
                    courseId: widget.courseId,
                    moduleId: widget.moduleId,
                  )),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        skipLoadingOnReload: true,
        data: (module) {
          if (module == null) {
            return const Center(child: Text('Module not found.'));
          }

          var m = module;
          // Inject submission data if available from the pending submissions screen
          if (widget.submissionData != null && m.requirements.isNotEmpty) {
            final sub = widget.submissionData!;
            final reqs = m.requirements.map((req) {
              return CourseModuleRequirementModel(
                id: req.id,
                title: req.title,
                description: req.description,
                status: sub['status']?.toString() ?? 'pending_review',
                needsAdminApproval: req.needsAdminApproval,
                studentName: sub['student_name']?.toString() ?? req.studentName,
                rollNo: sub['roll_no']?.toString() ?? req.rollNo,
                className: sub['class']?.toString() ?? req.className,
                submittedAt: sub['submitted_at']?.toString() ?? req.submittedAt,
                fileUrl: CourseAssetUrl.resolve(sub['file_url']?.toString()) ?? req.fileUrl,
                submissionId: sub['id']?.toString() ?? sub['submission_id']?.toString() ?? req.submissionId,
              );
            }).toList();
            m = CourseModuleModel(
              id: m.id,
              courseId: m.courseId,
              title: m.title,
              type: m.type,
              typeLabel: m.typeLabel,
              durationHours: m.durationHours,
              dueDate: m.dueDate,
              tags: m.tags,
              isCompleted: m.isCompleted,
              isSequential: m.isSequential,
              isLocked: m.isLocked,
              externalUrl: m.externalUrl,
              materialUrl: m.materialUrl,
              materialLabel: m.materialLabel,
              requirements: reqs,
              sessions: m.sessions,
              order: m.order,
              completedSubmissionsCount: m.completedSubmissionsCount,
              pendingSubmissionsCount: m.pendingSubmissionsCount,
              mcqEnabled: m.mcqEnabled,
              mcqQuestions: m.mcqQuestions,
            );
          }

          return _ModuleBody(module: m, isStudent: isStudent);
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
                    Icons.hourglass_empty,
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
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
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
            ...displaySessions.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionCard(session: entry.value, isStudent: isStudent, order: entry.key + 1),
              ),
            ),
          ] else ...[
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '📋 ',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Requirements Checklist (${m.requirements.length} items)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181C1F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (m.requirements.isEmpty)
                    const Text(
                      'No requirements or sessions listed for this module.',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    )
                  else
                    ...m.requirements.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RequirementCard(requirement: r, isStudent: isStudent),
                      ),
                    ),
                ],
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
            else if (m.mcqEnabled) ...[
              if (m.mcqQuestions.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.format_list_numbered, size: 18, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 8),
                      Text(
                        'This quiz contains ${m.mcqQuestions.length} questions',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6D28D9),
                        ),
                      ),
                    ],
                  ),
                ),
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
            ],
          ] else ...[
             _infoCard(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Row(
                     children: [
                       Text('👨‍🏫', style: TextStyle(fontSize: 18)),
                       SizedBox(width: 8),
                       Text(
                         'Instructor Insights',
                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF181C1F)),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: _statBox(
                           title: 'Pending',
                           value: m.pendingSubmissionsCount.toString(),
                           color: const Color(0xFFD97706),
                           bgColor: const Color(0xFFFFF8E6),
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: _statBox(
                           title: 'Completed',
                           value: m.completedSubmissionsCount.toString(),
                           color: const Color(0xFF1F9254),
                           bgColor: const Color(0xFFEFFAF1),
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
          ],
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

  Widget _statBox({required String title, required String value, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementCard extends ConsumerStatefulWidget {
  const _RequirementCard({required this.requirement, required this.isStudent});

  final CourseModuleRequirementModel requirement;
  final bool isStudent;

  @override
  ConsumerState<_RequirementCard> createState() => _RequirementCardState();
}

class _RequirementCardState extends ConsumerState<_RequirementCard> {
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _submitFile() async {
    if (_selectedFile == null) return;
    
    setState(() => _isSubmitting = true);
    try {
      final cId = GoRouterState.of(context).pathParameters['id'];
      final mId = GoRouterState.of(context).pathParameters['moduleId'];
      
      await ref.read(reportsRepositoryProvider).submitReport(
        courseId: cId,
        moduleId: mId,
        submoduleId: widget.requirement.id,
        activityTitle: widget.requirement.title,
        description: widget.requirement.description.isNotEmpty 
            ? widget.requirement.description 
            : 'Module assignment submission',
        category: ReportCategory.theory,
        fileName: _selectedFile?.name,
        fileBytes: _selectedFile?.bytes,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment submitted successfully!'), backgroundColor: Colors.green),
        );
        setState(() => _selectedFile = null);
        if (cId != null && mId != null) {
          ref.invalidate(courseModuleProvider((courseId: cId, moduleId: mId)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _reviewSubmission(String submissionId, String status) async {
    if (submissionId.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      await ref.read(coursesRemoteDataSourceProvider).reviewSubmission(
        submissionId, 
        status, 
        status == 'completed' ? 'Approved' : 'Rejected'
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'completed' ? 'Submission approved!' : 'Submission rejected!'),
            backgroundColor: status == 'completed' ? Colors.green : Colors.red,
          ),
        );
        final cId = GoRouterState.of(context).pathParameters['id'];
        final mId = GoRouterState.of(context).pathParameters['moduleId'];
        if (cId != null && mId != null) {
          ref.invalidate(courseModuleProvider((courseId: cId, moduleId: mId)));
        }
        if (cId != null) {
          ref.invalidate(coursePendingSubmissionsProvider(cId));
        }
        // If we are viewing a specific student's submission via the review screen
        if (GoRouterState.of(context).pathParameters.containsKey('submissionId')) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to review: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final approved = widget.requirement.isApproved;
    final pending = widget.requirement.isPending && !approved;

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
                  '${widget.requirement.title} *',
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
          if (widget.requirement.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.requirement.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (widget.requirement.needsAdminApproval && pending) ...[
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
          if (widget.isStudent && !approved) ...[
            InkWell(
              onTap: _pickFile,
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
                      Icon(
                        _selectedFile != null
                            ? Icons.file_present_rounded
                            : Icons.file_upload_outlined,
                        size: 32,
                        color: _selectedFile != null
                            ? const Color(0xFF398FDE)
                            : const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attach_file, size: 16, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 4),
                          Text(
                            _selectedFile != null ? _selectedFile!.name : 'Choose File',
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setState(() => _selectedFile = null),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Remove File'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
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
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitFile,
                  icon: _isSubmitting 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, size: 16),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Assignment'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F9254),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            if (widget.requirement.submittedAt != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Submitted: ${widget.requirement.submittedAt}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ],
          if (widget.requirement.studentName != null) ...[
            _buildAdminSubmissionBox(
              submissionId: widget.requirement.submissionId ?? '',
              studentName: widget.requirement.studentName,
              rollNo: widget.requirement.rollNo,
              className: widget.requirement.className,
              fileUrl: widget.requirement.fileUrl,
              submittedAt: widget.requirement.submittedAt,
              approved: approved,
              pending: pending,
              isStudentView: widget.isStudent,
            ),
          ] else if (!widget.isStudent) ...[
            Consumer(
              builder: (context, ref, _) {
                final cId = GoRouterState.of(context).pathParameters['id'] ?? '';
                final mId = GoRouterState.of(context).pathParameters['moduleId'] ?? '';
                // Use watch to get the future provider
                final pendingAsync = ref.watch(coursePendingSubmissionsProvider(cId));
                
                return pendingAsync.when(
                  data: (submissions) {
                    final reqSubs = submissions.where((s) {
                      final sModuleId = s['module_id']?.toString() ?? s['moduleId']?.toString();
                      final sSubmoduleId = s['submodule_id']?.toString() ?? s['submoduleId']?.toString();
                      return sModuleId == mId.toString() && 
                             (sSubmoduleId == widget.requirement.id.toString() || sSubmoduleId == null || sSubmoduleId == 'null');
                    }).toList();
                    if (reqSubs.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      children: reqSubs.map((sub) {
                        final isApproved = sub['status']?.toString().toLowerCase() == 'completed' || sub['status']?.toString().toLowerCase() == 'approved';
                        final isPending = sub['status']?.toString().toLowerCase() == 'pending';
                        final sId = sub['id']?.toString() ?? sub['submission_id']?.toString() ?? '';
                        final sName = sub['studentName']?.toString() ?? sub['student_name']?.toString() ?? 'Unknown Student';
                        final sRollNo = sub['rollNo']?.toString() ?? sub['roll_no']?.toString() ?? sub['studentId']?.toString() ?? sub['student_id']?.toString();
                        final sSubmittedAt = sub['submittedAt']?.toString() ?? sub['submitted_at']?.toString();
                        final sFileUrl = sub['fileUrl']?.toString() ?? sub['file_url']?.toString();
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildAdminSubmissionBox(
                            submissionId: sId,
                            studentName: sName,
                            rollNo: sRollNo, 
                            className: null,
                            fileUrl: sFileUrl, 
                            submittedAt: sSubmittedAt,
                            approved: isApproved,
                            pending: isPending,
                            isStudentView: false,
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (e, st) {
                    final errStr = e.toString();
                    if (errStr.contains('404')) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error loading submissions: $errStr', style: const TextStyle(color: Colors.red)),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildAdminSubmissionBox({
    required String submissionId,
    required String? studentName,
    required String? rollNo,
    required String? className,
    required String? fileUrl,
    required String? submittedAt,
    required bool approved,
    required bool pending,
    required bool isStudentView,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181C1F),
                ),
              ),
              OutlinedButton.icon(
                onPressed: fileUrl != null
                    ? () => openCourseUrl(context, fileUrl)
                    : null,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('View File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF398FDE),
                  side: const BorderSide(color: Color(0xFF398FDE)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Submitted by: ',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
          if (rollNo != null || className != null)
            Text(
              [
                if (rollNo != null) 'Roll No: ',
                if (className != null) 'Class: ',
              ].join(' | '),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          const Text(
            'Institute: Delhi Public School',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
          if (submittedAt != null)
            Text(
              'Submitted: ',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          const SizedBox(height: 20),
          if (approved) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1F9254)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF1F9254), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Approved by Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F9254),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Reviewed by: Priya Mehta',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ] else if (pending)
            isStudentView
                ? Container(
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
                  )
                : Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSubmitting || submissionId.isEmpty ? null : () => _reviewSubmission(submissionId, 'completed'),
                          icon: _isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text('Approve', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1F9254),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSubmitting || submissionId.isEmpty ? null : () => _reviewSubmission(submissionId, 'rejected'),
                          icon: _isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text('Reject', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Icon(Icons.info_outline, size: 14, color: Color(0xFFEA7A1A)),
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

class _SessionCard extends ConsumerStatefulWidget {
  const _SessionCard({required this.session, required this.isStudent, required this.order});

  final CourseSessionModel session;
  final bool isStudent;
  final int order;

  @override
  ConsumerState<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<_SessionCard> {
  bool _isCompletedLocally = false;

  @override
  void initState() {
    super.initState();
    _isCompletedLocally = widget.session.isCompleted;
  }

  @override
  void didUpdateWidget(covariant _SessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.id != oldWidget.session.id) {
      _isCompletedLocally = widget.session.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final cId = GoRouterState.of(context).pathParameters['id'] ?? '';
          final mId = GoRouterState.of(context).pathParameters['moduleId'] ?? '';
          await Navigator.of(context, rootNavigator: true).push<bool>(
            MaterialPageRoute(
              builder: (context) => CourseSessionDetailScreen(
                session: widget.session,
                isStudent: widget.isStudent,
                order: widget.order,
                courseId: cId,
                moduleId: mId,
              ),
            ),
          );

          // We don't set _isCompletedLocally manually here because
          // CourseSessionDetailScreen already invalidates the providers
          // on submission, so the state will refresh from the backend.
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF181C1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.session.contentType != null && widget.session.contentType!.isNotEmpty)
                          _buildBadge(widget.session.contentType!, Icons.category_outlined, const Color(0xFF398FDE), const Color(0xFFE8F4FD)),
                        if (widget.session.deliveryMode != null && widget.session.deliveryMode!.isNotEmpty)
                          _buildBadge(
                            widget.session.deliveryMode!,
                            widget.session.deliveryMode?.toLowerCase() == 'in_person' ? Icons.location_on_outlined : Icons.videocam_outlined,
                            const Color(0xFFD97706),
                            const Color(0xFFFFF8E6),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (_isCompletedLocally)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F9254),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                )
              else if (widget.session.submissionStatus == 'pending')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(12),
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
                )
              else
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
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

