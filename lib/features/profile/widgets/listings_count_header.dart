import 'package:flutter/material.dart';

/// Listings count header widget
class ListingsCountHeader extends StatelessWidget {
  final int count;

  const ListingsCountHeader({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Text(
        '$count ${count == 1 ? 'Listing' : 'Listings'}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
