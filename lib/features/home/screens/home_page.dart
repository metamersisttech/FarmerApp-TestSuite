import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/mixins/location_mixin.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/transport/services/transport_navigation_service.dart';
import 'package:flutter_app/features/home/widgets/quick_actions_section.dart';
import 'package:flutter_app/features/home/widgets/recent_listing_section.dart';
import 'package:flutter_app/features/home/widgets/recently_viewed_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/features/viewalllistings/screens/viewalllistings_page.dart';
import 'package:flutter_app/features/home/widgets/home_header.dart';
import 'package:flutter_app/main.dart' show routeObserver;

/// Home Page
///
/// Main screen after user logs in.
/// Features a fixed bottom navigation bar while content scrolls.
///
/// Architecture:
/// - Screen: UI only (build method)
/// - Mixin: Business logic and state coordination
/// - Controller: Data management
/// - Service: API calls
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
    initializeHomeController(onNavigateToTab: widget.onNavigateToTab);

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.fetchListings();
      syncRecentlyViewedListings();
      homeController.loadFavorites();
      homeController.loadUserFromStorage();
      checkLocationPermission();
      checkLocationServiceStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    print(
      '[HomePage] 🔄 Returned to home page (back navigation), refreshing recently viewed...',
    );
    syncRecentlyViewedListings();
    homeController.loadFavorites();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print('[HomePage] 🔄 App resumed, refreshing recently viewed...');
      syncRecentlyViewedListings();
      
      if (returnedFromLocationSettings) {
        returnedFromLocationSettings = false;
        print('[HomePage] 📍 Returned from settings, refreshing location...');
        
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            final success = await fetchAndDisplayCurrentLocation();
            
            if (success && mounted && currentLocationText != 'Getting location...') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location updated to $currentLocationText'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        });
      }
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
    final user = currentUser ?? widget.user;
    final displayName =
        user?.displayName ?? user?.firstName ?? user?.username ?? 'Guest';

    return Material(
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            HomeHeader(
              displayName: displayName,
              location: currentLocationText,
              onLocationTap: handleLocationTap,
              onNotificationTap: () => homeController.navigateToNotifications(context),
              notificationCount: notificationUnreadCount,
              onSearch: (value) {
                updateSearchQuery(value);
                homeController.searchListings(value);
              },
            ),
            const SizedBox(height: 30),
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
                      onTransportTap: () {
                        TransportNavigationService.navigateToMyRequests(context);
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
            TransportNavigationService.navigateToCreateRequest(context);
          },
        ),
      ],
    );
  }
}
