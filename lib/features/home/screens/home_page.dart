import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
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
import 'package:flutter_app/features/location/screens/location_page.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:geolocator/geolocator.dart';

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
  UserModel? _currentUser;
  String _currentLocationText = 'Bangalore, IN';
  bool _isLoadingUserData = false; // Flag to prevent multiple loads

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _homeController = HomeController();

    // Fetch listings and check location after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListings();
      _checkLocationPermission();
      _loadUserFromStorage(); // Load latest user data
      _checkLocationServiceStatus(); // Check if location is turned off
    });
  }
  
  /// Load user data from storage to get latest updates
  Future<void> _loadUserFromStorage() async {
    // Prevent multiple simultaneous loads
    if (_isLoadingUserData) return;
    
    _isLoadingUserData = true;
    
    try {
      final commonHelper = CommonHelper();
      final user = await commonHelper.getLoggedInUser();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      // Ignore errors, keep using widget.user
    } finally {
      _isLoadingUserData = false;
    }
  }

  /// Fetch listings from API
  Future<void> _fetchListings() async {
    await _homeController.fetchListings();

    if (!mounted) return;

    // Refresh UI with new listings
    setState(() {});

    if (_homeController.errorMessage != null) {
      showErrorToast(_homeController.errorMessage!);
    }
  }

  /// Handle listing tap
  void _handleListingTap(dynamic listing) {
    // TODO: Navigate to animal detail page
    showComingSoonMessage('Animal Detail');
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  /// Check and request location permission
  /// Shows dialog only when needed based on current permission status:
  /// - If "While using app" is granted: Auto-fetch location
  /// - If "Only this time" was selected: Show dialog every login (temporary)
  /// - If "Don't allow" was selected: Show dialog to allow user to enable
  Future<void> _checkLocationPermission() async {
    if (!mounted) return;

    try {
      // First, check current permission status
      final currentPermission = await _locationService.checkPermission();
      
      print('📍 Current location permission: $currentPermission');
      
      // If user has granted permanent permission, auto-fetch location
      if (currentPermission == LocationPermission.always || 
          currentPermission == LocationPermission.whileInUse) {
        print('✅ Location permission already granted, fetching location...');
        await _fetchAndDisplayCurrentLocation();
        return;
      }
      
      print('⚠️ Location permission not granted, showing dialog...');
      
      // Show dialog for:
      // - LocationPermission.denied (not yet asked, or "Only this time" was selected before)
      // - LocationPermission.deniedForever (user selected "Don't allow")
      final shouldEnable = await LocationService.showLocationPermissionDialog(context);
      
      print('👤 User response to dialog: $shouldEnable');
      
      if (shouldEnable && mounted) {
        // User clicked "Enable" - request permission
        final result = await _locationService.requestLocationAccess();
        
        if (!mounted) return;
        
        if (result.success) {
          showSuccessToast('Location access enabled');
          // Fetch location after permission granted
          await _fetchAndDisplayCurrentLocation();
        } else if (result.serviceDisabled) {
          // Location service is disabled, prompt to enable
          showErrorToast('Please enable location services in settings');
          await _locationService.openLocationSettings();
        } else if (result.permissionDenied) {
          showErrorToast('Location permission denied');
        }
      } else if (!shouldEnable) {
        // User clicked "Not Now"
        showInfoToast('You can enable location later from settings');
      }
    } catch (e) {
      print('❌ Error checking location permission: $e');
    }
  }

  /// Fetch current location and display it
  Future<void> _fetchAndDisplayCurrentLocation() async {
    try {
      // Show loading indicator
      setState(() {
        _currentLocationText = 'Getting location...';
      });

      // Get location with address
      final locationResult = await _locationService.getCurrentLocation(
        includeAddress: true,
      );

      if (!mounted) return;

      if (locationResult.success && locationResult.address != null) {
        setState(() {
          _currentLocationText = locationResult.address!;
        });
        print('📍 Location updated: ${locationResult.address}');
      } else {
        // Fallback to default if failed
        setState(() {
          _currentLocationText = 'Bangalore, IN';
        });
        print('⚠️ Failed to get address, using default');
      }
    } catch (e) {
      print('❌ Error fetching location: $e');
      // Fallback to default
      if (mounted) {
        setState(() {
          _currentLocationText = 'Bangalore, IN';
        });
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
  void _handleProfileTap() async {
    final result = HomeNavigationService.toProfile(context);
    
    // Reload user data after returning from profile page
    if (result.success) {
      await _loadUserFromStorage();
    } else if (result.message != null) {
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

  /// Handle location tap - Navigate to location page
  void _handleLocationTap() async {
    final selectedLocation = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPage(),
      ),
    );
    
    if (selectedLocation != null && mounted) {
      // Update the displayed location
      setState(() {
        _currentLocationText = selectedLocation.displayLocation;
      });
      
      showSuccessToast('Location updated to ${selectedLocation.displayLocation}');
    }
  }

  /// Check location service status on page load
  /// Shows dialog automatically if location is turned off
  Future<void> _checkLocationServiceStatus() async {
    if (!mounted) return;
    
    // Wait a bit for the page to settle before showing dialog
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Check if location services are enabled
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      // Location is turned off - show dialog automatically
      print('🔴 Location services are disabled, showing dialog...');
      _showLocationOffDialog();
    } else {
      print('✅ Location services are enabled');
    }
  }

  /// Show dialog when device location is turned off
  void _showLocationOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off,
                size: 48,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Device location is off',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B2B2B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Share your current location to easily buy and sell near you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Enable Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Open location settings
                  final opened = await _locationService.openLocationSettings();
                  if (!opened) {
                    showErrorToast('Could not open location settings');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enable Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract display name from user
    // Priority: displayName > firstName > username > 'Guest'
    // Use _currentUser (which gets updated from storage) instead of widget.user
    final user = _currentUser ?? widget.user;
    final displayName = user?.displayName ?? 
                        user?.firstName ?? 
                        user?.username ?? 
                        'Guest';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header: Profile Section with overlapping Search Bar
            _buildProfileWithSearch(displayName),

            // Add spacing for the overlapping search bar
            const SizedBox(height: 35),

            // Scrollable Content: Templates, Quick Actions, and Recent Listings
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Horizontal Scrolling Templates
                    _buildScrollingTemplates(),

                    // 3. Quick Actions Section
                    const QuickActionsSection(),

                    // 4. Recent Listing Section
                    RecentListingSection(
                      listings: _homeController.listings,
                      isLoading: _homeController.isLoading,
                      onActionPressed: () {
                        // TODO: Navigate to marketplace
                        showComingSoonMessage('Marketplace');
                      },
                      onListingTap: _handleListingTap,
                    ),
                  ],
                ),
              ),
            ),
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
  Widget _buildProfileWithSearch(String displayName) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Profile Section
        ProfileSection(
          firstName: displayName,
          location: _currentLocationText,
          notificationCount: 3,
          onNotificationTap: _handleNotificationTap,
          onProfileTap: _handleProfileTap,
          onWalletTap: _handleWalletTap,
          onLocationTap: _handleLocationTap,
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
