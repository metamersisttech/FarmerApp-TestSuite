/// Star Rating Widget
///
/// Interactive 5-star rating picker for delivery confirmation.
library;

import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool readOnly;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 40,
    this.activeColor,
    this.inactiveColor,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? Colors.amber.shade600;
    final inactive = inactiveColor ?? theme.colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isActive = starValue <= rating;

        return GestureDetector(
          onTap: readOnly ? null : () => onRatingChanged?.call(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              size: size,
              color: isActive ? active : inactive,
            ),
          ),
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showValue;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starColor = color ?? Colors.amber.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size,
          color: starColor,
        ),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
