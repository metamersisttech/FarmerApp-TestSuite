import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// A single stat item showing value and label
class ProfileStatItem extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.authPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
