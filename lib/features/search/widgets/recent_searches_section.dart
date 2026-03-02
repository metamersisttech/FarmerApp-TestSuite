import 'package:flutter/material.dart';

/// Recent Searches Section
///
/// Displays list of recent searches with clear all button
class RecentSearchesSection extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSearchTap;
  final VoidCallback onClearAll;

  const RecentSearchesSection({
    super.key,
    required this.searches,
    required this.onSearchTap,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Recent Searches List
          ...searches.map((search) => _buildSearchItem(search)),
        ],
      ),
    );
  }

  Widget _buildSearchItem(String search) {
    return GestureDetector(
      onTap: () => onSearchTap(search),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // History Icon
            Icon(
              Icons.history,
              size: 20,
              color: Colors.grey[400],
            ),

            const SizedBox(width: 16),

            // Search Text
            Expanded(
              child: Text(
                search,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.north_west,
              size: 18,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
