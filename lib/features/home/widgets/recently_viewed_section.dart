import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Recently Viewed Ads section widget
/// Displays horizontally scrollable list of recently viewed listings
class RecentlyViewedSection extends StatelessWidget {
  final String title;
  final List<ListingModel> listings;
  final bool isLoading;
  final Function(ListingModel)? onListingTap;
  final VoidCallback? onViewAll;
  final bool Function(int)? isFavorite; // Callback to check if listing is favorited

  const RecentlyViewedSection({
    super.key,
    this.title = 'Recently Viewed Ads',
    required this.listings,
    this.isLoading = false,
    this.onListingTap,
    this.onViewAll,
    this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // Always show section for debugging - will hide when working
    // if (!isLoading && listings.isEmpty) {
    //   return const SizedBox.shrink();
    // }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with View All button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                if (onViewAll != null && listings.isNotEmpty)
                  TextButton.icon(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.authPrimaryColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    label: const Icon(Icons.chevron_right, size: 20),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Horizontal scrollable list
          SizedBox(
            height: 170, // Reduced from 200 to 170
            child: isLoading
                ? _buildLoadingList()
                : listings.isEmpty
                    ? _buildEmptyState()
                    : _buildListingsList(),
          ),
        ],
      ),
    );
  }

  /// Build loading shimmer list
  Widget _buildLoadingList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? 12 : 0),
          child: _buildLoadingCard(),
        );
      },
    );
  }

  /// Build actual listings list
  Widget _buildListingsList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        final isListingFavorited = isFavorite?.call(listing.id) ?? false;
        return Padding(
          padding: EdgeInsets.only(right: index < listings.length - 1 ? 12 : 0),
          child: _RecentlyViewedCard(
            listing: listing,
            onTap: () => onListingTap?.call(listing),
            isFavorite: isListingFavorited,
          ),
        );
      },
    );
  }

  /// Build loading shimmer card
  Widget _buildLoadingCard() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Build empty state message
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No recently viewed ads yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Browse listings to see them here',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single recently viewed listing card
class _RecentlyViewedCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;
  final bool isFavorite;

  const _RecentlyViewedCard({
    required this.listing,
    this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            _buildImage(),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(6), // Reduced from 8 to 6
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    listing.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13, // Reduced from 14 to 13
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 3 to 2
                  
                  // Breed & Age
                  if (listing.breed != null)
                    Text(
                      '${listing.breed} • ${listing.age}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10, // Reduced from 11 to 10
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 3), // Reduced from 4 to 3
                  
                  // Price
                  Text(
                    listing.price,
                    style: const TextStyle(
                      fontSize: 13, // Reduced from 14 to 13
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          // Image
          listing.imageUrl != null
              ? Image.network(
                  listing.imageUrl!,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
          
          // Favorite icon overlay (top-right)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isFavorite ? Colors.red : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 80, // Reduced from 100 to 80
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_outlined,
        size: 32, // Reduced from 40 to 32
        color: Colors.grey[400],
      ),
    );
  }
}
