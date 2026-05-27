import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/courses_provider.dart';
import '../widgets/course_cover_image.dart';
import '../../data/models/course_model.dart';

enum _CourseFilter { all, open, invite, batch }

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  _CourseFilter _filter = _CourseFilter.all;

  List<CourseModel> _applyFilter(List<CourseModel> courses) {
    switch (_filter) {
      case _CourseFilter.all:
        return courses;
      case _CourseFilter.open:
        return courses.where((c) => _enrollmentKey(c).contains('open')).toList();
      case _CourseFilter.invite:
        return courses.where((c) => _enrollmentKey(c).contains('invite')).toList();
      case _CourseFilter.batch:
        return courses.where((c) => _enrollmentKey(c).contains('batch')).toList();
    }
  }

  String _enrollmentKey(CourseModel c) =>
      (c.enrollmentType ?? '').toLowerCase().replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 140;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2A3A4A), size: 20),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          'Courses',
          style: TextStyle(
            color: Color(0xFF2A3A4A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: coursesAsync.when(
        data: (courses) {
          final filtered = _applyFilter(courses);
          if (courses.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(coursesProvider),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
              children: [
                _FilterBar(
                  selected: _filter,
                  onSelected: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 16),
                ...filtered.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CourseCard(course: c),
                    )),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Showing ${filtered.length} Course${filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF398FDE)),
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
          Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No courses available',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final _CourseFilter selected;
  final ValueChanged<_CourseFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == _CourseFilter.all,
            onTap: () => onSelected(_CourseFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Open Enrollment',
            isSelected: selected == _CourseFilter.open,
            onTap: () => onSelected(_CourseFilter.open),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Invite Only',
            isSelected: selected == _CourseFilter.invite,
            onTap: () => onSelected(_CourseFilter.invite),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Batch',
            isSelected: selected == _CourseFilter.batch,
            onTap: () => onSelected(_CourseFilter.batch),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF398FDE) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF398FDE) : const Color(0xFFE0E3E7),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF2A3A4A),
          ),
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseCoverImage(
            imageUrl: course.thumbnailUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181C1F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description.isNotEmpty
                      ? course.description
                      : 'No description available.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (course.enrollmentType != null &&
                        course.enrollmentType!.isNotEmpty)
                      _EnrollmentBadge(enrollmentType: course.enrollmentType!),
                    if (course.enrollmentType != null &&
                        course.enrollmentType!.isNotEmpty)
                      const SizedBox(width: 8),
                    if (course.status != null && course.status!.isNotEmpty)
                      _PublishedBadge(label: _statusLabel(course.status!)),
                  ],
                ),
                if (_hasDateRange()) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _buildDateRange(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/courses/${course.id}'),
                    icon: const Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: Color(0xFF398FDE),
                    ),
                    label: const Text(
                      'View Course',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF398FDE),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF398FDE)),
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
      ),
    );
  }

  bool _hasDateRange() {
    return (course.startDate?.isNotEmpty ?? false) ||
        (course.endDate?.isNotEmpty ?? false);
  }

  String _buildDateRange() {
    final start = course.startDate?.trim();
    final end = course.endDate?.trim();
    if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
      return '$start - $end';
    }
    if (start != null && start.isNotEmpty) return start;
    if (end != null && end.isNotEmpty) return end;
    return '';
  }

}

class _EnrollmentBadge extends StatelessWidget {
  const _EnrollmentBadge({required this.enrollmentType});

  final String enrollmentType;

  @override
  Widget build(BuildContext context) {
    final key = enrollmentType.toLowerCase();
    Color border;
    Color text;
    String label;

    if (key.contains('invite')) {
      border = const Color(0xFF7C3AED);
      text = const Color(0xFF7C3AED);
      label = 'Invite';
    } else if (key.contains('batch')) {
      border = const Color(0xFFEA7A1A);
      text = const Color(0xFFEA7A1A);
      label = 'Batch';
    } else {
      border = const Color(0xFF1F9254);
      text = const Color(0xFF1F9254);
      label = key.contains('open') ? 'Open' : _shortLabel(enrollmentType);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  String _shortLabel(String value) {
    if (value.isEmpty) return value;
    final words = value.split(RegExp(r'\s+'));
    if (words.length == 1) {
      return value[0].toUpperCase() + value.substring(1).toLowerCase();
    }
    return words.first[0].toUpperCase() + words.first.substring(1).toLowerCase();
  }
}

String _statusLabel(String status) {
  final s = status.toLowerCase();
  if (s.contains('publish')) return 'Published';
  return status[0].toUpperCase() + status.substring(1).toLowerCase();
}

class _PublishedBadge extends StatelessWidget {
  const _PublishedBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F9254),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
