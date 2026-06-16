import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/courses/data/models/course_model.dart';
import 'package:gttp/features/courses/data/models/course_module_model.dart';
import 'package:gttp/features/courses/presentation/providers/course_details_provider.dart';
import 'package:gttp/features/courses/presentation/utils/course_links.dart';
import 'package:gttp/features/courses/presentation/widgets/course_cover_image.dart';

class CoordinatorCourseDetailsScreen extends ConsumerWidget {
  final String courseId;

  const CoordinatorCourseDetailsScreen({super.key, required this.courseId});

  static const _moduleColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(courseDetailsProvider(courseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load course', style: TextStyle(color: Colors.red.shade400)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(courseDetailsProvider(courseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (course) {
          if (course == null) {
            return const Center(child: Text('Course not found.'));
          }

          return CustomScrollView(
            slivers: [
              _buildHero(context, course),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseInfo(context, course),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Course Modules (${course.modules.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (course.modules.isEmpty)
                        Text(
                          'No modules available for this course.',
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      else
                        ...course.modules.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildModuleCard(
                                  context,
                                  module: e.value,
                                  index: e.key,
                                ),
                              ),
                            ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, CourseModel course) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF0F62FE),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: CourseCoverImage(
          imageUrl: course.thumbnailUrl,
          fit: BoxFit.cover,
          placeholderColor: const Color(0xFF0F62FE),
        ),
      ),
    );
  }

  Widget _buildCourseInfo(BuildContext context, CourseModel course) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          if (course.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              course.description,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
          if (course.pdfUrl != null && course.pdfUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => openCourseUrl(context, course.pdfUrl),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Course PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F62FE),
                side: const BorderSide(color: Color(0xFF0F62FE)),
              ),
            ),
          ],
          _PendingApprovalsWidget(courseId: course.id),

        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required CourseModuleModel module,
    required int index,
  }) {
    final color = _moduleColors[index % _moduleColors.length];
    final number = '${index + 1}';
    final isAssignment = module.type.toLowerCase().contains('assignment') ||
        module.type.toLowerCase().contains('report');
    final status = module.isCompleted ? 'Approved' : 'Pending Review';
    final statusColor = module.isCompleted ? Colors.green : Colors.orange;

    if (isAssignment) {
      return _buildModuleAssignment(
        context,
        number: number,
        title: module.title,
        color: color,
        status: status,
        statusColor: statusColor,
        moduleId: module.id,
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/courses/$courseId/modules/${module.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                radius: 20,
                child: Text(
                  number,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (module.typeLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        module.typeLabel,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleAssignment(
    BuildContext context, {
    required String number,
    required String title,
    required Color color,
    required String status,
    required Color statusColor,
    required String moduleId,
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
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                radius: 20,
                child: Text(
                  number,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
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

