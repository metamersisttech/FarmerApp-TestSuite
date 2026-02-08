import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Mixin for RejectAppointmentScreen state management
mixin RejectAppointmentStateMixin<T extends StatefulWidget> on State<T> {
  final AppointmentService _service = AppointmentService();
  final TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late AppointmentModel appointment;
  bool isSubmitting = false;

  /// Quick-select reason chips
  static const List<String> quickReasons = [
    'Fully booked',
    'Outside service area',
    'Not my specialization',
    'Emergency only this week',
  ];

  void initializeRejection(AppointmentModel appt) {
    appointment = appt;
  }

  /// Tapping a chip fills the text field
  void onQuickReasonTap(String reason) {
    if (!mounted) return;
    reasonController.text = reason;
    setState(() {});
  }

  /// Validate and submit
  Future<void> submitRejection() async {
    if (!formKey.currentState!.validate() || isSubmitting || !mounted) return;

    setState(() => isSubmitting = true);

    try {
      final result = await _service.rejectAppointment(
        appointmentId: appointment.appointmentId,
        rejectionReason: reasonController.text.trim(),
      );

      if (!mounted) return;
      setState(() => isSubmitting = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Appointment rejected.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to reject.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to reject appointment.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void handleBack() => Navigator.of(context).pop();

  void disposeRejection() {
    reasonController.dispose();
  }
}
