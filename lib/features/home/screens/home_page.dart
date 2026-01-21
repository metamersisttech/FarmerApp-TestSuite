import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/mixins/location_mixin.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
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
/// 
/// Architecture:
/// - UI only in this file (build methods)
/// - Business logic in HomeStateMixin
/// - Location logic in LocationMixin
/// - Data management in HomeController
/// - API calls in HomeService
class HomePage extends StatefulWidget {
  final UserModel? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with ToastMixin, HomeStateMixin, LocationMixin {
  
  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    initializeHomeController();

    // Initialize data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchListings();
      checkLocationPermission();
      loadUserFromStorage();
      checkLocationServiceStatus();
    });
  }

  @override
  void dispose() {
    disposeHomeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract display name from user
    final user = currentUser ?? widget.user;
    final displayName = user?.displayName ?? 
                        user?.firstName ?? 
                        user?.username ?? 
                        'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header: Profile Section with overlapping Search Bar
            _buildProfileWithSearch(displayName),

            // Add spacing for the overlapping search bar
            const SizedBox(height: 30),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horizontal Scrolling Templates
                    _buildScrollingTemplates(),

                    // Quick Actions Section
                    QuickActionsSection(
                      onMarketplaceTap: () {
                        HomeNavigationService.toMarketplace(context);
                      },
                      onVetServicesTap: () {
                        HomeNavigationService.toVetServices(context);
                      },
                    ),

                    // Recent Listing Section
                    RecentListingSection(
                      listings: homeController.listings,
                      isLoading: homeController.isLoading,
                      onActionPressed: () {
                        showComingSoonMessage('Marketplace');
                      },
                      onListingTap: handleListingTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Add Button
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: handleAddTap,
          backgroundColor: AppTheme.authPrimaryColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentBottomNavIndex,
        onTap: handleBottomNavTap,
      ),
    );
  }

  /// Build profile section with overlapping search bar
  Widget _buildProfileWithSearch(String displayName) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Profile Section
        ProfileSection(
          firstName: displayName,
          location: currentLocationText,
          notificationCount: 3,
          onNotificationTap: handleNotificationTap,
          onProfileTap: handleProfileTap,
          onWalletTap: handleWalletTap,
          onLocationTap: handleLocationTap,
        ),

        // Search Bar positioned below profile section
        Positioned(
          bottom: -20,
          left: 20,
          right: 20,
          child: HomeSearchBar(onChanged: handleSearch),
        ),
      ],
    );
  }

  /// Build scrolling templates section
  Widget _buildScrollingTemplates() {
    return ScrollingTemplates(
      templates: [
        TemplateCardData(
          title: 'New Listings',
          subtitle: 'Check out latest animals',
          icon: Icons.fiber_new,
          backgroundColor: AppTheme.authPrimaryColor,
          buttonText: 'View Now',
          onPressed: () {
            showComingSoonMessage('New Listings');
          },
        ),
        TemplateCardData(
          title: 'Vet Discount',
          subtitle: 'Special offers for you',
          icon: Icons.local_hospital,
          backgroundColor: Colors.orange,
          buttonText: 'View Now',
          onPressed: () {
            showComingSoonMessage('Vet Discount');
          },
        ),
        TemplateCardData(
          title: 'Premium Feed',
          subtitle: 'Quality feed at best price',
          icon: Icons.grass,
          backgroundColor: Colors.green,
          buttonText: 'Shop Now',
          onPressed: () {
            showComingSoonMessage('Premium Feed');
          },
        ),
        TemplateCardData(
          title: 'Transportation',
          subtitle: 'Book transport services',
          icon: Icons.local_shipping,
          backgroundColor: Colors.deepPurple,
          buttonText: 'Book Now',
          onPressed: () {
            showComingSoonMessage('Transportation');
          },
        ),
      ],
    );
  }
}
