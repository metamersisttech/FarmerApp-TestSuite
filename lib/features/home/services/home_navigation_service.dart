import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/screens/profile_page.dart';
import 'package:flutter_app/features/sell/screens/post_animal_page.dart';
import 'package:flutter_app/features/vet/screens/vet_services_page.dart';
import 'package:flutter_app/features/viewalllistings/screens/viewalllistings_page.dart';
import 'package:flutter_app/features/recentlyviewed/screens/recentlyviewed_page.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Result of navigation action
class NavigationResult {
  final bool success;
  final String? message;

  const NavigationResult({required this.success, this.message});

  factory NavigationResult.success() => const NavigationResult(success: true);
  factory NavigationResult.comingSoon(String feature) {
    return NavigationResult(success: false, message: '$feature feature coming soon!');
  }
}

/// Service for handling home navigation
class HomeNavigationService {
  /// Navigate to Chat screen
  static NavigationResult toChat(BuildContext context) {
    // TODO: Implement chat navigation when screen is ready
    return NavigationResult.comingSoon('Chat');
  }

  /// Navigate to Post Animal (Sell) screen
  static NavigationResult toSell(BuildContext context, {VoidCallback? onReturn}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostAnimalPage()),
    ).then((_) {
      if (onReturn != null) {
        onReturn();
      }
    });
    return NavigationResult.success();
  }

  /// Navigate to My Ads screen
  static NavigationResult toMyAds(BuildContext context) {
    // TODO: Implement my ads navigation when screen is ready
    return NavigationResult.comingSoon('My Ads');
  }

  /// Navigate to Saved/Liked listings
  static NavigationResult toSaved(BuildContext context) {
    // TODO: Implement saved listings navigation when screen is ready
    return NavigationResult.comingSoon('Saved listings');
  }

  /// Navigate to Notifications screen
  static NavigationResult toNotifications(BuildContext context) {
    // TODO: Implement notifications navigation when screen is ready
    return NavigationResult.comingSoon('Notifications');
  }

  /// Navigate to Profile screen
  static NavigationResult toProfile(BuildContext context, {VoidCallback? onReturn}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    ).then((_) {
      if (onReturn != null) {
        onReturn();
      }
    });
    return NavigationResult.success();
  }

  /// Navigate to Wallet screen
  static NavigationResult toWallet(BuildContext context) {
    // TODO: Implement wallet navigation when screen is ready
    return NavigationResult.comingSoon('Wallet');
  }

  /// Navigate to Animal Detail screen
  static NavigationResult toAnimalDetail(BuildContext context, int listingId) {
    Navigator.pushNamed(
      context,
      AppRoutes.animalDetail,
      arguments: listingId,
    );
    return NavigationResult.success();
  }

  /// Navigate to Marketplace (View All Listings) screen
  static NavigationResult toMarketplace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAllListingsPage()),
    );
    return NavigationResult.success();
  }

  /// Navigate to Vet Services screen
  static NavigationResult toVetServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VetServicesPage()),
    );
    return NavigationResult.success();
  }

  /// Navigate to Recently Viewed Listings screen
  static NavigationResult toRecentlyViewed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecentlyViewedPage()),
    );
    return NavigationResult.success();
  }
}

