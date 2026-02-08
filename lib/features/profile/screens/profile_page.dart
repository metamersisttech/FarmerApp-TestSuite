import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/editprofile/screens/edit_profile_page.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/profile/controllers/profile_controller.dart';
import 'package:flutter_app/features/profile/mixins/profile_state_mixin.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/profile/widgets/kyc_status_card.dart';
import 'package:flutter_app/features/profile/widgets/logout_button.dart';
import 'package:flutter_app/features/profile/widgets/profile_header_card.dart';
import 'package:flutter_app/features/profile/widgets/profile_menu_list.dart';
import 'package:flutter_app/features/profile/screens/my_listings_page.dart';
import 'package:flutter_app/features/sell/screens/post_animal_page.dart';
import 'package:flutter_app/features/vet/widgets/become_vet_card.dart';
import 'package:flutter_app/features/vet/controllers/vet_onboarding_controller.dart';
import 'package:flutter_app/features/vet/screens/vet_onboarding_carousel_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_verification_status_screen.dart';
import 'package:flutter_app/features/vet_dashboard/screens/vet_home_page.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/switch_mode_card.dart';

/// Profile Page
/// 
/// Displays user profile with:
/// - Header with avatar, name, role, location, rating, stats
/// - KYC verification status
/// - Menu items (My Listings, Saved Items, Bookings, Wallet)
/// - Bottom navigation
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with ProfileStateMixin, ToastMixin {
  late final ProfileController _controller;
  bool _isBecomeVetLoading = false;
  bool _isApprovedVet = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setLoading(true);

    await Future.wait([
      _controller.loadProfile(),
      _controller.loadMenuCounts(),
      _checkVetApprovalStatus(),
    ]);

    if (!mounted) return;

    if (_controller.profile != null) {
      setProfile(_controller.profile);
      setMenuCounts(_controller.menuCounts);
    } else if (_controller.errorMessage != null) {
      setError(_controller.errorMessage);
      showErrorToast(_controller.errorMessage!);
    }

    setLoading(false);
  }

  Future<void> _checkVetApprovalStatus() async {
    try {
      final controller = VetOnboardingController();
      final result = await controller.checkVerificationStatus();
      if (result.success && result.verificationStatus != null) {
        _isApprovedVet = result.verificationStatus!.isApproved;
      }
      controller.dispose();
    } catch (_) {
      // Silently fail — default to showing BecomeVetCard
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void _handleEditProfile() async {
    // Fetch fresh user data before navigating
    try {
      final commonHelper = CommonHelper();
      final backendHelper = BackendHelper();
      
      // Initialize auth with stored token
      final accessToken = await commonHelper.getAccessToken();
      if (accessToken != null) {
        APIClient().setAuthorization(accessToken);
      }
      
      // Fetch current user data from API using BackendHelper
      final userJson = await backendHelper.getMe();
      final user = UserModel.fromJson(userJson);
      
      if (!mounted) return;
      
      // Navigate to edit profile page with user data
      // Map both old and new field formats
      final fullNameValue = user.fullName ?? 
          (user.firstName != null || user.lastName != null 
              ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim() 
              : '');
      
      // displayName should default to firstName, not username
      final displayNameValue = user.displayName ?? user.firstName ?? user.username ?? '';
              
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            initialFullName: fullNameValue,
            initialDisplayName: displayNameValue,
            initialDob: user.dob,
            initialAddress: user.address,
            initialState: user.state,
            initialDistrict: user.district,
            initialVillage: user.village,
            initialPincode: user.pincode,
            initialLatitude: user.latitude,
            initialLongitude: user.longitude,
            initialAbout: user.about,
            initialProfileImageUrl: user.profileImage,
          ),
        ),
      );
      
      // If profile was saved successfully, refresh the profile data
      if (result == true) {
        await _handleRefresh();
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast('Failed to load profile data');
    }
  }

  void _handleKycTap() {
    if (profile?.isKycVerified == true) {
      showSuccessToast('Your KYC is already verified');
    } else {
      // TODO: Navigate to KYC verification page
      showSuccessToast('KYC Verification - Coming soon!');
    }
  }

  void _handleBecomeVet() async {
    setState(() => _isBecomeVetLoading = true);

    try {
      final controller = VetOnboardingController();
      final result = await controller.checkVerificationStatus();

      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _isBecomeVetLoading = false);

      if (result.success && result.verificationStatus != null) {
        final status = result.verificationStatus!;
        if (status.hasApplied) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VetVerificationStatusScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VetOnboardingCarouselScreen(),
            ),
          );
        }
      } else {
        showErrorToast(result.message ?? 'Failed to check vet status');
      }
      controller.dispose();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBecomeVetLoading = false);
      showErrorToast('Failed to check vet status');
    }
  }

  void _handleSwitchToVet() async {
    setState(() => _isBecomeVetLoading = true);

    try {
      await CommonHelper().setAppMode('vet');
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VetHomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBecomeVetLoading = false);
      showErrorToast('Failed to switch to vet mode');
    }
  }

  void _handleMyListings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyListingsPage()),
    );
  }

  void _handleSavedItems() {
    // TODO: Navigate to saved items page
    showSuccessToast('Saved Items - Coming soon!');
  }

  void _handleBookings() {
    // TODO: Navigate to bookings page
    showSuccessToast('My Bookings - Coming soon!');
  }

  void _handleWallet() {
    // TODO: Navigate to wallet page
    showSuccessToast('Wallet & Payments - Coming soon!');
  }

  void _handleReviews() {
    // TODO: Navigate to reviews page
    showSuccessToast('Reviews & Ratings - Coming soon!');
  }

  void _handleNotifications() {
    // TODO: Navigate to notifications page
    showSuccessToast('Notifications - Coming soon!');
  }

  void _handleLanguage() {
    // TODO: Navigate to language selection page
    showSuccessToast('Language - Coming soon!');
  }

  void _handlePrivacy() {
    // TODO: Navigate to privacy settings page
    showSuccessToast('Privacy & Security - Coming soon!');
  }

  void _handleHelp() {
    // TODO: Navigate to help & support page
    showSuccessToast('Help & Support - Coming soon!');
  }

  void _handleLogout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Show loading
              setLoading(true);
              
              // Call logout API
              final success = await _controller.logout();
              
              if (!mounted) return;
              
              setLoading(false);
              
              if (success) {
                showSuccessToast('Logged out successfully');
                // Navigate to welcome/login page
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              } else {
                showErrorToast('Failed to logout. Please try again.');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSettings() {
    // TODO: Navigate to settings page
    showSuccessToast('Settings - Coming soon!');
  }

  /// Handle bottom navigation tap
  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Go to Home
        Navigator.pop(context);
        break;
      case 1:
        // Chat
        showSuccessToast('Chat - Coming soon!');
        break;
      case 2:
        // Sell - Navigate to Post Animal page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostAnimalPage()),
        );
        break;
      case 3:
        // My Ads
        showSuccessToast('My Ads - Coming soon!');
        break;
      case 4:
        // Saved
        showSuccessToast('Saved - Coming soon!');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).padding.top + 120;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Green header (fixed at top, behind everything)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(),
                ),
                
                // Scrollable content (on top of header)
                Positioned.fill(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Spacer to push content below header, but allow overlap
                          SizedBox(height: headerHeight - 40),
                          
                          // Profile header card (overlaps green header)
                          profile != null
                              ? ProfileHeaderCard(
                                  profile: profile!,
                                  onEditProfile: _handleEditProfile,
                                )
                              : _buildProfilePlaceholder(),
                          
                          const SizedBox(height: 16),
                          
                          // KYC Status Card
                          KycStatusCard(
                            isVerified: profile?.isKycVerified ?? false,
                            status: profile?.kycStatus,
                            onTap: _handleKycTap,
                          ),

                          const SizedBox(height: 16),

                          // Become a Vet / Switch to Vet Mode
                          if (_isApprovedVet)
                            SwitchModeCard(
                              targetMode: 'vet',
                              onTap: _handleSwitchToVet,
                              isLoading: _isBecomeVetLoading,
                            )
                          else
                            BecomeVetCard(
                              onTap: _handleBecomeVet,
                              isLoading: _isBecomeVetLoading,
                            ),

                          const SizedBox(height: 16),

                          // Menu List
                          ProfileMenuList(
                            menuItems: ProfileMenuItem.defaultMenuItems(
                              myListingsCount: getMenuCount('my_listings'),
                              savedItemsCount: getMenuCount('saved_items'),
                              bookingsCount: getMenuCount('my_bookings'),
                              notificationsCount: getMenuCount('notifications'),
                              onMyListingsTap: _handleMyListings,
                              onSavedItemsTap: _handleSavedItems,
                              onBookingsTap: _handleBookings,
                              onWalletTap: _handleWallet,
                              onReviewsTap: _handleReviews,
                              onNotificationsTap: _handleNotifications,
                              onLanguageTap: _handleLanguage,
                              onPrivacyTap: _handlePrivacy,
                              onHelpTap: _handleHelp,
                            ),
                          ),
                          
                          // Logout Button
                          LogoutButton(
                            onTap: _handleLogout,
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      
      // Fixed Bottom Navigation Bar (same as Home page)
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // No specific tab selected since Profile isn't in the nav
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).padding.top + 120,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.authPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: _handleSettings,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleRefresh,
            child: const Text('Tap to retry'),
          ),
        ],
      ),
    );
  }
}

