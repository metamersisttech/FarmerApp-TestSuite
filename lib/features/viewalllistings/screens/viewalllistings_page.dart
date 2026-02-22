import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/postlistings/screens/post_animal_page.dart';
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
/// - Data management in ViewAllListingsController (with Firebase sync)
/// - Data fetching in ViewAllListingsService
/// - Cache-first strategy with automatic invalidation via Firebase
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
    
    // Initialize controller with Firebase sync (see mixin for implementation)
    // This will:
    // 1. Create controller with firebaseSync instance
    // 2. Register Firebase listener for automatic cache invalidation
    // 3. Fetch initial listings (cache-first strategy)
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
      resizeToAvoidBottomInset: false, // Keep bottom nav static when keyboard appears
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
      // Floating Add Button (Sell)
      floatingActionButton: _buildSellButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentBottomNavIndex,
        onTap: (index) => handleMarketplaceBottomNavigation(index, handleBottomNavTap),
      ),
    );
  }

  /// Build Sell button (Floating Action Button)
  Widget _buildSellButton(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _TriColorBorderPainter(),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: _handleSellTap,
            icon: const Icon(
              Icons.add,
              color: AppTheme.authPrimaryColor,
              size: 28,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  /// Handle Sell button tap
  void _handleSellTap() {
    // Navigate to post animal page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostAnimalPage()),
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

/// Custom painter for three-color segmented circular border
class _TriColorBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 5.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw three arcs (120 degrees each = 2.094 radians)
    const sweepAngle = 2.094; // 120 degrees in radians
    
    // Segment 1: Green/Teal (AppTheme.authPrimaryColor) - top
    paint.color = AppTheme.authPrimaryColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.571, // Start at top (-90 degrees)
      sweepAngle,
      false,
      paint,
    );

    // Segment 2: Orange - bottom right
    paint.color = Colors.orange;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0.523, // Start after first segment
      sweepAngle,
      false,
      paint,
    );

    // Segment 3: Deep Purple - bottom left
    paint.color = Colors.deepPurple;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      2.618, // Start after second segment
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
