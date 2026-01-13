import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Basic Info Section for Animal Detail Page
///
/// Displays animal name, verified badge, breed, gender, and price.
class BasicInfoSection extends StatelessWidget {
  final String name;
  final String? breedGender;
  final String price;
  final String? originalPrice;
  final bool isVerified;

  const BasicInfoSection({
    super.key,
    required this.name,
    this.breedGender,
    required this.price,
    this.originalPrice,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Verified Badge Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 8),
                _buildVerifiedBadge(),
              ],
            ],
          ),

          // Breed and Gender
          if (breedGender != null && breedGender!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              breedGender!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (originalPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  originalPrice!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: AppTheme.authPrimaryColor,
          ),
          const SizedBox(width: 4),
          const Text(
            'Verified',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.authPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
