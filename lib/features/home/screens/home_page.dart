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
import 'package:flutter_app/features/home/widgets/recently_viewed_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/main.dart' show routeObserver;

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
    with ToastMixin, HomeStateMixin, LocationMixin, WidgetsBindingObserver, RouteAware {
  
  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    initializeHomeController();
    
    // Add observer to detect when app resumes
    WidgetsBinding.instance.addObserver(this);

    // Initialize data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchListings();
      fetchRecentlyViewedListings();
      checkLocationPermission();
      loadUserFromStorage();
      checkLocationServiceStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up
    // This happens when user navigates BACK to this page from another page
    print('[HomePage] 🔄 Returned to home page (back navigation), refreshing recently viewed...');
    fetchRecentlyViewedListings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh recently viewed when app resumes
    if (state == AppLifecycleState.resumed) {
      print('[HomePage] 🔄 App resumed, refreshing recently viewed...');
      fetchRecentlyViewedListings();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
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
            // Fixed Header: Profile Section with Search Bar
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

                    // Recently Viewed Ads Section
                    RecentlyViewedSection(
                      listings: recentlyViewedListings,
                      isLoading: isLoadingRecentlyViewed,
                      onListingTap: handleListingTap,
                      onViewAll: () {
                        HomeNavigationService.toRecentlyViewed(context);
                      },
                    ),

                    // Recent Listing Section
                    RecentListingSection(
                      listings: homeController.listings,
                      isLoading: homeController.isLoading,
                      onActionPressed: () {
                        HomeNavigationService.toMarketplace(context);
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
      // Floating Add Button - Centered in Bottom Nav Bar
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddTap,
        backgroundColor: Colors.green,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentBottomNavIndex,
        onTap: handleBottomNavTap,
      ),
    );
  }

  /// Build profile section with search bar and action icons
  Widget _buildProfileWithSearch(String displayName) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Profile Section (simplified)
        ProfileSection(
          firstName: displayName,
          location: currentLocationText,
          onLocationTap: handleLocationTap,
        ),

        // Search Bar with Favorite and Notification icons
        Positioned(
          bottom: -20,
          left: 20,
          right: 20,
          child: Row(
            children: [
              // Search Bar
              Expanded(
                child: HomeSearchBar(onChanged: handleSearch),
              ),
              const SizedBox(width: 12),
              
              // Favorite Icon
              _buildActionIcon(
                icon: Icons.favorite_border,
                onTap: () {
                  // Handle favorite tap - will be implemented in mixin
                  final result = HomeNavigationService.toSaved(context);
                  if (!result.success && result.message != null) {
                    showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
                  }
                },
              ),
              const SizedBox(width: 12),
              
              // Notification Icon with badge
              _buildActionIcon(
                icon: Icons.notifications_outlined,
                onTap: handleNotificationTap,
                badgeCount: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build action icon button with optional badge
  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppTheme.authPrimaryColor,
              size: 24,
            ),
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
