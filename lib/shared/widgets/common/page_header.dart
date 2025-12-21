import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reusable page header with title and subtitle
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final CrossAxisAlignment alignment;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.titleFontSize = 32,
    this.subtitleFontSize = 16,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: titleColor ?? AppTheme.authPrimaryColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: subtitleColor ?? Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

