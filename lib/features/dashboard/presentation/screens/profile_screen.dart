import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/auth/data/models/user_model.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _displayName = '';
  String _email = '';
  String _phone = '';
  String _role = '';
  String _institute = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile() async {
    final user = await ref.read(secureStorageProvider).getUserModel();
    if (!mounted) return;
    final roleRaw = user?.role ?? '';
    setState(() {
      _displayName = user?.name ?? '';
      _email = user?.email ?? '';
      _phone = user?.phone ?? '';
      _role = roleRaw.isNotEmpty
          ? AppUserRole.fromApi(roleRaw).label
          : roleRaw;
      _institute = user?.institute ?? '';
    });
  }

  String get _initials {
    if (_displayName.trim().isEmpty) return 'DR'; // Fallback to DR to match design
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0];
      final last = parts.last;
      if (first.isNotEmpty && last.isNotEmpty) {
        return (first[0] + last[0]).toUpperCase();
      }
    }
    return _displayName.substring(0, 1).toUpperCase();
  }

  Color get _themeColor {
    if (_role.toLowerCase() == 'principal') {
      return const Color(0xFFE65C00); // Orange
    }
    if (_role.toLowerCase() == 'national coordinator') {
      return const Color(0xFF357AB6); // Blue
    }
    if (_role.toLowerCase() == 'teacher') {
      return const Color(0xFF8B5CF6); // Purple
    }
    if (_role.toLowerCase() == 'student') {
      return const Color(0xFF357AB6); // Blue
    }
    return const Color(0xFF357AB6); // Default Blue
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeColor = _themeColor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Top Dynamic Header
            Container(
              height: 200 + topPadding,
              width: double.infinity,
              color: themeColor,
            ),
            
            // Header Content
            Padding(
              padding: EdgeInsets.only(top: topPadding + 24, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile Body
            Padding(
              padding: EdgeInsets.only(top: 150 + topPadding, left: 24, right: 24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    _displayName.trim().isEmpty ? 'User' : _displayName,
                    style: const TextStyle(
                      color: Color(0xFF2A3A4A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _role.isNotEmpty ? _role : 'Unknown Role',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoItem(
                          icon: Icons.email_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          bgColor: const Color(0xFFEFF6FF),
                          title: 'Email',
                          value: _email.isNotEmpty ? _email : 'Not Provided',
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: Icons.phone_outlined,
                          iconColor: const Color(0xFF10B981),
                          bgColor: const Color(0xFFECFDF5),
                          title: 'Phone',
                          value: _phone.isNotEmpty ? _phone : 'Not Provided',
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: Icons.apartment_outlined,
                          iconColor: const Color(0xFFF97316),
                          bgColor: const Color(0xFFFFF7ED),
                          title: 'Organization',
                          value: _institute.isNotEmpty ? _institute : 'Not Provided',
                        ),
                        _buildDivider(),
                        _buildInfoItem(
                          icon: Icons.military_tech_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          bgColor: const Color(0xFFF5F3FF),
                          title: 'Status',
                          value: 'Active',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await context.push<bool>('/profile/edit');
                        if (result == true) {
                          _loadProfile();
                        }
                      },
                      icon: Icon(Icons.settings_outlined, color: themeColor),
                      label: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: themeColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).logout();
                        ref.invalidate(userModelProvider);
                        ref.invalidate(dashboardDataProvider);
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 140), // Space for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF8692A6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2A3A4A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 68, right: 20),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
