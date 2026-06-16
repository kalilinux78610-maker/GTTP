import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/course_details_provider.dart';

class PendingSubmissionsScreen extends ConsumerWidget {
  final String courseId;

  const PendingSubmissionsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(coursePendingSubmissionsProvider(courseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181C1F)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pending Submissions',
          style: TextStyle(
            color: Color(0xFF181C1F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Failed to load pending submissions:\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Text(
                'No pending submissions found.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            itemCount: submissions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = submissions[index];
              final submissionId = sub['id']?.toString() ?? sub['submission_id']?.toString() ?? '';
              final studentName = sub['student_name']?.toString() ?? 'Unknown Student';
              final moduleName = sub['module_name']?.toString() ?? 'Unknown Module';
              final submittedAt = sub['submitted_at']?.toString() ?? '';

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    // Navigate to AssignmentReviewScreen
                    // We need to pass both courseId and moduleId. 
                    // However, we should also pass the submission data so the screen can show it.
                    context.push('/courses/$courseId/submissions/$submissionId', extra: sub);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF181C1F),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                moduleName,
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        if (submittedAt.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Color(0xFF6B7280)),
                              const SizedBox(width: 8),
                              Text(
                                submittedAt,
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
