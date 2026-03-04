import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/profile/widgets/logout_button.dart';
import 'package:flutter_app/features/profile/widgets/profile_menu_list.dart';
import 'package:flutter_app/features/vet_dashboard/mixins/vet_dashboard_state_mixin.dart';
import 'package:flutter_app/features/vet_dashboard/mixins/vet_dashboard_profile_mixin.dart';
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
    with ToastMixin, VetDashboardStateMixin, VetDashboardProfileMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('[VetDashboardProfile] initState called');
    initializeProfileController();
    _loadData();
  }

  @override
  void dispose() {
    disposeProfileController();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load user from storage and profile data in parallel, but wait for both
    await Future.wait([
      loadUserFromStorage(),
      loadProfileData(showErrorToast: showErrorToast),
    ]);
  }

  Future<void> _handleSwitchToFarmer() => handleSwitchToFarmer(
        setSwitchingMode: setSwitchingMode,
        showErrorToast: showErrorToast,
      );

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: isProfileLoading
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
                          vetProfile != null
                              ? VetProfileInfoCard(
                                  profile: vetProfile!,
                                  fallbackName: currentUser?.firstName,
                                )
                              : ProfileErrorPlaceholder(onRetry: _loadData),

                          const SizedBox(height: 16),

                          // Availability toggle
                          if (vetProfile != null) ...[
                            AvailabilityStatusCard(
                              isAvailable: vetProfile!.available,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Vet menu
                          ProfileMenuList(
                            menuItems: getProfileMenuItems(
                              context,
                              showSuccessToast: showSuccessToast,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Switch to farmer mode
                          SwitchModeCard(
                            targetMode: 'farmer',
                            onTap: _handleSwitchToFarmer,
                            isLoading: isSwitchingMode,
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
                      setLoading: setProfileLoading,
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
