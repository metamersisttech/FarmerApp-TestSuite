import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Circular selection indicator (checkbox/radio style)
class SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  final bool isHovered;
  final Color? selectedColor;
  final Color? hoverColor;
  final Color? defaultColor;
  final double size;
  final Duration animationDuration;

  const SelectionIndicator({
    super.key,
    required this.isSelected,
    this.isHovered = false,
    this.selectedColor,
    this.hoverColor,
    this.defaultColor,
    this.size = 28,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppTheme.primaryColor;
    final effectiveHoverColor = hoverColor ?? AppTheme.authPrimaryColor;
    final effectiveDefaultColor = defaultColor ?? Colors.grey.shade400;

    final borderColor = isSelected
        ? effectiveSelectedColor
        : isHovered
        ? effectiveHoverColor
        : effectiveDefaultColor;

    return AnimatedContainer(
      duration: animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? effectiveSelectedColor : Colors.transparent,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: isSelected
          ? Icon(Icons.check, color: Colors.white, size: size * 0.65)
          : null,
    );
  }
}
