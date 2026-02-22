import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Price Section Widget
class PriceSection extends StatelessWidget {
  final Map<String, dynamic> listingData;
  final String Function(dynamic) formatPrice;

  const PriceSection({
    super.key,
    required this.listingData,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final price = listingData['price'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '₹${formatPrice(price)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.authPrimaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Fixed Price',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
