import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';

/// Controller for vet-side appointment management
class VetAppointmentController extends BaseController {
  final AppointmentService _service = AppointmentService();

  List<AppointmentModel> _appointments = [];
  String _selectedStatus = 'New';

  List<AppointmentModel> get appointments => _appointments;
  String get selectedStatus => _selectedStatus;

  /// Status filter options for vet dashboard
  static const List<String> statusFilters = [
    'New',
    'Confirmed',
    'Completed',
    'Rejected',
  ];

  /// Map display label to API status value
  static String? _statusToApiValue(String displayStatus) {
    switch (displayStatus) {
      case 'New':
        return 'REQUESTED';
      case 'Confirmed':
        return 'CONFIRMED';
      case 'Completed':
        return 'COMPLETED';
      case 'Rejected':
        return 'REJECTED';
      default:
        return null;
    }
  }

  /// Load vet appointments with current filter
  Future<void> loadAppointments({String? status}) async {
    await executeAsync(() async {
      final apiStatus = status != null
          ? _statusToApiValue(status)
          : _statusToApiValue(_selectedStatus);

      final result = await _service.getVetAppointments(status: apiStatus);

      if (result.success && result.appointments != null) {
        _appointments = result.appointments!;
      } else {
        throw Exception(result.message ?? 'Failed to load appointments');
      }
      return _appointments;
    }, errorMessage: 'Failed to load appointment requests');
  }

  /// Change status filter and reload
  void setStatusFilter(String status) {
    if (isDisposed) return;
    _selectedStatus = status;
    notifyListeners();
    loadAppointments(status: status);
  }

  /// Refresh list
  Future<void> refreshAppointments() async {
    await loadAppointments();
  }
}
