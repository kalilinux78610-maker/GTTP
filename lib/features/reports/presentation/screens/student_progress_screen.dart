import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/reports/presentation/providers/reports_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentProgressScreen extends ConsumerWidget {
  final String? studentId;
  final String? courseId;

  const StudentProgressScreen({
    super.key,
    this.studentId,
    this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(studentProgressProvider(studentId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1C1E)),
      ),
      body: progressAsync.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 3,
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(studentProgressProvider(studentId)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (progress) {
          var courses = progress.courses;
          if (courseId != null) {
            courses = courses.where((c) => c.id.toString() == courseId).toList();
          }

          if (courses.isEmpty) {
            return const Center(
              child: Text(
                'No courses enrolled yet.',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
            );
          }

          final bottomPadding = MediaQuery.of(context).padding.bottom + 120;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: bottomPadding),
            itemCount: courses.length + 1, // +1 for the student header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildStudentHeader(progress.student);
              }
              final course = courses[index - 1];
              return _buildCourseProgressCard(context, course);
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 20, width: 200, color: Colors.grey),
          const SizedBox(height: 16),
          Container(height: 10, width: double.infinity, color: Colors.grey),
          const SizedBox(height: 8),
          Container(height: 14, width: 50, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStudentHeader(dynamic student) {
    final initials = student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S';
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF398FDE).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF398FDE),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.schoolName ?? 'School'} | Class: ${student.studentClass ?? 'N/A'} ${student.section != null ? 'Sec: ${student.section}' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgressCard(BuildContext context, dynamic course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '${course.progressPercentage}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF398FDE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: course.progressPercentage / 100,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF398FDE)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Modules',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ...course.modules.map<Widget>((module) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    module.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: module.isCompleted ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
                  ),
                  title: Text(
                    module.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: module.isCompleted ? const Color(0xFF4B5563) : const Color(0xFF1F2937),
                    ),
                  ),
                  trailing: !module.isCompleted
                      ? TextButton(
                          onPressed: () {
                            context.push('/courses/${course.id}/modules/${module.id}');
                          },
                          child: const Text('Go to Module'),
                        )
                      : const Text('Completed', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                ),
                if (module.submodules.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: module.submodules.map<Widget>((sub) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                sub.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                size: 16,
                                color: sub.isCompleted ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: sub.isCompleted ? const Color(0xFF6B7280) : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                              if (sub.status != 'pending' && !sub.isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    sub.status.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
