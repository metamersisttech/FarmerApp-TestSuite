import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Theme constants for selection cards
abstract class SelectionCardTheme {
  static const Color hoverBorderColor = AppTheme.authPrimaryColor;
  static const double cardBorderRadius = 16.0;
  static const double selectedBorderWidth = 2.5;
  static const double defaultBorderWidth = 1.5;
  static const Duration animationDuration = Duration(milliseconds: 200);
}

/// A reusable selection card with hover and selection states
class SelectionCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback? onTap;
  final VoidCallback? onHoverEnter;
  final VoidCallback? onHoverExit;
  final Color? selectedColor;
  final Color? selectedBorderColor;
  final Color? hoverBorderColor;
  final Color? defaultBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const SelectionCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.isHovered = false,
    this.onTap,
    this.onHoverEnter,
    this.onHoverExit,
    this.selectedColor,
    this.selectedBorderColor,
    this.hoverBorderColor,
    this.defaultBorderColor,
    this.borderRadius = SelectionCardTheme.cardBorderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: onHoverEnter != null ? (_) => onHoverEnter!() : null,
      onExit: onHoverExit != null ? (_) => onHoverExit!() : null,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SelectionCardTheme.animationDuration,
          padding: padding,
          decoration: _buildDecoration(),
          child: child,
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final effectiveSelectedBorderColor =
        selectedBorderColor ?? AppTheme.authPrimaryColor;
    final effectiveHoverBorderColor =
        hoverBorderColor ?? SelectionCardTheme.hoverBorderColor;
    final effectiveDefaultBorderColor =
        defaultBorderColor ?? Colors.grey.shade300;
    final effectiveSelectedColor =
        selectedColor ?? AppTheme.primaryColor.withOpacity(0.1);

    final borderColor = isSelected
        ? effectiveSelectedBorderColor
        : isHovered
        ? effectiveHoverBorderColor
        : effectiveDefaultBorderColor;

    final borderWidth = (isSelected || isHovered)
        ? SelectionCardTheme.selectedBorderWidth
        : SelectionCardTheme.defaultBorderWidth;

    return BoxDecoration(
      color: isSelected ? effectiveSelectedColor : Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: (isHovered || isSelected)
          ? [
              BoxShadow(
                color:
                    (isSelected
                            ? effectiveSelectedBorderColor
                            : effectiveHoverBorderColor)
                        .withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
