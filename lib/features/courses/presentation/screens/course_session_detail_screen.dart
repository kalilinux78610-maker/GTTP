import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gttp/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:gttp/features/courses/data/models/course_session_model.dart';
import 'package:gttp/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/courses/presentation/utils/course_links.dart';
import 'package:gttp/features/courses/presentation/providers/course_module_provider.dart';
import 'package:gttp/features/courses/presentation/providers/course_details_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:gttp/features/courses/presentation/widgets/session_video_player.dart';
import 'package:gttp/features/courses/presentation/providers/courses_provider.dart';


class CourseSessionDetailScreen extends ConsumerStatefulWidget {
  final CourseSessionModel session;
  final bool isStudent;
  final int order;
  final String courseId;
  final String moduleId;

  const CourseSessionDetailScreen({
    super.key,
    required this.session,
    required this.isStudent,
    required this.order,
    required this.courseId,
    required this.moduleId,
  });

  @override
  ConsumerState<CourseSessionDetailScreen> createState() => _CourseSessionDetailScreenState();
}

class _CourseSessionDetailScreenState extends ConsumerState<CourseSessionDetailScreen> {
  bool _isSubmitting = false;
  bool _isCompletedLocally = false;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _isCompletedLocally = widget.session.isCompleted;
  }

  bool get _requiresProofUpload {
    final type = widget.session.contentType?.toLowerCase().replaceAll('_', ' ') ?? '';
    if (type.contains('quiz') || type.contains('mcq')) return false;
    return widget.session.requiresProofUpload || type.contains('report upload') || type.contains('submission') || type.contains('assignment');
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _markAsComplete() async {
    setState(() => _isSubmitting = true);
    
    try {
      if (_requiresProofUpload) {
        if (_selectedFile == null) return;
        
        final bytes = _selectedFile != null ? await _selectedFile!.readAsBytes() : null;

        await ref.read(reportsRepositoryProvider).submitReport(
          courseId: widget.courseId,
          moduleId: widget.moduleId,
          submoduleId: widget.session.id,
          activityTitle: widget.session.title,
          description: 'Submitted via course session details screen.',
          category: ReportCategory.theory,
          fileName: _selectedFile?.name,
          fileBytes: bytes,
        );
        
        await ref.read(coursesRepositoryProvider).markSubmoduleComplete(
          widget.courseId,
          widget.moduleId,
          widget.session.id,
        );
      } else {
        await ref.read(coursesRepositoryProvider).markSubmoduleComplete(
          widget.courseId,
          widget.moduleId,
          widget.session.id,
        );
      }
      
      if (mounted) {
        setState(() {
          _isCompletedLocally = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(courseDetailsProvider(widget.courseId));
        ref.invalidate(courseModuleProvider((courseId: widget.courseId, moduleId: widget.moduleId)));
        ref.invalidate(coursesProvider);
        
        if (!_requiresProofUpload) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildBadge(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.session.contentType?.toLowerCase().replaceAll('_', ' ') ?? '';
    final isVideo = type == 'video (url)' || type == 'video';
    final isExternal = type == 'external course (url)' || type == 'external course';
    final isLiveSession = type == 'live session (meeting link)' || type == 'live session';
    final isMCQ = type == 'mcq test' || type == 'mcq' || type == 'quiz';

    final courseState = ref.watch(courseDetailsProvider(widget.courseId));
    final course = courseState.value;
    final isExpired = course?.isExpired ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Course Modules',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1E3A8A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: (widget.isStudent && !_isCompletedLocally && !_requiresProofUpload) ? 80 : 0, 
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isCompletedLocally && _requiresProofUpload) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_empty, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Submitted — Awaiting Review',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isExpired) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This course has expired. No further submissions are allowed.',
                              style: TextStyle(
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Order: ${widget.order}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      if (widget.session.contentType != null && widget.session.contentType!.isNotEmpty)
                        _buildBadge(
                          widget.session.contentType!, 
                          Icons.category_outlined, 
                          const Color(0xFF2563EB), 
                          const Color(0xFFEFF6FF)
                        ),
                      if (widget.session.deliveryMode != null && widget.session.deliveryMode!.isNotEmpty)
                        _buildBadge(
                          widget.session.deliveryMode!,
                          widget.session.deliveryMode?.toLowerCase() == 'in_person' ? Icons.people_outline : Icons.videocam_outlined,
                          const Color(0xFF059669),
                          const Color(0xFFECFDF5),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.session.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                  const SizedBox(height: 16),
                  
                  if (widget.session.instructions != null && widget.session.instructions!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF2563EB), width: 4)),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Html(
                                data: widget.session.instructions!,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(15.0),
                                    lineHeight: const LineHeight(1.6),
                                    color: const Color(0xFF4B5563),
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else if (widget.session.description != null && widget.session.description!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF2563EB), width: 4)),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.session.description!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (isLiveSession && widget.session.fileUrl != null && widget.session.fileUrl!.isNotEmpty) ...[
                    // Link Box
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: InkWell(
                        onTap: () => openCourseUrl(context, widget.session.fileUrl),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.session.fileUrl!,
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),


                    const SizedBox(height: 24),
                  ] else if (isVideo && widget.session.videoUrl != null && widget.session.videoUrl!.isNotEmpty) ...[
                    SessionVideoPlayer(videoUrl: widget.session.videoUrl!),
                    const SizedBox(height: 16),
                  ] else if ((isExternal || type == 'external course') && widget.session.fileUrl != null && widget.session.fileUrl!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openCourseUrl(context, widget.session.fileUrl),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open External Course', style: TextStyle(fontSize: 15)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (isMCQ) ...[
                    if (isExpired && !_isCompletedLocally && widget.session.submissionStatus == 'pending')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.timer_off_outlined, color: Color(0xFFDC2626)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Course expired. Quizzes are closed.',
                                style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                        onPressed: () async {
                          // Route to the quiz screen, passing the submoduleId
                          final result = await context.push<bool>('/courses/${widget.courseId}/modules/${widget.moduleId}/quiz?submoduleId=${widget.session.id}');
                          if (result == true && mounted) {
                            setState(() {
                              _isCompletedLocally = true;
                            });
                            // Refresh course details
                            ref.invalidate(courseDetailsProvider(widget.courseId));
                          }
                        },
                        icon: Icon(
                          _isCompletedLocally ? Icons.check_circle : Icons.quiz_outlined, 
                          size: 18
                        ),
                        label: Text(
                          _isCompletedLocally ? 'Retake MCQ Quiz' : 'Take MCQ Quiz', 
                          style: const TextStyle(fontSize: 15)
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _isCompletedLocally ? const Color(0xFF059669) : const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (!isLiveSession && !isVideo && !isExternal && widget.session.fileUrl != null && widget.session.fileUrl!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openCourseUrl(context, widget.session.fileUrl),
                        icon: const Icon(Icons.insert_drive_file_outlined, size: 18),
                        label: Text(
                          widget.session.deliveryMode?.toLowerCase() == 'virtual'
                              ? 'View Virtual Material'
                              : 'Read Material',
                          style: const TextStyle(fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (widget.session.referenceMaterialUrl != null && widget.session.referenceMaterialUrl!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openCourseUrl(context, widget.session.referenceMaterialUrl),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Download Reference Material', style: TextStyle(fontSize: 15)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_requiresProofUpload && widget.isStudent) ...[
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Icon(Icons.check_box_outlined, color: Color(0xFF1F2937), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Requirements Checklist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isExpired && !_isCompletedLocally && widget.session.submissionStatus == 'pending')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 32),
                            SizedBox(height: 12),
                            Text(
                              'Course Expired',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'This course has passed its end date. Submissions are no longer accepted.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload your ${widget.session.title.toLowerCase()} *',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Please upload the required document below.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Needs Admin Approval',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (!_isCompletedLocally && widget.session.submissionStatus != 'pending') ...[
                            InkWell(
                              onTap: _pickFile,
                              borderRadius: BorderRadius.circular(8),
                              child: DottedBorder(
                                options: const RoundedRectDottedBorderOptions(
                                  color: Color(0xFF9CA3AF),
                                  strokeWidth: 1.5,
                                  dashPattern: [6, 4],
                                  radius: Radius.circular(8),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        _selectedFile != null ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                                        size: 32,
                                        color: _selectedFile != null ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _selectedFile?.name ?? 'Choose File',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: _selectedFile != null ? const Color(0xFF111827) : const Color(0xFF6B7280),
                                          fontWeight: _selectedFile != null ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Accepted: PDF, DOC, DOCX | Max: 10 MB',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_selectedFile != null)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _isSubmitting ? null : _markAsComplete,
                                  icon: _isSubmitting 
                                    ? const SizedBox(
                                        width: 20, 
                                        height: 20, 
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                      )
                                    : const Icon(Icons.file_upload_outlined, size: 20),
                                  label: const Text('Submit Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                          ] else ...[
                            // Already completed
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF059669), size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'File Submitted',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Your file has been uploaded and is waiting for review.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (widget.isStudent && !_isCompletedLocally && !_requiresProofUpload && !isMCQ)
            if (!isExpired)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _markAsComplete,
                        icon: _isSubmitting 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('Mark as Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
