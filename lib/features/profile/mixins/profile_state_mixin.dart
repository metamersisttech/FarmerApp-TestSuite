import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';

/// Mixin for profile state management in widgets
mixin ProfileStateMixin<T extends StatefulWidget> on State<T> {
  ProfileModel? profile;
  Map<String, int> menuCounts = {};
  bool isLoading = false;
  String? errorMessage;

  /// Set profile data
  void setProfile(ProfileModel? data) {
    if (mounted) {
      setState(() => profile = data);
    }
  }

  /// Set menu counts
  void setMenuCounts(Map<String, int> counts) {
    if (mounted) {
      setState(() => menuCounts = counts);
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => isLoading = loading);
    }
  }

  /// Set error message
  void setError(String? error) {
    if (mounted) {
      setState(() => errorMessage = error);
    }
  }

  /// Clear error
  void clearError() {
    if (mounted) {
      setState(() => errorMessage = null);
    }
  }

  /// Check if profile is loaded
  bool get hasProfile => profile != null;

  /// Get count for a specific menu item
  int getMenuCount(String menuId) => menuCounts[menuId] ?? 0;
}

