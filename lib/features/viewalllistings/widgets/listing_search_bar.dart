import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Search bar widget with filter button for View All Listings page
class ListingSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final bool enabled;

  const ListingSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search livestock, breeds...',
    this.onChanged,
    this.onTap,
    this.onFilterTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              enabled: enabled,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Filter button
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
