import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/controllers/appointment_controller.dart';
import 'package:flutter_app/features/appointment/mixins/my_appointments_state_mixin.dart';
import 'package:flutter_app/features/appointment/widgets/appointment_card.dart';
import 'package:flutter_app/features/appointment/widgets/appointment_status_chips.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// My Appointments Screen
///
/// Shows the farmer's appointment list with status filter chips,
/// pull-to-refresh, and action buttons per appointment.
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with MyAppointmentsStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeAppointments();
    });
  }

  @override
  void dispose() {
    disposeAppointments();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8),
            child: AppointmentStatusChips(
              statuses: AppointmentController.statusFilters,
              selectedStatus: selectedStatus,
              onSelected: handleStatusFilter,
            ),
          ),
          // Appointments list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return AppointmentCard(
            appointment: appointment,
            onTap: () => handleAppointmentTap(appointment),
            onCancelTap: appointment.canCancel
                ? () => handleCancelAppointment(appointment)
                : null,
            onChatTap: appointment.canChat
                ? () => handleChatTap(appointment)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedStatus == 'All'
                  ? 'You haven\'t booked any appointments yet.'
                  : 'No ${selectedStatus.toLowerCase()} appointments found.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('my_appointments_retry_btn'),
              onPressed: handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
