import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// A customizable icon badge container
class IconBadge extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Widget? child;
  final bool isSelected;
  final bool isHovered;
  final Color? selectedColor;
  final Color? hoverColor;
  final Color? defaultColor;
  final double size;
  final double borderRadius;

  const IconBadge({
    super.key,
    this.text,
    this.icon,
    this.child,
    this.isSelected = false,
    this.isHovered = false,
    this.selectedColor,
    this.hoverColor,
    this.defaultColor,
    this.size = 50,
    this.borderRadius = 12,
  }) : assert(
         text != null || icon != null || child != null,
         'Provide text, icon, or child',
       );

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppTheme.primaryColor;
    final effectiveHoverColor = hoverColor ?? AppTheme.authPrimaryColor;
    final effectiveDefaultColor = defaultColor ?? Colors.grey.shade100;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? effectiveSelectedColor
            : isHovered
            ? effectiveHoverColor.withOpacity(0.2)
            : effectiveDefaultColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (child != null) return child!;

    if (icon != null) {
      return Icon(
        icon,
        size: size * 0.5,
        color: isSelected ? Colors.white : Colors.grey[700],
      );
    }

    return Text(
      text!.toUpperCase(),
      style: TextStyle(
        fontSize: size * 0.32,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
    );
  }
}
