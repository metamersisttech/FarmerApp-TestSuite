import 'package:flutter/material.dart';

/// Section title widget for health form
class HealthSectionTitle extends StatelessWidget {
  final String title;

  const HealthSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
