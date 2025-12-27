import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/services/location_service.dart';
import 'package:flutter_app/features/home/controllers/home_controller.dart';
import 'package:flutter_app/features/home/mixins/home_state_mixin.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/home/widgets/home_search_bar.dart';
import 'package:flutter_app/features/home/widgets/profile_section.dart';
import 'package:flutter_app/features/home/widgets/quick_actions_section.dart';
import 'package:flutter_app/features/home/widgets/recent_listing_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Home Page
///
/// Main screen after user logs in.
/// Features a fixed bottom navigation bar while content scrolls.
class HomePage extends StatefulWidget {
  final UserModel? user;

  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeStateMixin, ToastMixin {
  late final HomeController _homeController;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _homeController = HomeController();
    
    // Check location permission after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermission();
    });
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  /// Check and request location permission
  Future<void> _checkLocationPermission() async {
    // Check if permission is already granted
    final isGranted = await _locationService.isPermissionGranted();
    if (isGranted) return;

    if (!mounted) return;

    // Show custom dialog asking user to enable location
    final shouldEnable = await LocationService.showLocationPermissionDialog(context);
    
    if (shouldEnable && mounted) {
      // User clicked "Enable" - request permission
      final result = await _locationService.requestLocationAccess();
      
      if (!mounted) return;
      
      if (result.success) {
        showSuccessToast('Location access enabled');
      } else if (result.serviceDisabled) {
        // Location service is disabled, prompt to enable
        showErrorToast('Please enable location services in settings');
        await _locationService.openLocationSettings();
      } else if (result.permissionDenied) {
        showErrorToast('Location permission denied');
      }
    }
  }

  /// Handle bottom navigation tap
  void _handleBottomNavTap(int index) {
    setBottomNavIndex(index);

    // Handle navigation based on index
    NavigationResult result;
    switch (index) {
      case 0:
        // Already on Home
        return;
      case 1:
        result = HomeNavigationService.toChat(context);
        break;
      case 2:
        result = HomeNavigationService.toSell(
          context,
          onReturn: resetToHomeTab,
        );
        break;
      case 3:
        result = HomeNavigationService.toMyAds(context);
        break;
      case 4:
        result = HomeNavigationService.toSaved(context);
        break;
      default:
        return;
    }

    // Show message if feature is coming soon
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle search input
  void _handleSearch(String value) {
    updateSearchQuery(value);
    _homeController.updateSearchQuery(value);
    // TODO: Implement search when backend is ready
  }

  /// Handle notification tap
  void _handleNotificationTap() {
    final result = HomeNavigationService.toNotifications(context);
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle profile tap
  void _handleProfileTap() {
    final result = HomeNavigationService.toProfile(context);
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  /// Handle wallet tap
  void _handleWalletTap() {
    final result = HomeNavigationService.toWallet(context);
    if (!result.success && result.message != null) {
      showComingSoonMessage(result.message!.replaceAll(' feature coming soon!', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract first name from user, fallback to 'Guest'
    final firstName = widget.user?.firstName ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Section with overlapping Search Bar
            _buildProfileWithSearch(firstName),

            // Add spacing for the overlapping search bar
            const SizedBox(height: 35),

            // 2. Horizontal Scrolling Templates
            _buildScrollingTemplates(),

            // 3. Quick Actions Section
            const QuickActionsSection(),

            // 4. Recent Listing Section (Scrollable - takes remaining space)
            Expanded(child: RecentListingSection(onActionPressed: () {})),
          ],
        ),
      ),
      // Bottom Navigation Bar (Fixed Footer)
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  /// Build profile section with overlapping search bar
  Widget _buildProfileWithSearch(String firstName) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Profile Section
        ProfileSection(
          firstName: firstName,
          notificationCount: 3,
          onNotificationTap: _handleNotificationTap,
          onProfileTap: _handleProfileTap,
          onWalletTap: _handleWalletTap,
        ),

        // Search Bar positioned below profile section
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: HomeSearchBar(onChanged: _handleSearch),
        ),
      ],
    );
  }

  /// Build scrolling templates section
  Widget _buildScrollingTemplates() {
    return ScrollingTemplates(
      templates: [
        TemplateCardData(
          title: 'New Listings',
          subtitle: 'Check out latest animals',
          icon: Icons.fiber_new,
          backgroundColor: AppTheme.authPrimaryColor,
          buttonText: 'View Now',
          onPressed: () {
            // TODO: Navigate to listings
            showComingSoonMessage('New Listings');
          },
        ),
        TemplateCardData(
          title: 'Vet Discount',
          subtitle: 'Special offers for you',
          icon: Icons.local_hospital,
          backgroundColor: Colors.orange,
          buttonText: 'View Now',
          onPressed: () {
            // TODO: Navigate to vet services
            showComingSoonMessage('Vet Discount');
          },
        ),
        TemplateCardData(
          title: 'Premium Feed',
          subtitle: 'Quality feed at best price',
          icon: Icons.grass,
          backgroundColor: Colors.green,
          buttonText: 'Shop Now',
          onPressed: () {
            // TODO: Navigate to shop
            showComingSoonMessage('Premium Feed');
          },
        ),
        TemplateCardData(
          title: 'Transportation',
          subtitle: 'Book transport services',
          icon: Icons.local_shipping,
          backgroundColor: Colors.deepPurple,
          buttonText: 'Book Now',
          onPressed: () {
            // TODO: Navigate to transport booking
            showComingSoonMessage('Transportation');
          },
        ),
      ],
    );
  }
}
