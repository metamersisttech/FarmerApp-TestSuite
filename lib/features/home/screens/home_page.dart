import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/home/widgets/home_search_bar.dart';
import 'package:flutter_app/features/home/widgets/profile_section.dart';
import 'package:flutter_app/features/home/widgets/quick_actions_section.dart';
import 'package:flutter_app/features/home/widgets/recent_listing_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Home Page
///
/// Main screen after user logs in.
/// Features a fixed bottom navigation bar while content scrolls.
class HomePage extends StatefulWidget {
  final UserModel? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentBottomNavIndex = 0;

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        // Navigate to Chat
        // TODO: Implement chat navigation
        break;
      case 2:
        // Navigate to Sell/Create Ad
        // TODO: Implement sell navigation
        break;
      case 3:
        // Navigate to My Ads
        // TODO: Implement my ads navigation
        break;
      case 4:
        // Navigate to Saved/Liked
        // TODO: Implement saved navigation
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract first name from user, fallback to 'Guest'
    final firstName = widget.user?.firstName ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Section with overlapping Search Bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Profile Section
                ProfileSection(
                  firstName: firstName,
                  notificationCount: 3,
                  onNotificationTap: () {},
                  onProfileTap: () {},
                  onWalletTap: () {},
                ),
                
                // Search Bar positioned below profile section
                Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: HomeSearchBar(
                    onChanged: (value) {
                      // TODO: Implement search
                    },
                  ),
                ),
              ],
            ),

            // Add spacing for the overlapping search bar
            const SizedBox(height: 35),

          // 3. Horizontal Scrolling Templates (Fixed)
          ScrollingTemplates(
            templates: [
              TemplateCardData(
                title: 'New Listings',
                subtitle: 'Check out latest animals',
                icon: Icons.fiber_new,
                backgroundColor: AppTheme.authPrimaryColor,
                buttonText: 'View Now',
                onPressed: () {},
              ),
              TemplateCardData(
                title: 'Vet Discount',
                subtitle: 'Special offers for you',
                icon: Icons.local_hospital,
                backgroundColor: Colors.orange,
                buttonText: 'View',
                onPressed: () {},
              ),
              TemplateCardData(
                title: 'Premium Feed',
                subtitle: 'Quality feed at best price',
                icon: Icons.grass,
                backgroundColor: Colors.green,
                buttonText: 'Shop Now',
                onPressed: () {},
              ),
              TemplateCardData(
                title: 'Transportation',
                subtitle: 'Book transport services',
                icon: Icons.local_shipping,
                backgroundColor: Colors.deepPurple,
                buttonText: 'Book Now',
                onPressed: () {},
              ),
            ],
          ),

          // 4. Quick Actions Section (Fixed)
          const QuickActionsSection(),

          // 5. Recent Listing Section (Scrollable - takes remaining space)
          Expanded(
            child: RecentListingSection(
              onActionPressed: () {},
            ),
          ),
          ],
        ),
      ),
      // Bottom Navigation Bar (Fixed Footer)
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}
