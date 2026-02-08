import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';

/// Controller for managing user's appointments list
class AppointmentController extends BaseController {
  final AppointmentService _service = AppointmentService();

  List<AppointmentModel> _appointments = [];
  String _selectedStatus = 'All';

  /// All loaded appointments
  List<AppointmentModel> get appointments => _appointments;

  /// Currently selected status filter
  String get selectedStatus => _selectedStatus;

  /// Status filter options
  static const List<String> statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Rejected',
    'Cancelled',
  ];

  /// Map display status to API status value
  static String? _statusToApiValue(String displayStatus) {
    switch (displayStatus) {
      case 'All':
        return null;
      case 'Pending':
        return 'REQUESTED';
      case 'Confirmed':
        return 'CONFIRMED';
      case 'Completed':
        return 'COMPLETED';
      case 'Rejected':
        return 'REJECTED';
      case 'Cancelled':
        return 'CANCELLED';
      default:
        return null;
    }
  }

  /// Load appointments (optionally filtered by status)
  Future<void> loadAppointments({String? status}) async {
    await executeAsync(() async {
      final apiStatus = status != null
          ? _statusToApiValue(status)
          : _statusToApiValue(_selectedStatus);

      final result = await _service.getAppointments(status: apiStatus);

      if (result.success && result.appointments != null) {
        _appointments = result.appointments!;
      } else {
        throw Exception(result.message ?? 'Failed to load appointments');
      }
      return _appointments;
    }, errorMessage: 'Failed to load appointments');
  }

  /// Set status filter and reload
  void setStatusFilter(String status) {
    if (isDisposed) return;
    _selectedStatus = status;
    notifyListeners();
    loadAppointments(status: status);
  }

  /// Cancel an appointment
  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      final result = await _service.cancelAppointment(appointmentId);
      if (result.success) {
        // Refresh list after cancel
        await loadAppointments();
        return true;
      }
      setError(result.message ?? 'Failed to cancel appointment');
      return false;
    } catch (e) {
      setError('Failed to cancel appointment');
      return false;
    }
  }

  /// Refresh appointments
  Future<void> refreshAppointments() async {
    await loadAppointments();
  }
}
