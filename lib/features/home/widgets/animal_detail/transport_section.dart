import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Transport Section for Animal Detail Page
///
/// Displays transport availability and estimated cost.
class TransportSection extends StatelessWidget {
  final bool isAvailable;
  final double? estimatedCost;
  final VoidCallback? onBookTap;

  const TransportSection({
    super.key,
    required this.isAvailable,
    this.estimatedCost,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7), // Light cream/peach background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Truck Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4B5), // Light orange
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFFD4860B), // Orange/amber
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transport Available',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (estimatedCost != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Estimated: \u20B9${estimatedCost!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} to your location',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B8E7B), // Teal/grey-green
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Book Button
            GestureDetector(
              onTap: onBookTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0D4), // Light orange background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE8B44A), // Orange border
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD4860B), // Orange text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
