import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Horizontal filter chip row for bid status filtering
class BidStatusFilter extends StatelessWidget {
  final String? selectedFilter;
  final ValueChanged<String?> onFilterChanged;

  const BidStatusFilter({
    super.key,
    this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<(String label, String? value)> _filters = [
    ('All', null),
    ('Pending', 'PENDING'),
    ('Approved', 'APPROVED'),
    ('Rejected', 'REJECTED'),
    ('Cancelled', 'CANCELLED'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, value) = _filters[index];
          final isSelected = selectedFilter == value;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(value),
            selectedColor: AppTheme.authPrimaryColor,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppTheme.authPrimaryColor : Colors.grey[300]!,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}
