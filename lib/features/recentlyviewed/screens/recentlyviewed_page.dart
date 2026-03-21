import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/recentlyviewed/mixins/recentlyviewed_state_mixin.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_card.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_search_bar.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/main.dart' show routeObserver;

/// Recently Viewed Listings Page
///
/// Displays all recently viewed listings in a grid view.
/// Accessed when user taps on "View All" in Recently Viewed Ads section.
/// 
/// Architecture:
/// - UI only in this file (build methods)
/// - Business logic in RecentlyViewedStateMixin
/// - Data management in RecentlyViewedController
/// - Data fetching in RecentlyViewedService
/// - Uses local cache for tracking viewed listings
class RecentlyViewedPage extends StatefulWidget {
  const RecentlyViewedPage({super.key});

  @override
  State<RecentlyViewedPage> createState() => _RecentlyViewedPageState();
}

class _RecentlyViewedPageState extends State<RecentlyViewedPage>
    with RecentlyViewedStateMixin, HomeStateMixin, RouteAware {
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    initializeController();
    initializeHomeController();
    
    // Fetch recently viewed listings and favorites after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchRecentlyViewedListings();
      // Load favorites after listings are fetched
      controller.loadFavorites().then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up
    // This fires when user returns from animal detail page
    print('[RecentlyViewed] 🔄 didPopNext - User returned from detail page, reloading favorites...');
    controller.loadFavorites().then((_) {
      if (mounted) {
        setState(() {});
        print('[RecentlyViewed] ✅ UI refreshed after loading favorites');
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    disposeController();
    disposeHomeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: ListingSearchBar(
              controller: searchController,
              onChanged: handleListingsSearch,
              showFilterButton: false, // No filters for recently viewed
            ),
          ),

          const SizedBox(height: 16),

          // Listings grid
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentBottomNavIndex,
        onTap: (index) => handleRecentlyViewedBottomNavigation(
          index,
          homeController.onNavigateToTab ?? (_) {},
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Recently Viewed',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build main content (grid or loading/error state)
  Widget _buildContent() {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.authPrimaryColor,
        ),
      );
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.authPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Get filtered listings based on search query
    final filteredListings = controller.getFilteredListings();

    if (!controller.hasListings) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recently viewed listings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse the marketplace to see listings here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (filteredListings.isEmpty && controller.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No listings found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: handleRefresh,
      color: AppTheme.authPrimaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredListings.length,
        itemBuilder: (context, index) {
          final listing = filteredListings[index];
          final isFavorited = controller.isListingFavorited(listing.id);
          
          return ListingCard(
            listing: listing,
            onTap: () => handleListingTap(listing),
            onFavoriteTap: null, // Disable toggle on listing cards
            isFavorite: isFavorited,
          );
        },
      ),
    );
  }
}
