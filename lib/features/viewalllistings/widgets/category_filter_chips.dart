import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Horizontal scrollable category filter chips widget for livestock listings
class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String>? onSelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == selectedCategory;

            return Padding(
              padding: EdgeInsets.only(
                right: index < categories.length - 1 ? 8 : 0,
                bottom: 10,
              ),
              child: _CategoryChip(
                label: category,
                isSelected: isSelected,
                onTap: () => onSelected?.call(category),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Single category chip widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
