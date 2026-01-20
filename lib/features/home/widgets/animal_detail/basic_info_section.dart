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
          // First Row: Name + Verified Badge on left, Price on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Name and Verified Badge
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
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
              ),

              // Right side: Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                  if (originalPrice != null)
                    Text(
                      originalPrice!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Second Row: Breed and Gender
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
        ],
      ),
    );
  }

  /// Build the verified badge
  Widget _buildVerifiedBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.authPrimaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'Verified',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.authPrimaryColor,
          ),
        ),
      ],
    );
  }
}
