import 'package:flutter/material.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';

class DashboardRoleWidgets {
  static Widget buildOverviewCard({
    required AppUserRole role,
    required DashboardModel data,
    required Widget Function(String value, String label, Color color) buildStatItem,
    required int coursesFallback,
    required int schedulesFallback,
    required int certsFallback,
  }) {
    if (role == AppUserRole.principal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStatItem('${data.totalStudents}', 'Students', const Color(0xFF3286C9)),
          buildStatItem('${data.totalFaculties}', 'Teachers', const Color(0xFFE65C00)),
          buildStatItem('${data.totalCourses}', 'Active Courses', const Color(0xFF209E5A)),
        ],
      );
    } else if (role == AppUserRole.coordinator) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStatItem('${data.totalSchools}', 'Institutes', const Color(0xFF3286C9)),
          buildStatItem('${data.totalStudents}', 'Students', const Color(0xFFE65C00)),
          buildStatItem('${data.totalCourses}', 'Courses', const Color(0xFF209E5A)),
        ],
      );
    } else {
      // Default / Student / Teacher fallback
      final displayCourses = coursesFallback > 0 ? coursesFallback : (data.totalCourses > 0 ? data.totalCourses : data.totalClasses);
      final displaySchedules = data.totalSchedules > 0 ? data.totalSchedules : schedulesFallback;
      final displayCerts = data.totalCertificates > 0 ? data.totalCertificates : certsFallback;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStatItem('$displayCourses', 'Total Courses', const Color(0xFF3286C9)),
          buildStatItem('$displaySchedules', 'Schedules', const Color(0xFFE65C00)),
          buildStatItem('$displayCerts', 'Certificates', const Color(0xFF209E5A)),
        ],
      );
    }
  }

  static Widget buildQuickAccessList({
    required AppUserRole role,
    required DashboardModel data,
    required Widget Function({
      required String title,
      required String subtitle,
      String? trailing,
      required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required VoidCallback onTap,
    }) buildQuickAccessCard,
    required int certsFallback,
    required VoidCallback onNavigateCertificates,
    required VoidCallback onNavigateGallery,
  }) {
    if (role == AppUserRole.principal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Staff Directory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A4A),
            ),
          ),
          const SizedBox(height: 16),
          if (data.facultiesList == null || data.facultiesList!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text('No staff members found.'),
            )
          else
            _buildHorizontalList(
              items: data.facultiesList!,
              itemBuilder: (context, item) => _buildFacultyCard(item),
            ),
          const SizedBox(height: 24),
          const Text(
            'Recent Students',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A4A),
            ),
          ),
          const SizedBox(height: 16),
          if (data.studentsList == null || data.studentsList!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text('No students found.'),
            )
          else
            _buildHorizontalList(
              items: data.studentsList!,
              itemBuilder: (context, item) => _buildStudentCard(item),
            ),
        ],
      );
    } else if (role == AppUserRole.coordinator) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Managed Institutes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A4A),
            ),
          ),
          const SizedBox(height: 16),
          if (data.institutesList == null || data.institutesList!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text('No institutes found.'),
            )
          else
            ...data.institutesList!.map((item) => _buildInstituteCard(item)),
        ],
      );
    } else {
      // Default / Student / Teacher fallback
      final certCount = data.totalCertificates > 0 ? data.totalCertificates : certsFallback;
      final certTrailing = '$certCount Earned';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3A4A),
            ),
          ),
          const SizedBox(height: 16),
          buildQuickAccessCard(
            title: 'Certificates',
            subtitle: 'View all your earned certificates',
            trailing: certTrailing,
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFF209E5A),
            onTap: onNavigateCertificates,
          ),
          buildQuickAccessCard(
            title: 'Gallery',
            subtitle: 'View school events & competitions',
            icon: Icons.photo_library_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFFEA3A3D),
            onTap: onNavigateGallery,
          ),
        ],
      );
    }
  }

  static Widget _buildHorizontalList({
    required List<dynamic> items,
    required Widget Function(BuildContext, dynamic) itemBuilder,
  }) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length > 10 ? 10 : items.length, // Limit preview
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }

  static Widget _buildFacultyCard(dynamic item) {
    final map = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
    final name = map['name']?.toString() ?? 'Unknown';
    final dept = map['department']?.toString() ?? map['role']?.toString() ?? 'Staff';
    final avatar = map['avatar']?.toString();

    return _buildProfileCard(name, dept, avatar, const Color(0xFFE65C00));
  }

  static Widget _buildStudentCard(dynamic item) {
    final map = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
    final name = map['name']?.toString() ?? 'Unknown';
    final roll = map['roll_number']?.toString() ?? '';
    final studentClass = map['class']?.toString() ?? '';
    final subtitle = [roll, studentClass].where((e) => e.isNotEmpty).join(' • ');
    final avatar = map['avatar']?.toString();

    return _buildProfileCard(name, subtitle.isEmpty ? 'Student' : subtitle, avatar, const Color(0xFF3286C9));
  }

  static Widget _buildProfileCard(String name, String subtitle, String? avatarUrl, Color themeColor) {
    final initials = name.isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : 'U';

    Widget placeholder = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: themeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );

    final resolvedAvatar = CourseAssetUrl.resolve(avatarUrl);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (resolvedAvatar != null && resolvedAvatar.isNotEmpty)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: resolvedAvatar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => placeholder,
                  errorWidget: (context, url, error) => placeholder,
                ),
              ),
            )
          else
            placeholder,
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2A3A4A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8692A6),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInstituteCard(dynamic item) {
    final map = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
    final name = map['name']?.toString() ?? 'Unknown Institute';
    final code = map['code']?.toString() ?? '';
    final type = map['institute_type']?.toString() ?? 'School';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3286C9).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance, color: Color(0xFF3286C9)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2A3A4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [code, type].where((e) => e.isNotEmpty).join(' • '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8692A6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
