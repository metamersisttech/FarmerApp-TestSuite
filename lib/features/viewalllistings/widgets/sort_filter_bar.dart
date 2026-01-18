import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Sort and filter bar widget
class SortFilterBar extends StatelessWidget {
  final String sortBy;
  final int itemCount;
  final VoidCallback onSortTap;
  final VoidCallback onFilterTap;

  const SortFilterBar({
    super.key,
    required this.sortBy,
    required this.itemCount,
    required this.onSortTap,
    required this.onFilterTap,
  });

  String _getSortLabel() {
    switch (sortBy) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'newest':
        return 'Newest First';
      case 'relevance':
      default:
        return 'Relevance';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item count
          Text(
            '$itemCount animals found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          
          const Spacer(),
          
          // Sort button
          _buildButton(
            icon: Icons.sort,
            label: _getSortLabel(),
            onTap: onSortTap,
          ),
          
          const SizedBox(width: 12),
          
          // Filter button
          _buildButton(
            icon: Icons.filter_list,
            label: 'Filter',
            onTap: onFilterTap,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.authPrimaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
