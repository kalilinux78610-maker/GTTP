import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared bottom navigation — main app tabs.
///   0 = Dashboard, 1 = Reports, 2 = Courses, 3 = Profile
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeIndex,
    this.onTabTap,
    this.reportsBadge,
  });

  final int activeIndex;
  final void Function(int index)? onTabTap;
  final String? reportsBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            isSelected: activeIndex == 0,
            onTap: () {
              if (onTabTap != null) {
                onTabTap!(0);
              } else {
                context.go('/dashboard');
              }
            },
          ),
          _NavItem(
            icon: Icons.insert_page_break_outlined,
            label: 'Reports',
            isSelected: activeIndex == 1,
            badge: reportsBadge,
            onTap: () {
              if (onTabTap != null) {
                onTabTap!(1);
              } else {
                context.go('/reports');
              }
            },
          ),
          _NavItem(
            icon: Icons.menu_book_outlined,
            label: 'Courses',
            isSelected: activeIndex == 2,
            onTap: () {
              if (onTabTap != null) {
                onTabTap!(2);
              } else {
                context.go('/courses');
              }
            },
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: activeIndex == 3,
            onTap: () {
              if (onTabTap != null) {
                onTabTap!(3);
              } else {
                context.go('/profile');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF398FDE) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF8692A6),
                  size: 24,
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE65C00),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2A3A4A),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
