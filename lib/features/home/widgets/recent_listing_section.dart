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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Header (Title row with "View All" button)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.authTextPrimary,
                  ),
                ),
                if (actionText != null && onActionPressed != null)
                  TextButton(
                    onPressed: onActionPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.authPrimaryColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionText!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Scrollable Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Content or placeholder
                  content ?? _buildPlaceholder(),
                  
                  // Add multiple placeholders to demonstrate scrolling
                  if (content == null) ...[
                    const SizedBox(height: 12),
                    _buildPlaceholder(),
                    const SizedBox(height: 12),
                    _buildPlaceholder(),
                    const SizedBox(height: 12),
                    _buildPlaceholder(),
                    const SizedBox(height: 12),
                    _buildPlaceholder(),
                  ],
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
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
          'Listing item placeholder',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }
}

