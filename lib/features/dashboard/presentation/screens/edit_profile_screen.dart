import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/widgets/custom_text_field.dart';
import 'package:gttp/core/widgets/custom_button.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';


class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String _role = '';
  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile() async {
    final user = await ref.read(secureStorageProvider).getUserModel();
    if (!mounted) return;
    setState(() {
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phone ?? '';
      _role = user?.role ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Color get _themeColor {
    final roleRaw = _role.toLowerCase();
    if (roleRaw.contains('principal')) return const Color(0xFFE65C00);
    if (roleRaw.contains('coordinator')) return const Color(0xFF357AB6);
    if (roleRaw.contains('teacher') || roleRaw.contains('faculty')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF357AB6);
  }

  bool _validate() {
    String? nameErr;
    String? phoneErr;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      nameErr = 'Please enter your name';
    }
    if (phone.isEmpty) {
      phoneErr = 'Please enter your phone number';
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
    });
    return nameErr == null && phoneErr == null;
  }

  Future<void> _saveProfile() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final storage = ref.read(secureStorageProvider);
      
      // Update data on the backend API
      await ref.read(authRemoteDataSourceProvider).updateUserProfile({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      // Update local storage manually just in case
      final user = await storage.getUserModel();
      if (user != null) {
        final updatedUser = user.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        await storage.saveUserModel(updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeColor = _themeColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Container(
            height: 140 + topPadding,
            width: double.infinity,
            color: themeColor,
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding + 24, left: 24, right: 24),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (context.canPop()) context.pop();
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
                const SizedBox(width: 16),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 100 + topPadding, left: 24, right: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Full Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A3A4A),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    errorText: _nameError,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Phone Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A3A4A),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _phoneController,
                    hintText: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    errorText: _phoneError,
                    onChanged: (_) => setState(() => _phoneError = null),
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          text: 'Save Changes',
                          onPressed: _saveProfile,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
