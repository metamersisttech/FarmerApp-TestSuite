import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/auth/auth_header_icon.dart';

/// Reusable page header with optional icon, title and subtitle
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? titleColor;
  final Color? subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final CrossAxisAlignment alignment;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.titleColor,
    this.subtitleColor,
    this.titleFontSize = 28,
    this.subtitleFontSize = 14,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (icon != null) ...[
          AuthHeaderIcon(icon: icon!),
          const SizedBox(height: 20),
        ],
        Text(
          title,
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
            color: titleColor ?? AppTheme.authPrimaryColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: subtitleColor ?? AppTheme.authTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
