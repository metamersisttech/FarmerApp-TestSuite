import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/cache/media_cache_config.dart';
/// Listing card widget for marketplace
class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Flexible(
                flex: 0,
                child: _buildImageSection(),
              ),
              
              // Content section - wrapped in Expanded to prevent overflow
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            listing.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          
                          // Animal type and age
                          Row(
                            children: [
                              const Icon(Icons.cake_outlined, size: 11, color: Colors.grey),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  listing.age,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          
                          // Price
                          Text(
                            listing.price,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.authPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      
                      // Location and rating at bottom
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 10, color: Colors.grey),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    listing.location,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 10, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            listing.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
  return Stack(
    children: [
      // Image with progressive loading
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: AspectRatio(
          aspectRatio: 1.2,
          child: listing.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: listing.imageUrl!,
                  cacheManager: MediaCacheConfig.imageCache, // Use custom cache
                  fit: BoxFit.cover,
                  
                  // Placeholder: Shows while loading
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.grey[300]),
                  ),
                  
                  // Error: Shows if image fails to load
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                  
                  // Fade-in animation when image loads
                  fadeInDuration: const Duration(milliseconds: 300),
                )
              : _buildPlaceholder(),
        ),
      ),
      
      // Favorite button (existing code)
      Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: onFavoriteTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isFavorite ? Colors.red : Colors.grey[700],
            ),
          ),
        ),
      ),
      
      // Verified badge (existing code)
      if (listing.isVerified)
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.authPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

 Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}
