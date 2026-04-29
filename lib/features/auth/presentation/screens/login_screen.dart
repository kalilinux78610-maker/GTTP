import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/widgets/custom_text_field.dart';
import 'package:gttp/core/widgets/custom_button.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.sessionExpired = false});

  final bool sessionExpired;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;
  bool _sessionExpiredMessageShown = false;

  bool get _isButtonEnabled =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.sessionExpired && !_sessionExpiredMessageShown) {
      _sessionExpiredMessageShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired, please login again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? emailErr;
    String? passwordErr;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      emailErr = 'Email is required';
    } else if (!RegExp(r'^[\w.+-]+@[\w.-]+\.\w{2,}$').hasMatch(email)) {
      emailErr = 'Enter a valid email address';
    }

    if (password.isEmpty) {
      passwordErr = 'Password is required';
    } else if (password.length < 6) {
      passwordErr = 'Password must be at least 6 characters';
    }

    setState(() {
      _usernameError = emailErr;
      _passwordError = passwordErr;
    });

    return emailErr == null && passwordErr == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(
            usernameOrEmail: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (!mounted) return;
      setState(() => _isLoading = false);

      final storage = ref.read(secureStorageProvider);
      final accessToken = await storage.getAccessToken();
      final pendingUserId = await storage.getPendingUserId();
      if (!mounted) return;

      final email = _emailController.text.trim();
      if (pendingUserId != null) {
        context.push(
          '/verify-otp',
          extra: {'email': email},
        );
        return;
      }
      if (accessToken != null && accessToken.isNotEmpty) {
        context.go('/dashboard');
        return;
      }

      _showFailedDialog('Could not complete sign-in. Please try again.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _passwordError = e.message;
      });
      _showFailedDialog(e.message);
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Log crash in debug mode so we can diagnose
      debugPrint('[Login] Unexpected error: $e\n$st');
      _showFailedDialog(
        kDebugMode ? e.toString() : 'Something went wrong. Please try again.',
      );
    }
  }

  void _showFailedDialog([String? errorMessage]) {
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.errorLight5,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.signalRed,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage ?? 'Invalid email or password. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.signalRed,
                        foregroundColor: AppTheme.white,
                        disabledBackgroundColor: AppTheme.errorLight2,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          AppTheme.signalRed,
                        ),
                      ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
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
                    // Logo
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

              // ── Bottom: Login Card ──
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
                    const SizedBox(height: 12),
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
                          const Center(
                            child: Text(
                              "Login to your account",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepNavy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Username",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepNavy,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: "Username",
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            errorText: _usernameError,
                            onChanged: (_) =>
                                setState(() => _usernameError = null),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepNavy,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: "Enter your password",
                            prefixIcon: Icons.lock_outline,
                            isPassword: !_isPasswordVisible,
                            suffixIcon: _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onSuffixTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            controller: _passwordController,
                            errorText: _passwordError,
                            onChanged: (_) =>
                                setState(() => _passwordError = null),
                          ),
                          const SizedBox(height: 32),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryBlue,
                                  ),
                                )
                              : CustomButton(
                                  text: "Login",
                                  isEnabled: _isButtonEnabled,
                                  onPressed: _handleLogin,
                                ),
                          const SizedBox(height: 24),
                          const Divider(
                            color: AppTheme.borderLight,
                            thickness: 1,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
