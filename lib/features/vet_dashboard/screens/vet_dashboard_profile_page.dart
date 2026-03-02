import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/services/fcm_service.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/profile/widgets/logout_button.dart';
import 'package:flutter_app/features/profile/widgets/profile_menu_list.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/switch_mode_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Vet Dashboard Profile Page
///
/// Full profile page within vet mode, mirroring the farmer ProfilePage.
/// Shows vet info, availability toggle, vet-specific menu, and mode switch.
class VetDashboardProfilePage extends StatefulWidget {
  const VetDashboardProfilePage({super.key});

  @override
  State<VetDashboardProfilePage> createState() =>
      _VetDashboardProfilePageState();
}

class _VetDashboardProfilePageState extends State<VetDashboardProfilePage>
    with ToastMixin {
  late final VetProfileController _controller;
  bool _isLoading = true;
  bool _isSwitchingMode = false;

  VetProfileModel? get _profile => _controller.profile;

  @override
  void initState() {
    super.initState();
    _controller = VetProfileController();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadProfile();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_controller.errorMessage != null) {
      showErrorToast(_controller.errorMessage!);
    }
  }

  Future<void> _handleSwitchToFarmer() async {
    setState(() => _isSwitchingMode = true);

    try {
      await CommonHelper().setAppMode('farmer');
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSwitchingMode = false);
      showErrorToast('Failed to switch mode');
    }
  }

  void _handleLogout() {
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
              setState(() => _isLoading = true);

              // Unregister FCM token before clearing auth
              await FCMService().unregisterToken();

              await CommonHelper().clearAll();

              if (!mounted) return;
              setState(() => _isLoading = false);

              showSuccessToast('Logged out successfully');
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
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

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
      case 2:
      case 3:
        showSuccessToast('Coming soon!');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).padding.top + 120;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Green header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(),
                ),

                // Scrollable content
                Positioned.fill(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: headerHeight - 40),

                          // Vet profile card
                          _profile != null
                              ? _buildVetProfileCard()
                              : _buildPlaceholder(),

                          const SizedBox(height: 16),

                          // Availability toggle
                          if (_profile != null) ...[
                            _buildAvailabilityCard(),
                            const SizedBox(height: 16),
                          ],

                          // Vet menu
                          ProfileMenuList(
                            menuItems: [
                              ProfileMenuItem(
                                id: 'appointments',
                                title: 'My Appointments',
                                icon: Icons.calendar_today,
                                onTap: () => Navigator.pushNamed(
                                    context, '/vet-appointments'),
                              ),
                              ProfileMenuItem(
                                id: 'availability',
                                title: 'Manage Availability',
                                icon: Icons.schedule,
                                onTap: () => Navigator.pushNamed(
                                    context, '/vet-availability'),
                              ),
                              ProfileMenuItem(
                                id: 'pricing',
                                title: 'Manage Pricing',
                                icon: Icons.payments,
                                onTap: () => Navigator.pushNamed(
                                    context, '/vet-pricing'),
                              ),
                              ProfileMenuItem(
                                id: 'vet_profile',
                                title: 'Vet Clinical Profile',
                                icon: Icons.medical_information,
                                onTap: () => Navigator.pushNamed(
                                    context, '/vet-profile'),
                              ),
                              ProfileMenuItem(
                                id: 'reviews',
                                title: 'Reviews & Ratings',
                                icon: Icons.star_outline,
                                onTap: () =>
                                    showSuccessToast('Reviews - Coming soon!'),
                              ),
                              ProfileMenuItem(
                                id: 'notifications',
                                title: 'Notifications',
                                icon: Icons.notifications_outlined,
                                onTap: () => showSuccessToast(
                                    'Notifications - Coming soon!'),
                              ),
                              ProfileMenuItem(
                                id: 'help',
                                title: 'Help & Support',
                                icon: Icons.help_outline,
                                onTap: () =>
                                    showSuccessToast('Help - Coming soon!'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Switch to farmer mode
                          SwitchModeCard(
                            targetMode: 'farmer',
                            onTap: _handleSwitchToFarmer,
                            isLoading: _isSwitchingMode,
                          ),

                          const SizedBox(height: 16),

                          // Logout
                          LogoutButton(onTap: _handleLogout),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
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
      decoration: const BoxDecoration(
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
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vet Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => showSuccessToast('Settings - Coming soon!'),
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

  Widget _buildVetProfileCard() {
    final profile = _profile!;
    final name = profile.displayName;
    final initials = profile.initials;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          // Avatar + name
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.authPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dr. $name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile.isDocumentsVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    if (profile.specialization != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.specialization!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (profile.clinicName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.clinicName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Stats row
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                '${profile.yearsOfExperience ?? 0}',
                'Years Exp.',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStat(
                profile.specializations.length.toString(),
                'Specializations',
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildStat(
                profile.consultationFee != null
                    ? '\u20B9${double.tryParse(profile.consultationFee!)?.toInt() ?? profile.consultationFee}'
                    : 'N/A',
                'Consult Fee',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.authPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (_profile!.available ? Colors.green : Colors.grey)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _profile!.available
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: _profile!.available ? Colors.green : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile!.available
                      ? 'Currently Available'
                      : 'Currently Unavailable',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _profile!.available ? Colors.green : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your availability schedule',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
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
            Icons.medical_services_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load vet profile',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadData,
            child: const Text('Tap to retry'),
          ),
        ],
      ),
    );
  }
}
