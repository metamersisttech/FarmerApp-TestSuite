import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/cards/listing_card.dart';

/// My Listings section widget for profile page
/// Shows a preview of user's listings with option to view all
class MyListingsSection extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final List<ListingModel> listings;
  final bool isLoading;
  final Function(ListingModel)? onListingTap;
  final int maxListingsToShow;

  const MyListingsSection({
    super.key,
    this.title = 'My Listings',
    this.actionText = 'View All',
    this.onActionPressed,
    this.listings = const [],
    this.isLoading = false,
    this.onListingTap,
    this.maxListingsToShow = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Content Area
          isLoading
              ? _buildLoadingState()
              : listings.isEmpty
                  ? _buildEmptyState()
                  : _buildListings(),
        ],
      ),
    );
  }

  /// Build the header with title and action button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.authTextPrimary,
            ),
          ),
          if (actionText != null && onActionPressed != null)
            TextButton.icon(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.authPrimaryColor,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Text(
                actionText!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              label: const Icon(Icons.chevron_right, size: 20),
            ),
        ],
      ),
    );
  }

  /// Build the listings list (limited to maxListingsToShow)
  Widget _buildListings() {
    final displayListings = listings.take(maxListingsToShow).toList();
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: displayListings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final listing = displayListings[index];
        return ListingCard(
          imageUrl: listing.imageUrl,
          name: listing.name,
          age: listing.age,
          price: listing.price,
          location: listing.location,
          rating: listing.rating,
          isVerified: listing.isVerified,
          onTap: () => onListingTap?.call(listing),
        );
      },
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  /// Build shimmer loading card
  Widget _buildShimmerCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 18,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No listings yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start posting your animals for sale',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
