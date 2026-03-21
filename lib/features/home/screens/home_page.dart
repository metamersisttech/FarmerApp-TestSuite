import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/mixins/location_mixin.dart';
import 'package:flutter_app/features/home/widgets/home_header.dart';
import 'package:flutter_app/features/home/widgets/home_content.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
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
              child: HomeContent(
                templates: homeController.getTemplateCards(),
                onMarketplaceTap: () => homeController.navigateToMarketplace(context),
                onVetServicesTap: () => homeController.navigateToVetServices(context),
                recentlyViewedListings: recentlyViewedListings,
                isLoadingRecentlyViewed: isLoadingRecentlyViewed,
                onListingTap: (listing) {
                  if (listing is ListingModel) {
                    homeController.navigateToListingDetail(context, listing);
                    syncRecentlyViewedListings();
                  }
                },
                onViewAllRecentlyViewed: () => homeController.navigateToRecentlyViewed(context),
                isFavorite: (listingId) => homeController.isListingFavorited(listingId),
                freshListings: homeController.listings,
                isLoadingFreshListings: homeController.isLoading,
                onViewAllFreshListings: () => homeController.navigateToFreshListings(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
