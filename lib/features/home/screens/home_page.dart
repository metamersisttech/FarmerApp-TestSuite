import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/mixins/location_mixin.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/home/widgets/home_search_bar.dart';
import 'package:flutter_app/features/home/widgets/profile_section.dart';
import 'package:flutter_app/features/home/widgets/quick_actions_section.dart';
import 'package:flutter_app/features/home/widgets/recent_listing_section.dart';
import 'package:flutter_app/features/home/widgets/recently_viewed_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/features/viewalllistings/screens/viewalllistings_page.dart';
import 'package:flutter_app/main.dart' show routeObserver;
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
  final Function(int)? onNavigateToTab;

  const HomePage({super.key, this.user, this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        ToastMixin,
        HomeStateMixin,
        LocationMixin,
        WidgetsBindingObserver,
        RouteAware {
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
      homeController.loadFavorites(); // Load favorites on page load
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
    print(
      '[HomePage] 🔄 Returned to home page (back navigation), refreshing recently viewed...',
    );
    fetchRecentlyViewedListings();
    homeController.loadFavorites(); // Reload favorites when returning to page
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
    final displayName =
        user?.displayName ?? user?.firstName ?? user?.username ?? 'Guest';

    return Material(
      color: Colors.grey[100], // Match the background color
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                      onMarketplaceTap: () async {
                        final selectedTab = await Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewAllListingsPage(),
                          ),
                        );
                        if (selectedTab != null &&
                            widget.onNavigateToTab != null) {
                          widget.onNavigateToTab!(selectedTab);
                        }
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
                      isFavorite: (listingId) =>
                          homeController.isListingFavorited(listingId),
                    ),

                    // Fresh Recommendations Section
                    RecentListingSection(
                      title: 'Fresh recommendations',
                      listings: homeController.listings,
                      isLoading: homeController.isLoading,
                      onActionPressed: () async {
                        final selectedTab = await Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewAllListingsPage(),
                          ),
                        );
                        if (selectedTab != null &&
                            widget.onNavigateToTab != null) {
                          widget.onNavigateToTab!(selectedTab);
                        }
                      },
                      onListingTap: handleListingTap,
                    ),

                    // Add bottom padding for the bottom nav bar
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          onNotificationTap: handleNotificationTap,
          notificationCount: 3,
        ),

        // Search Bar
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
