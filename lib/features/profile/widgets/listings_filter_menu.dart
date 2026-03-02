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
          value: null,
          child: Text('All Listings'),
        ),
        const PopupMenuItem(
          value: 'active',
          child: Text('Active'),
        ),
        const PopupMenuItem(
          value: 'sold',
          child: Text('Sold'),
        ),
        const PopupMenuItem(
          value: 'expired',
          child: Text('Expired'),
        ),
      ],
    );
  }
}
