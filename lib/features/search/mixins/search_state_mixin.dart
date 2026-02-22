import 'package:flutter/material.dart';

/// Search State Mixin
///
/// Handles UI state and business logic for search functionality
/// 
/// Usage: Mix this into StatefulWidget's State class
mixin SearchStateMixin<T extends StatefulWidget> on State<T> {
  // Recent searches list
  List<String> recentSearches = [];
  
  // Current location
  String currentLocation = 'Bangalore, IN';
  
  // Loading state
  bool isLoading = false;
  
  /// Initialize search state
  void initializeSearchState() {
    // Load recent searches from cache/storage
    loadRecentSearches();
  }
  
  /// Load recent searches from storage
  Future<void> loadRecentSearches() async {
    // TODO: Load from cache/local storage
    // For now, use mock data
    setState(() {
      recentSearches = [
        'Jersey Cow',
        'Buffalo',
        'Goat breeds',
        'Sheep for sale',
      ];
    });
  }
  
  /// Add search to recent searches
  void addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      // Remove if already exists
      recentSearches.remove(query);
      // Add to beginning
      recentSearches.insert(0, query);
      // Keep only last 10 searches
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10);
      }
    });
    
    // TODO: Save to cache/local storage
  }
  
  /// Clear all recent searches
  void clearAllRecentSearches() {
    setState(() {
      recentSearches.clear();
    });
    
    // TODO: Clear from cache/local storage
  }
  
  /// Update current location
  void updateCurrentLocation(String location) {
    setState(() {
      currentLocation = location;
    });
  }
  
  /// Set loading state
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        isLoading = loading;
      });
    }
  }
}
