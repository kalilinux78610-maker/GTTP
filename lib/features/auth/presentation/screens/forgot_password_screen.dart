import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/widgets/custom_text_field.dart';
import 'package:gttp/core/widgets/custom_button.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;

  bool get _isButtonEnabled => _emailController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    String? err;

    if (email.isEmpty) {
      err = 'Email address is required';
    } else if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(email)) {
      err = 'Enter a valid email address';
    }

    setState(() => _emailError = err);
    return err == null;
  }

  Future<void> _handleSendOTP() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(email: _emailController.text.trim());
      if (!mounted) return;
      setState(() => _isLoading = false);
      // user_id is saved to secure storage inside the data layer.
      // We only pass email so the VerifyOtpScreen can display it to the user.
      context.push(
        '/verify-otp',
        extra: {
          'email': _emailController.text.trim(),
          'isPasswordReset': true,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = 'Unable to send OTP. Please try again.';
      });
    }
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

              // ── Bottom: Forgot Password Card ──
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    // ── Grab bar (flush at top) ──
                    const SizedBox(height: 18),
                    Center(
                      child: Container(
                        width: 66,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.saffronOrange,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // ── Rest of card content with padding ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  size: 14,
                                  color: AppTheme.primaryBlue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Back to Login',
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
                              "Forgot Password",
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
                              "Enter your email address to receive OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Email Address",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepNavy,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: "Enter Your Email",
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            errorText: _emailError,
                            onChanged: (_) =>
                                setState(() => _emailError = null),
                          ),
                          const SizedBox(height: 32),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryBlue,
                                  ),
                                )
                              : CustomButton(
                                  text: "Send OTP",
                                  isEnabled: _isButtonEnabled,
                                  onPressed: _handleSendOTP,
                                ),
                        ], // inner Column children
                      ), // inner Column
                    ), // Padding
                  ], // outer Column children
                ), // outer Column
              ), // Card Container
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
