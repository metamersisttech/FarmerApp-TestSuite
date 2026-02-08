import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/services/appointment_service.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';
import 'package:flutter_app/features/vet/services/vet_profile_service.dart';

/// Controller for the vet dashboard home screen.
/// Fetches vet profile, appointment counts, and today's appointments.
class VetDashboardController extends BaseController {
  final AppointmentService _appointmentService = AppointmentService();
  final VetProfileService _profileService = VetProfileService();

  VetProfileModel? _vetProfile;
  List<AppointmentModel> _todayAppointments = [];
  Map<String, int> _appointmentCounts = {};

  VetProfileModel? get vetProfile => _vetProfile;
  List<AppointmentModel> get todayAppointments => _todayAppointments;
  Map<String, int> get appointmentCounts => _appointmentCounts;

  int get pendingCount => _appointmentCounts['pending'] ?? 0;
  int get confirmedCount => _appointmentCounts['confirmed'] ?? 0;
  int get completedCount => _appointmentCounts['completed'] ?? 0;

  /// Load all dashboard data
  Future<void> loadDashboard() async {
    setLoading(true);
    setError(null);

    try {
      await Future.wait([
        _loadVetProfile(),
        _loadAppointments(),
      ]);
    } catch (e) {
      debugPrint('Error loading vet dashboard: $e');
      setError('Failed to load dashboard');
    }

    setLoading(false);
    notifyListeners();
  }

  Future<void> _loadVetProfile() async {
    final result = await _profileService.getVetProfile();
    if (result.success && result.profile != null) {
      _vetProfile = result.profile;
    }
  }

  Future<void> _loadAppointments() async {
    final requested = await _appointmentService.getVetAppointments(status: 'REQUESTED');
    final confirmed = await _appointmentService.getVetAppointments(status: 'CONFIRMED');
    final completed = await _appointmentService.getVetAppointments(status: 'COMPLETED');

    _appointmentCounts = {
      'pending': requested.appointments?.length ?? 0,
      'confirmed': confirmed.appointments?.length ?? 0,
      'completed': completed.appointments?.length ?? 0,
    };

    // Today's appointments = confirmed ones (most relevant for dashboard)
    _todayAppointments = confirmed.appointments ?? [];
  }
}
