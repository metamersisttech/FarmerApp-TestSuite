import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Horizontal scrollable breed filter chips widget
class BreedFilterChips extends StatelessWidget {
  final List<String> breeds;
  final String selectedBreed;
  final ValueChanged<String>? onSelected;

  const BreedFilterChips({
    super.key,
    required this.breeds,
    required this.selectedBreed,
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
        itemCount: breeds.length,
        itemBuilder: (context, index) {
            final breed = breeds[index];
            final isSelected = breed == selectedBreed;

            return Padding(
              padding: EdgeInsets.only(
                right: index < breeds.length - 1 ? 8 : 0,
                bottom: 10,
              ),
              child: _BreedChip(
                label: breed,
                isSelected: isSelected,
                onTap: () => onSelected?.call(breed),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Single breed chip widget
class _BreedChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _BreedChip({
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
