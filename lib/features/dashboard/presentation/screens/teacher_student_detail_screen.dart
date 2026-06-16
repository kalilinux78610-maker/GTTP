import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeacherStudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const TeacherStudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsApiProvider);
    final primaryColor = const Color(0xFF0052CC); // Admin Blue Theme

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181C1F)),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Row(
          children: [
            Text(
              'Students',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            Expanded(
              child: studentsAsync.maybeWhen(
                data: (rows) {
                  final match = _findStudent(rows, studentId);
                  return Text(
                    match != null ? StudentRowParser.name(match) : 'Student Details',
                    style: const TextStyle(
                      color: Color(0xFF181C1F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
                orElse: () => const Text(
                  'Student Details',
                  style: TextStyle(
                    color: Color(0xFF181C1F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: studentsAsync.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileCard(primaryColor, 'Loading...', '', '', '', '', 0, '', '', '', null),
              ],
            ),
          ),
        ),
        error: (err, stack) => Center(child: Text('Failed to load student data', style: TextStyle(color: Colors.red.shade400))),
        data: (rows) {
          final student = _findStudent(rows, studentId);
          if (student == null) {
            return const Center(child: Text('Student not found.'));
          }

          final name = StudentRowParser.name(student);
          final idStr = StudentRowParser.id(student).isEmpty ? 'N/A' : StudentRowParser.id(student);
          final classLabel = StudentRowParser.classLabel(student);
          
          final schoolName = student['school_name'] ?? student['schoolName'] ?? '';
          final school = schoolName.toString().trim().isNotEmpty ? schoolName.toString().trim() : 'N/A';
          
          final progress = StudentRowParser.scorePercent(student);
          
          final emailData = student['email'] ?? student['contact_email'] ?? '';
          final email = emailData.toString().trim().isNotEmpty ? emailData.toString().trim() : 'N/A';
          
          final phoneData = student['phone'] ?? student['mobile'] ?? student['contact_no'] ?? '';
          final phone = phoneData.toString().trim().isNotEmpty ? phoneData.toString().trim() : 'N/A';

          final initials = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase();
          final displayInitials = initials.isEmpty ? '?' : initials;

          final addressData = student['address'] ?? student['location'] ?? student['city'] ?? '';
          final address = addressData.toString().trim().isNotEmpty ? addressData.toString().trim() : 'N/A';
          final avatarUrl = StudentRowParser.avatar(student);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileCard(primaryColor, name, displayInitials, idStr, classLabel, school, progress, email, phone, address, avatarUrl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
      Color primaryColor, String name, String initials, String idStr, String classLabel, String school, int progress, String email, String phone, String address, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (avatarUrl != null)
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor,
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryColor,
                  child: Text(
                    initials,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      idStr,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(classLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              school,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Completion', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Text('$progress%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          _buildContactRow(Icons.email_outlined, email),
          const SizedBox(height: 12),
          _buildContactRow(Icons.phone_outlined, phone),
          const SizedBox(height: 12),
          _buildContactRow(Icons.location_on_outlined, address),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
      ],
    );
  }



  Map<String, dynamic>? _findStudent(List<Map<String, dynamic>> rows, String id) {
    for (final row in rows) {
      if (StudentRowParser.id(row) == id) return row;
    }
    return null;
  }
}
