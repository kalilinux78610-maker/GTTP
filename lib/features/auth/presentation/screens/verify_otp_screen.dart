import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/core/widgets/custom_button.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  final bool isPasswordReset;
  const VerifyOtpScreen({super.key, required this.email, this.isPasswordReset = false});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorText;
  
  // Resend OTP variables
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;
  bool _isResending = false;

  // Expire OTP variables
  Timer? _expireTimer;
  int _expireSeconds = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    _redirectIfAlreadySignedIn();
    _startTimers();
    for (var c in _controllers) {
      c.addListener(() => setState(() {}));
    }
  }

  /// If we already have a session token, skip OTP (login flow only — not password reset).
  Future<void> _redirectIfAlreadySignedIn() async {
    if (widget.isPasswordReset) return;
    final token = await ref.read(secureStorageProvider).getAccessToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.go('/dashboard');
    }
  }

  void _startTimers() {
    _startResendTimer();
    _startExpireTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _startExpireTimer() {
    setState(() {
      _expireSeconds = 180;
    });
    _expireTimer?.cancel();
    _expireTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_expireSeconds > 0) {
        setState(() => _expireSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedExpireTime {
    final minutes = (_expireSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_expireSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _handleResendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
      _errorText = null;
    });

    try {
      await ref.read(authRepositoryProvider).resendOtp();
      if (!mounted) return;
      _startTimers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: AppTheme.signalGreen,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = 'Unable to resend OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  bool get _isButtonEnabled =>
      _controllers.every((c) => c.text.isNotEmpty) && _expireSeconds > 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _expireTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorText = 'Please enter the complete 6-digit OTP');
      return;
    }

    if (widget.isPasswordReset) {
      // In the forgot password flow, the backend expects the OTP to be sent
      // along with the new password to /auth/reset-password.
      // If we call verifyOtp here, backend consumes it and resetPassword will fail with "Invalid OTP",
      // and unfortunately /auth/verify-otp also issues an access token logging them in.
      // So we skip verification here and let ResetPasswordScreen handle it.
      context.push(
        '/reset-password',
        extra: {'email': widget.email, 'otp': otp},
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(
            otp: otp,
          );
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // On success (no exception thrown), redirect to dashboard
      ref.invalidate(userModelProvider);
      ref.invalidate(dashboardDataProvider);
      context.go('/dashboard');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Unable to verify OTP. Please try again.';
      });
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppTheme.deepNavy,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppTheme.bgPage,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryBlue,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          setState(() => _errorText = null);
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
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

              // ── Bottom: OTP Card ──
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
                      onTap: () async {
                        await ref.read(secureStorageProvider).clearPendingUserId();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios,
                              size: 14, color: AppTheme.primaryBlue),
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
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        "Enter the 6-digit OTP sent to\n${widget.email}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // OTP Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (i) => _buildOtpBox(i),
                      ),
                    ),

                    if (_errorText != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppTheme.signalRed, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _errorText!,
                            style: TextStyle(
                              color: AppTheme.signalRed,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 24),

                    // Expiration timer display
                    Center(
                      child: Text(
                        _expireSeconds > 0 
                            ? "OTP expires in $_formattedExpireTime" 
                            : "OTP has expired. Please resend.",
                        style: TextStyle(
                          color: _expireSeconds > 0 ? AppTheme.textMuted : AppTheme.signalRed,
                          fontSize: 13,
                          fontWeight: _expireSeconds > 0 ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Resend OTP
                    Center(
                      child: _isResending
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryBlue,
                              ),
                            )
                          : TextButton(
                              onPressed: _canResend ? _handleResendOTP : null,
                              child: Text.rich(
                                TextSpan(
                                  text: "Didn't receive OTP? ",
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _canResend
                                          ? "Resend"
                                          : "Wait ${_resendSeconds}s",
                                      style: TextStyle(
                                        color: _canResend
                                            ? AppTheme.primaryBlue
                                            : AppTheme.textMuted.withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Verify OTP Button
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
                            text: "Verify OTP",
                            isEnabled: _isButtonEnabled,
                            onPressed: _handleVerifyOTP,
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
