import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/editprofile/screens/edit_profile_page.dart';
import 'package:flutter_app/features/profile/controllers/profile_controller.dart';
import 'package:flutter_app/features/profile/mixins/profile_state_mixin.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/profile/screens/my_listings_page.dart';
import 'package:flutter_app/features/profile/widgets/kyc_status_card.dart';
import 'package:flutter_app/features/profile/widgets/logout_button.dart';
import 'package:flutter_app/features/profile/widgets/profile_header_card.dart';
import 'package:flutter_app/features/profile/widgets/profile_menu_list.dart';
import 'package:flutter_app/features/transport/controllers/transport_onboarding_controller.dart';
import 'package:flutter_app/features/transport/screens/farmer/my_transport_bookings_screen.dart';
import 'package:flutter_app/features/transport/screens/home/transport_dashboard_screen.dart';
import 'package:flutter_app/features/transport/screens/onboarding/pending_approval_screen.dart';
import 'package:flutter_app/features/transport/screens/onboarding/role_request_screen.dart';
import 'package:flutter_app/features/transport/widgets/become_transport_card.dart';
import 'package:flutter_app/features/vet/controllers/vet_onboarding_controller.dart';
import 'package:flutter_app/features/vet/screens/vet_onboarding_carousel_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_verification_status_screen.dart';
import 'package:flutter_app/features/vet/widgets/become_vet_card.dart';
import 'package:flutter_app/features/vet_dashboard/screens/vet_home_page.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/switch_mode_card.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/common/language_switcher_widget.dart';
import 'package:flutter_app/features/favourite/services/favourite_badge_service.dart';
import 'package:flutter_app/features/profile/services/my_listings_badge_service.dart';
import 'package:flutter_app/main.dart' show routeObserver;

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
    with ProfileStateMixin, ToastMixin, RouteAware {
  late final ProfileController _controller;
  bool _isBecomeVetLoading = false;
  bool _isApprovedVet = false;
  bool _isBecomeTransportLoading = false;
  bool _isApprovedTransport = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this page
    print('[ProfilePage] 🔄 User returned to profile, refreshing menu counts...');
    _refreshMenuCounts();
  }

  Future<void> _refreshMenuCounts() async {
    await _controller.loadMenuCounts();
    if (mounted) {
      setMenuCounts(_controller.menuCounts);
      print('[ProfilePage] ✅ Menu counts refreshed: ${_controller.menuCounts}');
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setLoading(true);

    await Future.wait([
      _controller.loadProfile(),
      _controller.loadMenuCounts(),
      _checkVetApprovalStatus(),
      _checkTransportApprovalStatus(),
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

  Future<void> _checkTransportApprovalStatus() async {
    try {
      final controller = TransportOnboardingController();
      final result = await controller.checkVerificationStatus();
      if (result.success && result.verificationStatus != null) {
        _isApprovedTransport = result.verificationStatus!.isApproved;
      }
      controller.dispose();
    } catch (_) {
      // Silently fail — default to showing BecomeTransportCard
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
      final fullNameValue =
          user.fullName ??
          (user.firstName != null || user.lastName != null
              ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
              : '');

      // displayName should default to firstName, not username
      final displayNameValue =
          user.displayName ?? user.firstName ?? user.username ?? '';

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
      showSuccessToast('profile.kyc_verified'.tr());
    } else {
      showSuccessToast('profile.kyc_coming_soon'.tr());
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

  void _handleBecomeTransport() async {
    setState(() => _isBecomeTransportLoading = true);

    try {
      final controller = TransportOnboardingController();
      final result = await controller.checkVerificationStatus();

      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _isBecomeTransportLoading = false);

      if (result.success && result.verificationStatus != null) {
        final status = result.verificationStatus!;
        if (status.hasApplied) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PendingApprovalScreen(requestId: status.requestId!),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleRequestScreen(),
            ),
          );
        }
      } else {
        showErrorToast(result.errorMessage ?? 'Failed to check transport status');
      }
      controller.dispose();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBecomeTransportLoading = false);
      showErrorToast('Failed to check transport status');
    }
  }

  void _handleSwitchToTransport() async {
    setState(() => _isBecomeTransportLoading = true);

    try {
      await CommonHelper().setAppMode('transport');
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TransportDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBecomeTransportLoading = false);
      showErrorToast('Failed to switch to transport mode');
    }
  }

  void _handleMyListings() async {
    // Mark listings as viewed (clears badge count)
    final badgeService = MyListingsBadgeService();
    await badgeService.markAsViewed();
    
    // Navigate to My Listings page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Theme(
          data: Theme.of(context),
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: const MyListingsPage(showBackButton: true),
          ),
        ),
      ),
    );
    
    // Refresh menu counts when returning from My Listings page
    // This will recalculate the badge based on any new listings added
    await _controller.loadMenuCounts();
    if (mounted) {
      setMenuCounts(_controller.menuCounts);
    }
  }

  void _handleMyBids() {
    Navigator.pushNamed(context, AppRoutes.myBids);
  }

  void _handleSavedItems() async {
    // Mark favorites as viewed (clears badge count)
    final badgeService = FavouriteBadgeService();
    await badgeService.markAsViewed();
    
    // Navigate to favorite listings page
    await Navigator.pushNamed(context, AppRoutes.favouriteListings);
    
    // Refresh menu counts when returning from favorites page
    // This will recalculate the badge based on any new favorites added
    await _controller.loadMenuCounts();
    if (mounted) {
      setMenuCounts(_controller.menuCounts);
    }
  }

  void _handleBookings() {
    Navigator.pushNamed(context, AppRoutes.myAppointments);
  }

  void _handleMessages() {
    Navigator.pushNamed(context, AppRoutes.conversations);
  }

  void _handleWallet() {
    showSuccessToast('wallet.coming_soon'.tr());
  }

  void _handleReviews() {
    showSuccessToast('common.coming_soon'.tr());
  }

  void _handleNotifications() {
    Navigator.pushNamed(context, AppRoutes.notifications);
  }

  void _handleLanguage() {
    LanguageSwitcherWidget.showPicker(context);
  }

  void _handlePrivacy() {
    showSuccessToast('common.coming_soon'.tr());
  }

  void _handleHelp() {
    showSuccessToast('common.coming_soon'.tr());
  }

  void _handleLogout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('auth.logout'.tr()),
        content: Text('auth.logout_confirm'.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              setLoading(true);
              final success = await _controller.logout();

              if (!mounted) return;

              setLoading(false);

              if (success) {
                showSuccessToast('auth.logout_success'.tr());
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              } else {
                showErrorToast('auth.logout_failed'.tr());
              }
            },
            child: Text(
              'auth.logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTransportBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const MyTransportBookingsScreen()),
    );
  }

  void _handleSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).padding.top + 120;

    return Material(
      color: AppTheme.backgroundColor,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Green header (fixed at top, behind everything)
                Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),

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

                          // Become Transport Provider / Switch to Transport Mode
                          if (_isApprovedTransport)
                            SwitchModeCard(
                              targetMode: 'transport',
                              onTap: _handleSwitchToTransport,
                              isLoading: _isBecomeTransportLoading,
                            )
                          else
                            BecomeTransportCard(
                              onTap: _handleBecomeTransport,
                              isLoading: _isBecomeTransportLoading,
                            ),

                          const SizedBox(height: 16),

                          // Menu List
                          ProfileMenuList(
                            menuItems: ProfileMenuItem.defaultMenuItems(
                              myListingsCount: getMenuCount('my_listings'),
                              savedItemsCount: getMenuCount('saved_items'),
                              bookingsCount: getMenuCount('my_bookings'),
                              myBidsCount: getMenuCount('my_bids'),
                              notificationsCount: getMenuCount('notifications'),
                              onMyListingsTap: _handleMyListings,
                              onSavedItemsTap: _handleSavedItems,
                              onBookingsTap: _handleBookings,
                              onMyBidsTap: _handleMyBids,
                              onMessagesTap: _handleMessages,
                              onWalletTap: _handleWallet,
                              onReviewsTap: _handleReviews,
                              onNotificationsTap: _handleNotifications,
                              onLanguageTap: _handleLanguage,
                              onPrivacyTap: _handlePrivacy,
                              onHelpTap: _handleHelp,
                              onTransportBookingsTap: _handleTransportBookings,
                            ),
                          ),

                          // Logout Button
                          LogoutButton(onTap: _handleLogout),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
          Text(
            'profile.title'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              // Language switcher in profile header
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: Colors.white,
                      displayColor: Colors.white,
                    ),
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  child: const LanguageSwitcherWidget(compact: true),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('settings_btn'),
                onTap: _handleSettings,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings, color: Colors.white, size: 22),
                ),
              ),
            ],
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
          Icon(Icons.person_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'profile.load_failed'.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleRefresh,
            child: Text('profile.tap_retry'.tr()),
          ),
        ],
      ),
    );
  }
}
