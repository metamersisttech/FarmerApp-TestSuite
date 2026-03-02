import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/controllers/appointment_controller.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for My Appointments screen state management
mixin MyAppointmentsStateMixin<T extends StatefulWidget> on State<T> {
  final AppointmentController appointmentController = AppointmentController();

  bool get isLoading => appointmentController.isLoading;
  String? get errorMessage => appointmentController.errorMessage;
  List<AppointmentModel> get appointments =>
      appointmentController.appointments;
  String get selectedStatus => appointmentController.selectedStatus;

  /// Initialize and load appointments
  Future<void> initializeAppointments() async {
    appointmentController.addListener(_onControllerChange);
    await appointmentController.loadAppointments();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  /// Handle status filter change
  void handleStatusFilter(String status) {
    appointmentController.setStatusFilter(status);
  }

  /// Handle tapping on an appointment card
  void handleAppointmentTap(AppointmentModel appointment) {
    Navigator.pushNamed(
      context,
      AppRoutes.appointmentDetail,
      arguments: appointment.appointmentId,
    );
  }

  /// Handle cancel appointment
  Future<void> handleCancelAppointment(AppointmentModel appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text('Cancel Appointment?'),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.vet.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await appointmentController
          .cancelAppointment(appointment.appointmentId);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                appointmentController.errorMessage ?? 'Failed to cancel'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  /// Handle chat tap — navigate to chat screen
  void handleChatTap(AppointmentModel appointment) {
    if (!appointment.canChat) return;
    Navigator.pushNamed(
      context,
      AppRoutes.appointmentChat,
      arguments: appointment,
    );
  }

  /// Refresh appointments (for pull-to-refresh)
  Future<void> handleRefresh() async {
    await appointmentController.refreshAppointments();
  }

  /// Dispose controller
  void disposeAppointments() {
    appointmentController.removeListener(_onControllerChange);
    appointmentController.dispose();
  }
}
