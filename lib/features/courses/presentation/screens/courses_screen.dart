import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/courses_provider.dart';
import '../../data/models/course_model.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Courses',
          style: TextStyle(
            color: Color(0xFF2A3A4A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: () => ref.refresh(coursesProvider),
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(coursesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return _CourseCard(course: courses[index]);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE65C00)),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Failed to load courses',
                style: TextStyle(fontSize: 16, color: Colors.red.shade400),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(coursesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No courses available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to course detail
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (course.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    course.thumbnailUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  ),
                )
              else
                _buildPlaceholderImage(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (course.level != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4FD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.level!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3286C9),
                              ),
                            ),
                          ),
                        if (course.isEnrolled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Color(0xFF059669)),
                                SizedBox(width: 4),
                                Text(
                                  'Enrolled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A3A4A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    if (_hasAnyMeta()) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (course.enrollmentType != null && course.enrollmentType!.isNotEmpty)
                            _buildMetaChip(
                              icon: Icons.how_to_reg_outlined,
                              label: _toTitleCase(course.enrollmentType!),
                              bgColor: const Color(0xFFE8F4FD),
                              fgColor: const Color(0xFF3286C9),
                            ),
                          if (course.status != null && course.status!.isNotEmpty)
                            _buildMetaChip(
                              icon: Icons.verified_outlined,
                              label: _toTitleCase(course.status!),
                              bgColor: const Color(0xFFEFFAF1),
                              fgColor: const Color(0xFF1F9254),
                            ),
                          if (course.passPercentage != null && course.passPercentage!.isNotEmpty)
                            _buildMetaChip(
                              icon: Icons.equalizer_rounded,
                              label: _formatPassPercentage(course.passPercentage!),
                              bgColor: const Color(0xFFFFF3E8),
                              fgColor: const Color(0xFFEA7A1A),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (course.instructor != null) ...[
                          const Icon(Icons.person_outline, size: 16, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.instructor!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (course.duration != null) ...[
                          const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            '${course.duration} hrs',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if ((course.startDate != null && course.startDate!.isNotEmpty) ||
                        (course.endDate != null && course.endDate!.isNotEmpty)) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _buildDateRange(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAnyMeta() {
    return (course.enrollmentType?.isNotEmpty ?? false) ||
        (course.status?.isNotEmpty ?? false) ||
        (course.passPercentage?.isNotEmpty ?? false);
  }

  String _toTitleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _buildDateRange() {
    final start = course.startDate?.trim();
    final end = course.endDate?.trim();
    if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
      return '$start - $end';
    }
    if (start != null && start.isNotEmpty) return 'Starts: $start';
    if (end != null && end.isNotEmpty) return 'Ends: $end';
    return '';
  }

  String _formatPassPercentage(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return cleaned;
    return cleaned.endsWith('%') ? cleaned : '$cleaned%';
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fgColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
