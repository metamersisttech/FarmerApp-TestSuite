import 'package:flutter/material.dart';

/// Filter menu widget for My Listings page
class ListingsFilterMenu extends StatelessWidget {
  final String? currentFilter;
  final Function(String?) onFilterChanged;

  const ListingsFilterMenu({
    super.key,
    this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      onSelected: onFilterChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Text('All Listings'),
        ),
        const PopupMenuItem(
          value: 'draft',
          child: Text('Draft'),
        ),
        const PopupMenuItem(
          value: 'sold',
          child: Text('Sold'),
        ),
        const PopupMenuItem(
          value: 'published',
          child: Text('Published'),
        ),
      ],
    );
  }
}
