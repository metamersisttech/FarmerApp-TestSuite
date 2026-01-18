import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Search bar with filter and sort buttons widget
class SearchWithFiltersBar extends StatelessWidget {
  final String searchQuery;
  final String sortBy;
  final int listingsCount;
  final Function(String) onSearchChanged;
  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;

  const SearchWithFiltersBar({
    super.key,
    required this.searchQuery,
    required this.sortBy,
    required this.listingsCount,
    required this.onSearchChanged,
    required this.onSortTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Search bar - takes most space
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search animals...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[500],
                      size: 22,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: () {
                              onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Sort button
            _buildIconButton(
              icon: Icons.sort,
              label: _getSortLabel(),
              onTap: onSortTap,
            ),
            
            const SizedBox(width: 8),
            
            // Filter button
            _buildIconButton(
              icon: Icons.filter_list,
              label: 'Filter',
              onTap: onFilterTap,
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Listing count
        Row(
          children: [
            Text(
              '$listingsCount animals found',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build icon button for filter/sort
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppTheme.authPrimaryColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get sort label text
  String _getSortLabel() {
    switch (sortBy) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'newest':
        return 'Newest';
      case 'relevance':
      default:
        return 'Sort';
    }
  }
}
