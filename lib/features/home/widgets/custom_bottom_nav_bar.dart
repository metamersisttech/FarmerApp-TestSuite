import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Custom Bottom Navigation Bar for Home Page
///
/// Features:
/// - 4 navigation items (Home, Listings, AI, Community)
/// - Icon-only design with subtle backgrounds
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
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

              // 3. AI Tools
              _NavBarItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                isActive: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),

              // 4. Community
              _NavBarItem(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups_rounded,
                isActive: currentIndex == 3,
                onTap: () => onTap?.call(3),
              ),
            ],
          ),
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
