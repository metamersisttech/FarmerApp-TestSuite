import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Recent Listing section widget
class RecentListingSection extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? content;

  const RecentListingSection({
    super.key,
    this.title = 'Recent Listing',
    this.actionText = 'View All',
    this.onActionPressed,
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
          // Title row with "View All" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.authTextPrimary,
                ),
              ),
              if (actionText != null && onActionPressed != null)
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.authPrimaryColor,
                  ),
                  child: Text(
                    actionText!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Content or placeholder
          content ?? _buildPlaceholder(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
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

