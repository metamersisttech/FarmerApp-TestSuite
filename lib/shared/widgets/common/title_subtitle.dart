import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Displays a title and subtitle text pair
class TitleSubtitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final Color? selectedTitleColor;
  final Color? defaultTitleColor;
  final Color? subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final FontWeight titleFontWeight;
  final CrossAxisAlignment alignment;

  const TitleSubtitle({
    super.key,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    this.selectedTitleColor,
    this.defaultTitleColor,
    this.subtitleColor,
    this.titleFontSize = 18,
    this.subtitleFontSize = 14,
    this.titleFontWeight = FontWeight.w600,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedTitleColor ?? AppTheme.primaryColor;
    final effectiveDefaultColor = defaultTitleColor ?? Colors.black87;
    final effectiveSubtitleColor = subtitleColor ?? Colors.grey[600];

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: titleFontWeight,
            color: isSelected ? effectiveSelectedColor : effectiveDefaultColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: effectiveSubtitleColor,
            ),
          ),
        ],
      ],
    );
  }
}

