import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/widgets/app_bottom_nav.dart';
import 'package:gttp/features/notices/presentation/providers/notices_provider.dart';

/// Persistent bottom navigation for all main app tabs (Dashboard, Notices, Courses, Profile).
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    final noticesBadge = ref.watch(roleFilteredNoticesProvider).maybeWhen(
          data: (notices) {
            final unread = notices.where((n) => !n.isRead).length;
            return unread == 0 ? null : unread.toString();
          },
          orElse: () => null,
        );

    // Nav bar = 70px height + 20px gap from bottom + system safe area
    // By injecting this as MediaQuery bottom padding, every screen's
    // SafeArea / ListView padding automatically accounts for the nav bar.
    final systemBottom = MediaQuery.of(context).padding.bottom;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    // Only add clearance if the bottom nav is visible
    final navBarClearance = isKeyboardOpen ? systemBottom : 70.0 + 20.0 + systemBottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. If we are NOT on the Dashboard tab, switch to Dashboard tab instead of exiting.
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        // 2. If we ARE on the Dashboard tab, require double back press to exit.
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Exit the app
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.of(context).padding.copyWith(
                  bottom: navBarClearance,
                ),
              ),
              child: widget.navigationShell,
            ),
            if (!isKeyboardOpen)
              Positioned(
                left: 20,
                right: 20,
                bottom: systemBottom + 20,
                child: AppBottomNav(
                  activeIndex: widget.navigationShell.currentIndex,
                  reportsBadge: noticesBadge,
                  onTabTap: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation: index == widget.navigationShell.currentIndex,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
