
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gttp/features/courses/data/models/course_asset_url.dart';
import 'package:gttp/core/auth/user_role.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';

import 'package:gttp/features/dashboard/data/datasources/gttp_remote_datasource.dart';

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
  String _studentClass = '';
  String _parentMobile = '';
  String _instituteType = '';
  String _avatar = '';
  bool _isUploadingAvatar = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile() async {
    final storage = ref.read(secureStorageProvider);
    
    // --- 1. FAST PATH: Load from local cache immediately ---
    var user = await storage.getUserModel();
    final fallbackName = await storage.getDisplayName();
    var dashboard = ref.read(dashboardDataProvider).value;
    
    void updateState(dynamic u, dynamic d) {
      if (!mounted) return;
      String roleRaw = u?.effectiveRole ?? '';
      String display = u?.name ?? '';
      if (display.isEmpty && fallbackName != null) {
        display = fallbackName;
      }
      String email = u?.email ?? '';

      // Hardcode override since API doesn't return full data
      if (email.toLowerCase().contains('shreyanshvasava@efsouls.com') ||
          email.toLowerCase().contains('superadmin') ||
          display.toLowerCase().contains('shreyanshvasava') ||
          display.toLowerCase().contains('super admin')) {
        if (roleRaw.isEmpty || roleRaw == '5' || roleRaw == 'student') {
          roleRaw = '0'; // Super Admin role level
        }
        if (display.isEmpty) {
          display = 'Super Admin';
        }
      }

      // Graceful fallback for empty names using email prefix
      if (display.isEmpty && email.isNotEmpty) {
        final localPart = email.split('@').first;
        display = localPart
            .replaceAll(RegExp(r'[._-]+'), ' ')
            .split(' ')
            .map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '')
            .join(' ');
      }

      var phone = u?.phone ?? '';
      var institute = u?.institute ?? '';
      var instituteType = u?.instituteType ?? '';

      if (phone.isEmpty && (d?.currentUserPhone?.isNotEmpty ?? false)) {
        phone = d!.currentUserPhone!;
      }
      if (institute.isEmpty && (d?.currentUserOrganization?.isNotEmpty ?? false)) {
        institute = d!.currentUserOrganization!;
      } else if (institute.isEmpty && (d?.schoolName?.isNotEmpty ?? false)) {
        institute = d!.schoolName!;
      }
      if (instituteType.isEmpty && (d?.currentUserInstituteType?.isNotEmpty ?? false)) {
        instituteType = d!.currentUserInstituteType!;
      } else if (instituteType.isEmpty && (d?.schoolType?.isNotEmpty ?? false)) {
        instituteType = d!.schoolType!;
      }
      
      setState(() {
        _displayName = display;
        _email = email;
        _phone = phone;
        _role = roleRaw.isNotEmpty
            ? AppUserRole.fromApi(roleRaw).label
            : AppUserRole.superAdmin.label; // Fallback for unknown
        _institute = institute;
        _studentClass = u?.studentClass ?? '';
        _parentMobile = u?.parentMobile ?? '';
        _instituteType = instituteType;
        _avatar = u?.avatar ?? '';
      });
    }

    // Update UI immediately with what we have
    updateState(user, dashboard);

    // --- 2. SLOW PATH: Fetch latest profile from backend sequentially ---
    try {
      await ref.read(authRemoteDataSourceProvider).fetchMe();
      ref.invalidate(dashboardDataProvider);
      await ref.read(dashboardDataProvider.future);
    } catch (e) {
      debugPrint('Failed to refresh profile/dashboard: $e');
    }

    if (!mounted) return;

    // Read fresh data after network fetch
    user = await storage.getUserModel();
    dashboard = ref.read(dashboardDataProvider).value;

    // Update UI again with fresh data
    updateState(user, dashboard);

    // Persist dashboard-derived fields when the user record was missing them
    if (user != null &&
        (_phone.isNotEmpty || _institute.isNotEmpty || _instituteType.isNotEmpty)) {
      final updatedUser = user.copyWith(
        phone: _phone.isNotEmpty ? _phone : user.phone,
        institute: _institute.isNotEmpty ? _institute : user.institute,
        instituteType: _instituteType.isNotEmpty ? _instituteType : user.instituteType,
      );
      if (updatedUser.phone != user.phone ||
          updatedUser.institute != user.institute ||
          updatedUser.instituteType != user.instituteType) {
        await storage.saveUserModel(updatedUser);
        ref.invalidate(userModelProvider);
      }
    }

    // Fallback: Try to fetch from students API directly if fields are missing for a student
    if (_role.toLowerCase() == 'student' && (_studentClass.isEmpty || _parentMobile.isEmpty)) {
      try {
        // Bypass cache and fetch directly to ensure we get the latest data
        final gttpDataSource = ref.read(gttpRemoteDataSourceProvider);
        final students = await gttpDataSource.getStudents();
        
        final emailLower = _email.toLowerCase();
        final me = students.firstWhere(
          (s) => (s['email'] ?? s['contact_email'] ?? '').toString().toLowerCase() == emailLower, 
          orElse: () => <String, dynamic>{}
        );
        
        if (me.isNotEmpty && mounted) {
          final newClass = (me['class'] ?? me['class_name'] ?? me['student_class'] ?? '').toString();
          final newParentMobile = (me['parent_mobile'] ?? me['parent_phone'] ?? '').toString();
          
          setState(() {
            if (_studentClass.isEmpty) _studentClass = newClass;
            if (_parentMobile.isEmpty) _parentMobile = newParentMobile;
            if (_instituteType.isEmpty) {
              _instituteType = (me['institute_type'] ?? '').toString();
            }
            if (_avatar.isEmpty) {
              _avatar = (me['avatar'] ?? '').toString();
            }
          });
          
          // Optionally save to secure storage so it persists
          if (user != null) {
            final updatedUser = user.copyWith(
              studentClass: newClass.isNotEmpty ? newClass : user.studentClass,
              parentMobile: newParentMobile.isNotEmpty ? newParentMobile : user.parentMobile,
            );
            await storage.saveUserModel(updatedUser);
            ref.invalidate(userModelProvider);
          }
        }
      } catch (e) {
        // Ignore errors if student API fails or is forbidden
        debugPrint('Direct fallback fetch failed: $e');
      }
    }

    // Fallback: Try to fetch from faculties API if fields are still missing
    final isStaffRole = _role.toLowerCase().contains('faculty') || 
                          _role.toLowerCase().contains('teacher') || 
                          _role.toLowerCase().contains('principal') || 
                          _role.toLowerCase().contains('coordinator') ||
                          _role.toLowerCase().contains('administrator');
                          
    if (isStaffRole && (_phone.isEmpty || _institute.isEmpty || _instituteType.isEmpty)) {
      try {
        final gttpDataSource = ref.read(gttpRemoteDataSourceProvider);
        final faculties = await gttpDataSource.getFaculty();
        
        final emailLower = _email.toLowerCase();
        final me = faculties.firstWhere(
          (f) {
            final userObj = f['user'] is Map ? f['user'] as Map : f;
            return (userObj['email'] ?? '').toString().toLowerCase() == emailLower;
          }, 
          orElse: () => <String, dynamic>{}
        );
        
        if (me.isNotEmpty && mounted) {
          final userObj = me['user'] is Map ? me['user'] as Map : me;
          
          String getValid(List<Map> maps, List<String> keys) {
            for (var map in maps) {
              for (var key in keys) {
                if (map[key] != null && map[key].toString().trim().isNotEmpty) {
                  return map[key].toString().trim();
                }
              }
            }
            return '';
          }

          final newPhone = getValid([userObj, me], ['phone', 'mobile', 'mobile_number']);
          final newInstitute = getValid([userObj, me], ['school_name', 'institute']);
          final newInstituteType = getValid([userObj, me], ['institute_type']);
          
          setState(() {
            if (_phone.isEmpty) _phone = newPhone;
            if (_institute.isEmpty) _institute = newInstitute;
            if (_instituteType.isEmpty) _instituteType = newInstituteType;
            if (_avatar.isEmpty) {
              _avatar = (userObj['avatar'] ?? me['avatar'] ?? '').toString();
            }
          });
          
          if (user != null) {
            final updatedUser = user.copyWith(
              phone: newPhone.isNotEmpty ? newPhone : user.phone,
              institute: newInstitute.isNotEmpty ? newInstitute : user.institute,
              instituteType: newInstituteType.isNotEmpty ? newInstituteType : user.instituteType,
            );
            await storage.saveUserModel(updatedUser);
            ref.invalidate(userModelProvider);
          }
        }
      } catch (e) {
        debugPrint('Direct faculty fallback fetch failed: $e');
      }
    }
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploadingAvatar = true);
      try {
        await ref.read(authRemoteDataSourceProvider).uploadAvatar(pickedFile.path);
        await _loadProfile(); // Refresh UI with new data
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Color get _themeColor {
    if (_role.toLowerCase() == 'principal') {
      return const Color(0xFFE65C00); // Orange
    }
    if (_role.toLowerCase() == 'national coordinator') {
      return const Color(0xFF357AB6); // Blue
    }
    if (_role.toLowerCase() == 'teacher' || _role.toLowerCase() == 'faculty') {
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
    
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final schoolLogo = dashboardAsync.value?.schoolLogo;
    
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
                    onTap: () => context.go('/dashboard'),
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
                    child: InkWell(
                      onTap: _isUploadingAvatar ? null : _pickImage,
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        children: [
                          Builder(
                            builder: (context) {
                              String? imageUrlToShow;
                              if (_avatar.isNotEmpty) {
                                imageUrlToShow = CourseAssetUrl.resolve(_avatar);
                              }
                              if (imageUrlToShow == null && schoolLogo != null && schoolLogo.isNotEmpty) {
                                imageUrlToShow = CourseAssetUrl.resolve(schoolLogo);
                              }

                              if (imageUrlToShow != null) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrlToShow,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: Text(
                                          _initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Center(
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
                                  ),
                                );
                              }
                              
                              return Center(
                                child: Text(
                                  _initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _isUploadingAvatar 
                                ? const SizedBox(
                                    width: 16, height: 16, 
                                    child: CircularProgressIndicator(strokeWidth: 2)
                                  )
                                : Icon(Icons.camera_alt, color: themeColor, size: 16),
                            ),
                          ),
                        ],
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
                        Builder(builder: (context) {
                          final infoItems = <Widget>[];

                          infoItems.add(_buildInfoItem(
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            bgColor: const Color(0xFFEFF6FF),
                            title: 'Email',
                            value: _email.isNotEmpty ? _email : 'Not Provided',
                          ));

                          if (_role.toLowerCase() != 'student' || _phone.isNotEmpty) {
                            final dashboardPhone = dashboardAsync.value?.currentUserPhone ?? '';
                            infoItems.add(_buildInfoItem(
                              icon: Icons.phone_outlined,
                              iconColor: const Color(0xFF10B981),
                              bgColor: const Color(0xFFECFDF5),
                              title: 'Phone',
                              value: _phone.isNotEmpty
                                  ? _phone
                                  : (dashboardPhone.isNotEmpty ? dashboardPhone : 'Not Provided'),
                            ));
                          }

                          if (_role.toLowerCase() == 'student') {
                            if (_studentClass.isNotEmpty) {
                              infoItems.add(_buildInfoItem(
                                icon: Icons.class_outlined,
                                iconColor: const Color(0xFFF97316),
                                bgColor: const Color(0xFFFFF7ED),
                                title: 'Class',
                                value: _studentClass,
                              ));
                            }
                          }
                          
                          infoItems.add(_buildInfoItem(
                            icon: Icons.apartment_outlined,
                            iconColor: const Color(0xFFF97316),
                            bgColor: const Color(0xFFFFF7ED),
                            title: 'Organization',
                            value: _institute.isNotEmpty && _institute.toLowerCase() != 'school'
                                ? _institute
                                : (dashboardAsync.value?.currentUserOrganization?.isNotEmpty == true
                                    ? dashboardAsync.value!.currentUserOrganization!
                                    : (dashboardAsync.value?.schoolName?.isNotEmpty == true
                                        ? dashboardAsync.value!.schoolName!
                                        : (_role.toLowerCase().contains('super admin') || _role.toLowerCase().contains('admin') ? 'GTTP' : 'Not Provided'))),
                          ));

                          if (_role.toLowerCase() == 'student' && _parentMobile.isNotEmpty) {
                            infoItems.add(_buildInfoItem(
                              icon: Icons.family_restroom_outlined,
                              iconColor: const Color(0xFFEC4899),
                              bgColor: const Color(0xFFFCE7F3),
                              title: "Parent's Mobile",
                              value: _parentMobile,
                            ));
                          }

                          final dashboardSchoolType =
                              dashboardAsync.value?.currentUserInstituteType ??
                              dashboardAsync.value?.schoolType ??
                              '';
                          
                          String displayType = _instituteType.isNotEmpty
                              ? _instituteType
                              : dashboardSchoolType;
                              
                          if (displayType.isEmpty && _institute.toLowerCase() == 'school') {
                            displayType = 'school';
                          }

                          final formattedType = displayType.isNotEmpty
                              ? '${displayType[0].toUpperCase()}${displayType.substring(1)}'
                              : 'Not Provided';

                          infoItems.add(_buildInfoItem(
                            icon: Icons.account_balance_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            bgColor: const Color(0xFFEFF6FF),
                            title: 'Institute Type',
                            value: formattedType,
                          ));

                          final childrenWithDividers = <Widget>[];
                          for (int i = 0; i < infoItems.length; i++) {
                            childrenWithDividers.add(infoItems[i]);
                            if (i < infoItems.length - 1) {
                              childrenWithDividers.add(_buildDivider());
                            }
                          }
                          return Column(children: childrenWithDividers);
                        }),
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
                      icon: Icon(Icons.settings_outlined, color: themeColor, size: 24),
                      label: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: themeColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                      icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),


                  const SizedBox(height: 120), // Space for bottom nav
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
