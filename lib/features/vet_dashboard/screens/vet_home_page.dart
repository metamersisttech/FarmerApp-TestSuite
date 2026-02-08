import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_app/features/vet_dashboard/mixins/vet_dashboard_state_mixin.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/today_appointments_section.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/vet_profile_header_section.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/vet_quick_actions_section.dart';
import 'package:flutter_app/features/vet_dashboard/widgets/vet_stats_section.dart';

/// Vet Dashboard Home Page
///
/// Main screen for vets after switching to vet mode.
/// Mirrors the farmer home page layout with vet-specific content.
class VetHomePage extends StatefulWidget {
  const VetHomePage({super.key});

  @override
  State<VetHomePage> createState() => _VetHomePageState();
}

class _VetHomePageState extends State<VetHomePage>
    with ToastMixin, VetDashboardStateMixin {
  @override
  void initState() {
    super.initState();
    initializeDashboardController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDashboardData();
      loadUserFromStorage();
    });
  }

  @override
  void dispose() {
    disposeDashboardController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vetProfile = dashboardController.vetProfile;
    final displayName = vetProfile?.displayName ??
        currentUser?.firstName ??
        currentUser?.username ??
        'Vet';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            VetProfileHeaderSection(
              displayName: displayName,
              clinicName: vetProfile?.clinicName,
              isAvailable: vetProfile?.available ?? true,
              onNotificationTap: handleNotificationTap,
              onProfileTap: handleProfileTap,
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Stats Cards
                      VetStatsSection(
                        pendingCount: dashboardController.pendingCount,
                        confirmedCount: dashboardController.confirmedCount,
                        completedCount: dashboardController.completedCount,
                      ),

                      const SizedBox(height: 8),

                      // Quick Actions
                      VetQuickActionsSection(
                        onAppointmentsTap: () {
                          Navigator.pushNamed(context, '/vet-appointments');
                        },
                        onAvailabilityTap: () {
                          Navigator.pushNamed(context, '/vet-availability');
                        },
                        onPricingTap: () {
                          Navigator.pushNamed(context, '/vet-pricing');
                        },
                        onProfileTap: () {
                          Navigator.pushNamed(context, '/vet-profile');
                        },
                      ),

                      const SizedBox(height: 8),

                      // Today's Appointments
                      TodayAppointmentsSection(
                        appointments: dashboardController.todayAppointments,
                        isLoading: dashboardController.isLoading,
                        onViewAllTap: handleViewAllAppointments,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentBottomNavIndex,
        onTap: handleBottomNavTap,
      ),
    );
  }
}
