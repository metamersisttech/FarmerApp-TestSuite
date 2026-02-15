import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Custom Bottom Navigation Bar for Home Page
///
/// Features:
/// - 4 navigation items (Home, Listings, Community, Profile)
/// - Icon-only design with subtle backgrounds
/// - Notched center for FAB
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Home
            _NavBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              isActive: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),

            // 2. Listings/Farm
            _NavBarItem(
              icon: Icons.storefront_outlined,
              activeIcon: Icons.storefront_rounded,
              isActive: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),

            // Center space for FAB
            const SizedBox(width: 56),

            // 3. Community (moved from index 3)
            _NavBarItem(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups_rounded,
              isActive: currentIndex == 2,
              onTap: () => onTap?.call(2),
            ),

            // 4. Profile (NEW - replaces AI Tools)
            _NavBarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              isActive: currentIndex == 3,
              onTap: () => onTap?.call(3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual navigation bar item with icon only
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.authPrimaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? AppTheme.authPrimaryColor : Colors.grey[500],
          size: 26,
        ),
      ),
    );
  }
}
