import 'package:flutter/material.dart';

/// Mixin for My Listings page state management
mixin MyListingsStateMixin<T extends StatefulWidget> on State<T> {
  // Filter state
  String? selectedFilter;

  /// Set filter
  void setFilter(String? filter) {
    if (mounted) {
      setState(() => selectedFilter = filter);
    }
  }

  /// Clear filter
  void clearFilter() {
    setFilter(null);
  }

  /// Get filter display text
  String getFilterText() {
    return selectedFilter != null
        ? '${selectedFilter![0].toUpperCase()}${selectedFilter!.substring(1)}'
        : 'All';
  }

  /// Check if filter is active
  bool get hasFilter => selectedFilter != null;
}
