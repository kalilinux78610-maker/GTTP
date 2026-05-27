import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
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

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileCard(primaryColor, name, displayInitials, idStr, classLabel, school, progress, email, phone),
                const SizedBox(height: 16),
                // The following cards are placeholders since the API does not currently provide this data
                _buildPassportSecurityCard(),
                const SizedBox(height: 16),
                _buildJourneyTimeline(primaryColor),
                const SizedBox(height: 16),
                _buildPillarsProgress(primaryColor),
                const SizedBox(height: 16),
                _buildFlaggingHistory(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
      Color primaryColor, String name, String initials, String idStr, String classLabel, String school, int progress, String email, String phone) {
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

  Widget _buildPassportSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Passport Security', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    Text('Critical for Feb Picnic & Mar Conference', style: TextStyle(fontSize: 12, color: Colors.amber.shade800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Passport Number', style: TextStyle(fontSize: 13, color: Colors.amber.shade900)),
              const Text('M1234567', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expiry Date', style: TextStyle(fontSize: 13, color: Colors.amber.shade900)),
              const Text('15 Jun 2026', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Passport expires within 6 months - Renewal required!',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyTimeline(Color primaryColor) {
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
              Icon(Icons.timeline, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text('Student Journey Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimelineItem('Course Enrollment', '15 Aug 2025', true, true, false),
          _buildTimelineItem('August Orientation', '20 Aug 2025', true, true, false),
          _buildTimelineItem('September Theory Unit', '15 Sep 2025', true, true, false),
          _buildTimelineItem('October Practical', '12 Oct 2025', false, true, true),
          _buildTimelineItem('November Research Competition', 'TBD', false, false, false),
          _buildTimelineItem('December Case Study', 'TBD', false, false, false),
          _buildTimelineItem('January MCQ Assessment', 'TBD', false, false, false),
          _buildTimelineItem('February Picnic', 'TBD', false, false, false),
          _buildTimelineItem('March International Conference', 'TBD', false, false, false),
          _buildTimelineItem('April Convocation', 'TBD', false, false, false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, bool isActive, bool isWarning, {bool isLast = false}) {
    Color dotColor = isCompleted ? const Color(0xFF10B981) : (isWarning ? const Color(0xFFF59E0B) : Colors.grey.shade300);
    IconData icon = isCompleted ? Icons.check_circle : (isWarning ? Icons.access_time_filled : Icons.access_time);
    Color iconColor = isCompleted ? const Color(0xFF10B981) : (isWarning ? const Color(0xFFF59E0B) : Colors.grey.shade400);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: isActive ? const Color(0xFF10B981) : Colors.grey.shade200)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? const Color(0xFF1E293B) : Colors.grey.shade500, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Icon(icon, size: 16, color: iconColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarsProgress(Color primaryColor) {
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
          const Text('4 Pillars Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 20),
          _buildPillarSection(
            icon: Icons.menu_book,
            iconBg: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF3B82F6),
            title: 'Theory',
            items: [
              _buildProgressTask('Tourism Poster', 'Submitted: 28 Aug 2025', 'Approved', true),
              _buildProgressTask('Heritage Blog', 'Submitted: 25 Oct 2025', 'Approved', true),
              _buildProgressTask('Case Study', '', 'Pending', false),
            ],
          ),
          const SizedBox(height: 24),
          _buildPillarSection(
            icon: Icons.workspace_premium,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF10B981),
            title: 'Practical',
            items: [
              _buildProgressTask('Photography Entry', 'Submitted: 30 Aug 2025', 'Approved', true),
              _buildProgressTask('Event Management', 'Submitted: 28 Oct 2025', 'Flagged', false, warningMessage: 'Unclear documentation'),
              _buildProgressTask('Final Project', '', 'Pending', false),
            ],
          ),
          const SizedBox(height: 24),
          _buildPillarSection(
            icon: Icons.business_center,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFF59E0B),
            title: 'Internship',
            items: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Status: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        const Text('In Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('01 Oct 2025 - 31 Dec 2025', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPillarSection(
            icon: Icons.map_outlined,
            iconBg: const Color(0xFFFCE7F3),
            iconColor: const Color(0xFFEC4899),
            title: 'Visits',
            items: [
              _buildVisitTask('Taj Mahal Visit', '15 Sep 2025'),
              _buildVisitTask('Red Fort Documentation', '22 Sep 2025'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarSection({required IconData icon, required Color iconBg, required Color iconColor, required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildProgressTask(String title, String subtitle, String status, bool isApproved, {String? warningMessage}) {
    Color statusBg = status == 'Approved' ? const Color(0xFFD1FAE5) : (status == 'Flagged' ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9));
    Color statusColor = status == 'Approved' ? const Color(0xFF059669) : (status == 'Flagged' ? const Color(0xFFDC2626) : const Color(0xFF64748B));
    IconData statusIcon = status == 'Approved' ? Icons.check_circle_outline : (status == 'Flagged' ? Icons.flag_outlined : Icons.access_time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
          if (isApproved) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check, size: 12, color: Color(0xFF059669)),
                const SizedBox(width: 4),
                Text('Approved by Coordinator', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontStyle: FontStyle.italic)),
              ],
            ),
          ],
          if (warningMessage != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFD97706)),
                const SizedBox(width: 4),
                Text(warningMessage, style: TextStyle(fontSize: 11, color: Colors.amber.shade700)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisitTask(String title, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildFlaggingHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined, size: 20, color: Colors.red.shade400),
              const SizedBox(width: 8),
              const Text('Flagging History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Very light red
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Event Management Practical', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text('Practical', style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Documentation lacks clarity on event execution steps',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flagged by: Ms. Priya Sharma\n(Coordinator)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    Text('28 Oct\n2025', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFFECACA)),
                ),
                Row(
                  children: [
                    Text('Resolution: ', style: TextStyle(fontSize: 12, color: Colors.red.shade800)),
                    Text('Pending Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _findStudent(List<Map<String, dynamic>> rows, String id) {
    for (final row in rows) {
      if (StudentRowParser.id(row) == id) return row;
    }
    return null;
  }
}
