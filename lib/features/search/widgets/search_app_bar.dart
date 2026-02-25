import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Search App Bar
///
/// Custom app bar with:
/// - Back arrow button on left
/// - Search input field in center
/// - Filter and Search icon buttons on right
class SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onBack;
  final ValueChanged<String> onSearch;
  final VoidCallback? onFilterTap;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onBack,
    required this.onSearch,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.authPrimaryColor, // Primary green color for status bar area
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white, // White icon on green background
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),

          const SizedBox(width: 4), // Reduced margin

          // Search Input Field
          Expanded(
            child: Container(
              height: 48,
              clipBehavior: Clip.antiAlias, // Important for border radius
              decoration: BoxDecoration(
                color: Colors.white, // White background for search input
                borderRadius: BorderRadius.circular(23), // Match home page (pill shape)
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: onSearch,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search livestocks, products...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Filter Button (optional)
          if (onFilterTap != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onFilterTap,
                icon: const Icon(Icons.tune),
                color: AppTheme.authPrimaryColor,
                padding: EdgeInsets.zero,
              ),
            ),

          if (onFilterTap != null) const SizedBox(width: 8),

          // Search Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: () => onSearch(controller.text),
              icon: const Icon(Icons.search),
              color: AppTheme.authPrimaryColor,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
