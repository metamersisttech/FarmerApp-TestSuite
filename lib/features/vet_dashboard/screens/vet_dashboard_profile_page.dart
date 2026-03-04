import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/profile/widgets/logout_button.dart';
import 'package:flutter_app/features/profile/widgets/profile_menu_list.dart';
import 'package:flutter_app/features/profile/models/profile_model.dart';
import 'package:flutter_app/features/vet/controllers/vet_profile_controller.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';
import 'package:flutter_app/features/vet_dashboard/mixins/vet_dashboard_state_mixin.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/switch_mode_card.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/vet_profile_header.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/vet_profile_info_card.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/availability_status_card.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/profile_error_placeholder.dart';
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
    with ToastMixin, VetDashboardStateMixin {
  late final VetProfileController _controller;
  bool _isLoading = true;
  bool _isSwitchingMode = false;

  VetProfileModel? get _profile => _controller.profile;

  @override
  void initState() {
    super.initState();
    debugPrint('[VetDashboardProfile] initState called');
    _controller = VetProfileController();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() => loadVetProfileData(
        controller: _controller,
        setLoading: (loading) => setState(() => _isLoading = loading),
        showErrorToast: showErrorToast,
      );

  Future<void> _handleSwitchToFarmer() => handleSwitchToFarmer(
        setSwitchingMode: (switching) => setState(() => _isSwitchingMode = switching),
        showErrorToast: showErrorToast,
      );

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Fixed header at top
                VetProfileHeader(
                  onBackPressed: handleBackPressed,
                ),

                // Scrollable content in the middle
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Vet profile card
                          _profile != null
                              ? VetProfileInfoCard(profile: _profile!)
                              : ProfileErrorPlaceholder(onRetry: _loadData),

                          const SizedBox(height: 16),

                          // Availability toggle
                          if (_profile != null) ...[
                            AvailabilityStatusCard(
                              isAvailable: _profile!.available,
                            ),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Fixed logout button at bottom
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: bottomPadding > 0 ? bottomPadding : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: LogoutButton(onTap: () {
                    handleLogout(
                      setLoading: (loading) => setState(() => _isLoading = loading),
                      showSuccessToast: showSuccessToast,
                      showErrorToast: showErrorToast,
                    );
                  }),
                ),
              ],
            ),
    );
  }
}
