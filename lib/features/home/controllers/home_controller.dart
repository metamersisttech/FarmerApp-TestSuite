import 'package:flutter_app/core/base/base_controller.dart';

/// Controller for home page operations
class HomeController extends BaseController {
  int _currentBottomNavIndex = 0;
  String _searchQuery = '';

  /// Current bottom navigation bar index
  int get currentBottomNavIndex => _currentBottomNavIndex;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Set bottom navigation index
  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    // TODO: Implement search logic when backend is ready
  }

  /// Handle notification tap
  void onNotificationTap() {
    // TODO: Navigate to notifications screen
    setError('Notifications feature coming soon!');
  }

  /// Handle profile tap
  void onProfileTap() {
    // TODO: Navigate to profile screen
    setError('Profile feature coming soon!');
  }

  /// Handle wallet tap
  void onWalletTap() {
    // TODO: Navigate to wallet screen
    setError('Wallet feature coming soon!');
  }
}

