import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Quick Actions section widget
class QuickActionsSection extends StatelessWidget {
  final String title;
  final Widget? content;

  const QuickActionsSection({
    super.key,
    this.title = 'Quick Actions',
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.authTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Content or placeholder
          content ?? _buildPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          'Components will be added here',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }
}

