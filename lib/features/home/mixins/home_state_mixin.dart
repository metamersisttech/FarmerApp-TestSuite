import 'package:flutter/material.dart';

/// Mixin for common home page state management
mixin HomeStateMixin<T extends StatefulWidget> on State<T> {
  int currentBottomNavIndex = 0;
  String searchQuery = '';

  /// Set bottom navigation index
  void setBottomNavIndex(int index) {
    if (mounted) {
      setState(() => currentBottomNavIndex = index);
    }
  }

  /// Reset to home tab
  void resetToHomeTab() {
    setBottomNavIndex(0);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    if (mounted) {
      setState(() => searchQuery = query);
    }
  }

  /// Clear search
  void clearSearch() {
    if (mounted) {
      setState(() => searchQuery = '');
    }
  }

  /// Show feature coming soon message
  void showComingSoonMessage(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$feature feature coming soon!')),
      );
    }
  }
}

