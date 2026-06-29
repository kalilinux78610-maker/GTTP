import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/theme/app_theme.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.microtask(_checkAuthStatus);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Jailbreak/Root Detection
    bool jailbroken = false;
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
    } catch (_) {}

    if (jailbroken) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Security Risk Detected', style: TextStyle(color: Colors.red)),
          content: Text('This app cannot run on a jailbroken or rooted device for security reasons. Please use a secure device.'),
        ),
      );
      return;
    }

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
    } on ApiException catch (e) {
      // Only log the user out if the API explicitly rejects the token (401).
      // If it's a network timeout (offline), we MUST return true to let them
      // enter the app and see the cached data!
      if (e.statusCode == 401 || e.message.toLowerCase().contains('session expired')) {
        await storage.clearTokens();
        await storage.clearDisplayName();
        return false;
      }
      return true;
    } catch (_) {
      // Fallback for non-API errors (e.g. SocketException)
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: SizedBox(
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
            ),
            const SizedBox(height: 32),
            // Removed CircularProgressIndicator, the pulsating logo indicates loading
          ],
        ),
      ),
    );
  }
}
