import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Bottom sheet for sorting listings
class ListingSortBottomSheet extends StatefulWidget {
  final String currentSortBy;
  final String currentOrder;
  final Function(String sortBy, String order) onApply;

  const ListingSortBottomSheet({
    super.key,
    required this.currentSortBy,
    required this.currentOrder,
    required this.onApply,
  });

  @override
  State<ListingSortBottomSheet> createState() => _ListingSortBottomSheetState();
}

class _ListingSortBottomSheetState extends State<ListingSortBottomSheet> {
  late String _selectedSortBy;
  late String _selectedOrder;

  // Combined sort options for better UX
  final List<Map<String, dynamic>> _sortOptions = [
    {
      'label': 'Price: Low to High',
      'icon': Icons.arrow_upward,
      'sortBy': 'price',
      'order': 'asc',
    },
    {
      'label': 'Price: High to Low',
      'icon': Icons.arrow_downward,
      'sortBy': 'price',
      'order': 'desc',
    },
    {
      'label': 'Date Posted: Newest First',
      'icon': Icons.new_releases,
      'sortBy': 'posted_at',
      'order': 'desc',
    },
    {
      'label': 'Date Posted: Oldest First',
      'icon': Icons.history,
      'sortBy': 'posted_at',
      'order': 'asc',
    },
    {
      'label': 'Views: Most Viewed',
      'icon': Icons.visibility,
      'sortBy': 'views',
      'order': 'desc',
    },
    {
      'label': 'Views: Least Viewed',
      'icon': Icons.visibility_off,
      'sortBy': 'views',
      'order': 'asc',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _selectedOrder = widget.currentOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort Listings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sort Options Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._sortOptions.map((option) => _buildSortOption(
                    option['label'] as String,
                    option['icon'] as IconData,
                    option['sortBy'] as String,
                    option['order'] as String,
                  )).toList(),
                ],
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedSortBy, _selectedOrder);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, IconData icon, String sortBy, String order) {
    final isSelected = _selectedSortBy == sortBy && _selectedOrder == order;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortBy = sortBy;
          _selectedOrder = order;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
