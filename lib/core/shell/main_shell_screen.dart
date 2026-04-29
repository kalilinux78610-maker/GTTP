import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/widgets/app_bottom_nav.dart';
import 'package:gttp/features/reports/presentation/providers/reports_provider.dart';

/// Persistent bottom navigation for all main app tabs (Dashboard, Reports, Courses, Profile).
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsBadge = ref.watch(flaggedReportsProvider).maybeWhen(
          data: (reports) =>
              reports.isEmpty ? null : reports.length.toString(),
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          navigationShell,
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: AppBottomNav(
              activeIndex: navigationShell.currentIndex,
              reportsBadge: reportsBadge,
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
