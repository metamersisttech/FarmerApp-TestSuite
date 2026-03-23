import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/widgets/home_search_bar.dart';
import 'package:flutter_app/features/home/widgets/profile_section.dart';

/// Home page header with profile section and overlapping search bar
class HomeHeader extends StatelessWidget {
  final String displayName;
  final String location;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final int notificationCount;
  final Function(String) onSearch;

  const HomeHeader({
    super.key,
    required this.displayName,
    required this.location,
    required this.onLocationTap,
    required this.onNotificationTap,
    required this.notificationCount,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Profile Section
        ProfileSection(
          firstName: displayName,
          location: location,
          onLocationTap: onLocationTap,
          onNotificationTap: onNotificationTap,
          notificationCount: notificationCount,
        ),

        // Search Bar (overlapping at the bottom)
        Positioned(
          bottom: -20,
          left: 20,
          right: 20,
          child: HomeSearchBar(onChanged: onSearch),
        ),
      ],
    );
  }
}
