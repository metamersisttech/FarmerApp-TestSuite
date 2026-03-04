import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
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
    debugPrint('[VetHomePage] initState called');
    initializeDashboardController();
    
    // Load user data immediately to show correct name
    loadUserFromStorage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDashboardData();
      fetchNotificationUnreadCount();
    });
  }

  @override
  void dispose() {
    disposeDashboardController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            VetProfileHeaderSection(
              displayName: getDisplayName(),
              clinicName: dashboardController.vetProfile?.clinicName,
              isAvailable: dashboardController.vetProfile?.available ?? true,
              onNotificationTap: handleNotificationTap,
              onProfileTap: handleProfileTap,
              notificationCount: notificationUnreadCount,
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
                        onAppointmentsTap: handleAppointmentsTap,
                        onAvailabilityTap: handleAvailabilityTap,
                        onPricingTap: handlePricingTap,
                        onProfileTap: handleVetProfileTap,
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
    );
  }
}
