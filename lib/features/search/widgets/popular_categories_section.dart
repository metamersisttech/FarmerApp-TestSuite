import 'package:flutter/material.dart';

/// Popular Categories Section
///
/// Displays grid of popular livestock categories with icons
class PopularCategoriesSection extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;

  const PopularCategoriesSection({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Text(
            'Popular Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Categories Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildCategoryItem(
                icon: '🐄',
                label: 'Cow',
                onTap: () => onCategoryTap('Cow'),
              ),
              _buildCategoryItem(
                icon: '🐑',
                label: 'Sheep',
                onTap: () => onCategoryTap('Sheep'),
              ),
              _buildCategoryItem(
                icon: '🐃',
                label: 'Buffalo',
                onTap: () => onCategoryTap('Buffalo'),
              ),
              _buildCategoryItem(
                icon: '🐐',
                label: 'Goat',
                onTap: () => onCategoryTap('Goat'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Emoji
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),

            const SizedBox(height: 8),

            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
