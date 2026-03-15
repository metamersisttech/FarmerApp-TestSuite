import 'package:flutter/material.dart';

/// Mixin for My Listings page state management
mixin MyListingsStateMixin<T extends StatefulWidget> on State<T> {
  // Filter state - default to 'all'
  String? selectedFilter = 'all';

  /// Set filter
  void setFilter(String? filter) {
    if (mounted) {
      setState(() => selectedFilter = filter ?? 'all');
    }
  }

  /// Clear filter
  void clearFilter() {
    setFilter('all');
  }

  /// Get filter display text
  String getFilterText() {
    if (selectedFilter == null || selectedFilter == 'all') {
      return 'All';
    }
    return '${selectedFilter![0].toUpperCase()}${selectedFilter!.substring(1)}';
  }

  /// Check if filter is active
  bool get hasFilter => selectedFilter != null && selectedFilter != 'all';
}
