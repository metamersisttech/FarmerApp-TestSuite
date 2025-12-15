import 'package:flutter/material.dart';

/// Circular header icon used on auth screens (matches screenshot style).
class AuthHeaderIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  const AuthHeaderIcon({
    super.key,
    required this.icon,
    this.size = 84,
    this.iconSize = 40,
    this.backgroundColor = const Color(0x1A93BF8F),
    this.iconColor = const Color(0xFF2E7D32),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}


