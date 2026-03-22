import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reusable Listing Card Widget
///
/// Displays a listing item with image, name, age, price, location, and rating.
/// Used in home page recent listings and marketplace.
class ListingCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String age;
  final String price;
  final String location;
  final double rating;
  final bool isVerified;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    this.imageUrl,
    required this.name,
    required this.age,
    required this.price,
    required this.location,
    this.rating = 0.0,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('listing_card'),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            _buildImage(),
            const SizedBox(width: 16),
            // Details
            Expanded(child: _buildDetails()),
          ],
        ),
      ),
    );
  }

  /// Build the listing image
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        height: 96,
        color: Colors.grey.shade200,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('[ListingCard] Image error: $error for $imageUrl');
                  return _buildPlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Build placeholder for missing image
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.pets,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  /// Build the details section
  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name + Verified Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    age,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isVerified) _buildVerifiedBadge(),
          ],
        ),
        const SizedBox(height: 8),
        // Price
        Text(
          price,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.authPrimaryColor,
          ),
        ),
        const SizedBox(height: 6),
        // Location + Rating
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 14,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (rating > 0) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.star,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Build the verified badge
  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.authPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Verified',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.authPrimaryColor,
        ),
      ),
    );
  }
}
