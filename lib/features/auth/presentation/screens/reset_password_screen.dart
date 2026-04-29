import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/core/widgets/custom_text_field.dart';
import 'package:gttp/core/widgets/custom_button.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  bool get _isButtonEnabled =>
      _newPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? newPwErr;
    String? confirmPwErr;

    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();

    if (newPw.isEmpty) {
      newPwErr = 'New password is required';
    } else if (newPw.length < 6) {
      newPwErr = 'Password must be at least 6 characters';
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(newPw)) {
      newPwErr = 'Password must contain letters and numbers';
    }

    if (confirmPw.isEmpty) {
      confirmPwErr = 'Please confirm your password';
    } else if (confirmPw != newPw) {
      confirmPwErr = 'Passwords do not match';
    }

    setState(() {
      _newPasswordError = newPwErr;
      _confirmPasswordError = confirmPwErr;
    });

    return newPwErr == null && confirmPwErr == null;
  }

  Future<void> _handleResetPassword() async {
    if (!_validate()) return;

    if (widget.email.isEmpty || widget.otp.isEmpty) {
      setState(() {
        _newPasswordError = 'Session expired. Please request OTP again.';
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: widget.email,
            otp: widget.otp,
            newPassword: _newPasswordController.text.trim(),
          );
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _confirmPasswordError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _confirmPasswordError = 'Unable to reset password. Please try again.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.successLight5,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppTheme.signalGreen, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Password Changed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your password has been successfully reset. Please login with your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.signalGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Pop all screens back to login
                    context.go('/');
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Top: Logo + Welcome ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryBlueLight5, AppTheme.white],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 220,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, error) => const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: AppTheme.borderMid,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Welcome to GTTP India",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom: Reset Password Card ──
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textDark.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.signalAmber],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios,
                              size: 14, color: AppTheme.primaryBlue),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        "Create a strong new password",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // New Password
                    const Text(
                      "New Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Enter New Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: !_isNewPasswordVisible,
                      suffixIcon: _isNewPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      controller: _newPasswordController,
                      errorText: _newPasswordError,
                      onChanged: (_) =>
                          setState(() => _newPasswordError = null),
                      onSuffixTap: () => setState(
                        () => _isNewPasswordVisible = !_isNewPasswordVisible,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Confirm Password
                    const Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Confirm New Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: !_isConfirmPasswordVisible,
                      suffixIcon: _isConfirmPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      controller: _confirmPasswordController,
                      errorText: _confirmPasswordError,
                      onChanged: (_) =>
                          setState(() => _confirmPasswordError = null),
                      onSuffixTap: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Reset Password Button
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          )
                        : CustomButton(
                            text: "Reset Password",
                            isEnabled: _isButtonEnabled,
                            onPressed: _handleResetPassword,
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
