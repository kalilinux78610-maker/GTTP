import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/courses/data/models/course_model.dart';
import 'package:gttp/features/courses/data/models/course_module_model.dart';
import 'package:gttp/features/courses/presentation/providers/course_details_provider.dart';
import 'package:gttp/features/courses/presentation/utils/course_links.dart';
import 'package:gttp/features/courses/presentation/widgets/course_cover_image.dart';
import 'package:gttp/features/courses/presentation/screens/create_course_module_screen.dart';
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
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CreateCourseModuleScreen(
                                    courseId: courseId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Module'),
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
    final progress = (course.progressPercent ?? 0).clamp(0, 100);

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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                '$progress% Complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F62FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F62FE)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        ],
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
              if (status == 'Pending Review')
                ElevatedButton(
                  onPressed: () {
                    context.push('/dashboard/assignment-review/$courseId/$moduleId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Review'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
