import 'package:flutter/material.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Mixin for CompleteAppointmentScreen state management
mixin CompleteAppointmentStateMixin<T extends StatefulWidget> on State<T> {
  final AppointmentService _service = AppointmentService();
  final TextEditingController prescriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late AppointmentModel appointment;
  bool isSubmitting = false;

  void initializeCompletion(AppointmentModel appt) {
    appointment = appt;
  }

  /// Validate and submit
  Future<void> submitCompletion() async {
    if (!formKey.currentState!.validate() || isSubmitting || !mounted) return;

    setState(() => isSubmitting = true);

    try {
      final result = await _service.completeAppointment(
        appointmentId: appointment.appointmentId,
        prescription: prescriptionController.text.trim(),
        completionNotes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => isSubmitting = false);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Appointment completed.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to complete.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to complete appointment.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  void handleBack() => Navigator.of(context).pop();

  void disposeCompletion() {
    prescriptionController.dispose();
    notesController.dispose();
  }
}
