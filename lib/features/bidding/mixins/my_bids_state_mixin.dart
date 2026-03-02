import 'package:flutter/material.dart';

/// Mixin for My Bids page filter state
mixin MyBidsStateMixin<T extends StatefulWidget> on State<T> {
  String? _selectedFilter;

  String? get selectedFilter => _selectedFilter;

  bool get hasFilter => _selectedFilter != null;

  void setFilter(String? filter) {
    if (mounted) {
      setState(() => _selectedFilter = filter);
    }
  }

  void clearFilter() {
    if (mounted) {
      setState(() => _selectedFilter = null);
    }
  }
}
