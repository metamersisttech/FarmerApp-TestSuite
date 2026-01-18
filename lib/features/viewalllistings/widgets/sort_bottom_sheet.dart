import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Sort bottom sheet widget
class SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortSelected;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Sort options
          _buildSortOption(
            context,
            'Relevance',
            'relevance',
            Icons.thumb_up_outlined,
          ),
          _buildSortOption(
            context,
            'Price: Low to High',
            'price_low',
            Icons.arrow_upward,
          ),
          _buildSortOption(
            context,
            'Price: High to Low',
            'price_high',
            Icons.arrow_downward,
          ),
          _buildSortOption(
            context,
            'Newest First',
            'newest',
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isSelected = currentSort == value;
    
    return InkWell(
      onTap: () {
        onSortSelected(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected ? AppTheme.authPrimaryColor.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.authPrimaryColor : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppTheme.authPrimaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
