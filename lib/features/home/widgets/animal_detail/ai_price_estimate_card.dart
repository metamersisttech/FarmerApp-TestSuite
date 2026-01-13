import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// AI Price Estimate Card for Animal Detail Page
///
/// Displays AI-generated price estimate with price range and assessment.
class AiPriceEstimateCard extends StatelessWidget {
  final String priceRange;
  final String? assessment;

  const AiPriceEstimateCard({
    super.key,
    required this.priceRange,
    this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.authPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.authPrimaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // AI Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.authPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppTheme.authPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Price Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Price Estimate',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.authPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  priceRange,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Assessment Badge
          if (assessment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.authPrimaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                assessment!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.authPrimaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
