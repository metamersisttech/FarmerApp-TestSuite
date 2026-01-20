import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Seller Info Card for Animal Detail Page
///
/// Displays seller profile, name, location, rating, and reviews.
class SellerInfoCard extends StatelessWidget {
  final SellerInfo seller;
  final VoidCallback? onContactTap;

  const SellerInfoCard({
    super.key,
    required this.seller,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Seller',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Seller Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Profile Image
                _buildProfileImage(),
                const SizedBox(width: 12),

                // Name, Location, Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        seller.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      // Location
                      if (seller.location != null) ...[
                        const SizedBox(height: 4),
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
                                seller.location!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Rating
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            seller.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${seller.reviewCount} reviews)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Verified Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.authPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.authPrimaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build profile image with placeholder
  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: seller.profileImage != null && seller.profileImage!.isNotEmpty
          ? NetworkImage(seller.profileImage!)
          : null,
      child: seller.profileImage == null || seller.profileImage!.isEmpty
          ? Icon(
              Icons.person,
              size: 28,
              color: Colors.grey.shade400,
            )
          : null,
    );
  }
}
