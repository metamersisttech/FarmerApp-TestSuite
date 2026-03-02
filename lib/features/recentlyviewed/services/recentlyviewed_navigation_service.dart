import 'package:flutter/material.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Navigation service for recently viewed feature
class RecentlyViewedNavigationService {
  /// Navigate to recently viewed listings page
  static void toRecentlyViewed(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.recentlyViewed);
  }
}
