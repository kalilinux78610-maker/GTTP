import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/school_network/presentation/providers/school_network_provider.dart';
import 'package:intl/intl.dart';

class FacultyDetailsScreen extends ConsumerWidget {
  const FacultyDetailsScreen({
    super.key,
    required this.faculty,
  });

  final Map<String, dynamic> faculty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = faculty['id']?.toString() ?? faculty['user_id']?.toString() ?? '';
    
    if (id.isEmpty) {
      return _buildContent(context, faculty);
    }
    
    final asyncFaculty = ref.watch(facultyDetailProvider(id));
    
    return asyncFaculty.when(
      data: (freshFaculty) => _buildContent(context, freshFaculty),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF4F7FB),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE65C00))),
      ),
      error: (e, st) {
        // Fallback to cached data if fetch fails
        return _buildContent(context, faculty);
      },
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> facultyData) {
    final userObj = facultyData['user'] is Map ? facultyData['user'] as Map : facultyData;
    final schoolObj = facultyData['school'] is Map ? facultyData['school'] as Map : {};
    
    final name = (userObj['name'] ?? userObj['faculty_name'] ?? 'Unknown').toString();
    final email = (userObj['email'] ?? 'No email').toString();
    final phone = (userObj['phone'] ?? userObj['mobile'] ?? 'Not provided').toString();
    final role = (userObj['role'] ?? userObj['designation'] ?? 'Faculty').toString();
    final schoolName = (schoolObj['name'] ?? 'Unknown School').toString();
    final avatarUrl = StudentRowParser.avatar(userObj as Map<String, dynamic>);
    
    final dob = facultyData['date_of_birth']?.toString() ?? '';
    final formattedDob = _formatDate(dob);
    
    final gender = facultyData['gender']?.toString() ?? '-';
    final bloodGroup = facultyData['blood_group']?.toString() ?? '-';
    final institute = facultyData['institute']?.toString() ?? '-';
    
    // Departments & Programs
    final departments = facultyData['department'] is List 
      ? (facultyData['department'] as List).join(', ') 
      : (facultyData['department']?.toString() ?? '-');
    final programs = facultyData['program'] is List 
      ? (facultyData['program'] as List).join(', ') 
      : (facultyData['program']?.toString() ?? '-');
      
    final studentsCount = facultyData['students_count']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
              decoration: const BoxDecoration(
                color: Color(0xFFE65C00),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.canPop()) context.pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Faculty Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 34), // balance back button
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (avatarUrl != null)
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _buildFallbackAvatar(name),
                          ),
                        )
                      else
                        _buildFallbackAvatar(name),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Contact Information'),
                    _buildInfoCard([
                      _buildInfoRow(Icons.email_outlined, 'Email', email),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
                    ]),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Academic Details'),
                    _buildInfoCard([
                      _buildInfoRow(Icons.account_balance_outlined, 'School / Institute', schoolName),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(Icons.domain_outlined, 'Institute Type', institute.toUpperCase()),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(Icons.groups_outlined, 'Students Count', studentsCount),
                      if (departments != '-' && departments.isNotEmpty) ...[
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildInfoRow(Icons.business_outlined, 'Department', departments),
                      ],
                      if (programs != '-' && programs.isNotEmpty) ...[
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildInfoRow(Icons.book_outlined, 'Program', programs),
                      ],
                    ]),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Personal Details'),
                    _buildInfoCard([
                      _buildInfoRow(Icons.cake_outlined, 'Date of Birth', formattedDob.isEmpty ? '-' : formattedDob),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(Icons.person_outline, 'Gender', gender.toUpperCase()),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(Icons.bloodtype_outlined, 'Blood Group', bloodGroup),
                    ]),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 40,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'F',
        style: const TextStyle(
          color: Color(0xFFE65C00),
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}
