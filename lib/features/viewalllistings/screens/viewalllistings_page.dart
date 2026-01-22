import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/viewalllistings/mixins/viewalllistings_state_mixin.dart';
import 'package:flutter_app/features/viewalllistings/widgets/category_filter_chips.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_card.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_search_bar.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_sort_bottom_sheet.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// View All Listings Page
///
/// Displays all marketplace listings in a grid view.
/// Accessed when user taps on "Marketplace" quick action.
/// 
/// Architecture:
/// - UI only in this file (build methods)
/// - Business logic in ViewAllListingsStateMixin
/// - Data management in ViewAllListingsController
/// - Data fetching in ViewAllListingsService
class ViewAllListingsPage extends StatefulWidget {
  const ViewAllListingsPage({super.key});

  @override
  State<ViewAllListingsPage> createState() => _ViewAllListingsPageState();
}

class _ViewAllListingsPageState extends State<ViewAllListingsPage>
    with ViewAllListingsStateMixin, HomeStateMixin {
  
  @override
  void initState() {
    super.initState();
    initializeController();
    initializeHomeController();
    
    // Fetch marketplace listings after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMarketplaceListings();
    });
  }

  @override
  void dispose() {
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
          // Search bar with filter button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: ListingSearchBar(
              controller: searchController,
              onChanged: handleListingsSearch,
              onFilterTap: _showSortFilterSheet,
            ),
          ),

          // Category filter chips
          CategoryFilterChips(
            categories: controller.categories,
            selectedCategory: controller.selectedCategory,
            onSelected: handleCategorySelected,
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
        onTap: (index) => handleMarketplaceBottomNavigation(index, handleBottomNavTap),
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
        'Browse Livestock',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Show sort and filter bottom sheet
  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ListingSortBottomSheet(
          currentSortBy: controller.apiSortBy,
          currentOrder: controller.apiOrder,
          onApply: handleSortFilterApply,
        );
      },
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

    if (!controller.hasListings) {
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
              'Try adjusting your filters',
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
        itemCount: controller.listingsCount,
        itemBuilder: (context, index) {
          final listing = controller.listings[index];
          return ListingCard(
            listing: listing,
            onTap: () => handleListingTap(listing),
            onFavoriteTap: () {
              // TODO: Implement favorite functionality
              showSuccessMessage('Favorite feature coming soon!');
            },
          );
        },
      ),
    );
  }
}
