import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_checkAuthStatus);
  }

  Future<void> _checkAuthStatus() async {
    final storage = ref.read(secureStorageProvider);
    final accessToken = await storage.getAccessToken();

    // Minimum branding delay to prevent jarring flickers
    await Future.delayed(const Duration(milliseconds: 1200));

    // Also check for pending verification
    final pendingUserId = await storage.getPendingUserId();

    if (!mounted) return;

    if (pendingUserId != null) {
      context.go('/verify-otp');
      return;
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      final isTokenValid = await _validateStoredSession();
      if (!mounted) return;
      if (!isTokenValid) {
        context.go('/login', extra: {'sessionExpired': true});
        return;
      }
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  Future<bool> _validateStoredSession() async {
    final storage = ref.read(secureStorageProvider);
    try {
      await ref.read(apiClientProvider).get('/dashboard', requiresAuth: true);
      return true;
    } catch (_) {
      await storage.clearTokens();
      await storage.clearDisplayName();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 250,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: AppTheme.borderMid,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}
