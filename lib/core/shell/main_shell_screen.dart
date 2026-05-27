import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/widgets/app_bottom_nav.dart';
import 'package:gttp/features/notices/presentation/providers/notices_provider.dart';

/// Persistent bottom navigation for all main app tabs (Dashboard, Notices, Courses, Profile).
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesBadge = ref.watch(noticesNotifierProvider).maybeWhen(
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
    final navBarClearance = 70.0 + 20.0 + systemBottom;

    return Scaffold(
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
            child: navigationShell,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: systemBottom + 20,
            child: AppBottomNav(
              activeIndex: navigationShell.currentIndex,
              reportsBadge: noticesBadge,
              onTabTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
