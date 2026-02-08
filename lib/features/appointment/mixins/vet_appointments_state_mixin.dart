import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/appointment/controllers/vet_appointment_controller.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Mixin for VetAppointmentsScreen state management
mixin VetAppointmentsStateMixin<T extends StatefulWidget> on State<T> {
  final VetAppointmentController vetAppointmentController =
      VetAppointmentController();

  int? _vetId;

  bool get isLoading => vetAppointmentController.isLoading;
  String? get errorMessage => vetAppointmentController.errorMessage;
  List<AppointmentModel> get appointments =>
      vetAppointmentController.appointments;
  String get selectedStatus => vetAppointmentController.selectedStatus;

  /// Initialize: load vet profile (for vetId) and appointments
  Future<void> initializeVetAppointments() async {
    vetAppointmentController.addListener(_onControllerChange);
    await _loadVetId();
    await vetAppointmentController.loadAppointments();
  }

  /// Load vet's own profile to get vet_id for slot endpoint
  Future<void> _loadVetId() async {
    try {
      final commonHelper = CommonHelper();
      final token = await commonHelper.getAccessToken();
      if (token != null) APIClient().setAuthorization(token);
      final profile = await BackendHelper().getVetProfile();
      _vetId = profile['vet_id'] as int?;
    } catch (_) {
      // Non-fatal: approve flow will fail gracefully if vetId is null
    }
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  /// Handle status filter change
  void handleStatusFilter(String status) {
    vetAppointmentController.setStatusFilter(status);
  }

  /// Navigate to Approve screen
  void handleApproveTap(AppointmentModel appointment) {
    if (_vetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to load vet profile. Please try again.'),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.vetApproveAppointment,
      arguments: {'appointment': appointment, 'vetId': _vetId},
    ).then((_) {
      vetAppointmentController.refreshAppointments();
    });
  }

  /// Navigate to Reject screen
  void handleRejectTap(AppointmentModel appointment) {
    Navigator.pushNamed(
      context,
      AppRoutes.vetRejectAppointment,
      arguments: appointment,
    ).then((_) {
      vetAppointmentController.refreshAppointments();
    });
  }

  /// Chat placeholder
  void handleChatTap(AppointmentModel appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Opening chat with ${appointment.requestor?.name ?? "user"}...'),
        backgroundColor: const Color(0xFF3B9B59),
      ),
    );
  }

  /// Navigate to Complete screen
  void handleCompleteTap(AppointmentModel appointment) {
    Navigator.pushNamed(
      context,
      AppRoutes.vetCompleteAppointment,
      arguments: appointment,
    ).then((_) {
      vetAppointmentController.refreshAppointments();
    });
  }

  /// Pull-to-refresh
  Future<void> handleRefresh() async {
    await vetAppointmentController.refreshAppointments();
  }

  /// Dispose controller
  void disposeVetAppointments() {
    vetAppointmentController.removeListener(_onControllerChange);
    vetAppointmentController.dispose();
  }
}
