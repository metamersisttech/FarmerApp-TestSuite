/// Transport Dashboard Controller
///
/// Manages dashboard state: availability, location, stats.
library;

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_provider_model.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/transport_dashboard_service.dart';
import 'package:flutter_app/features/transport/services/transport_profile_service.dart';

class TransportDashboardController extends BaseController {
  final TransportDashboardService _dashboardService;
  final TransportProfileService _profileService;

  TransportProviderModel? _profile;
  List<TransportRequestModel> _activeJobs = [];
  bool _isAvailable = false;
  int _activeJobsCount = 0;
  int _pendingRequestsCount = 0;
  int _completedTripsToday = 0;
  double _totalEarningsToday = 0.0;

  Timer? _locationUpdateTimer;
  static const Duration _locationUpdateInterval = Duration(minutes: 5);

  TransportProviderModel? get profile => _profile;
  List<TransportRequestModel> get activeJobs => _activeJobs;
  bool get isAvailable => _isAvailable;
  int get activeJobsCount => _activeJobsCount;
  int get pendingRequestsCount => _pendingRequestsCount;
  int get completedTripsToday => _completedTripsToday;
  double get totalEarningsToday => _totalEarningsToday;

  /// Check if has profile
  bool get hasProfile => _profile != null;

  /// Get formatted earnings
  String get formattedEarnings => '\u20B9${_totalEarningsToday.toStringAsFixed(0)}';

  TransportDashboardController({
    TransportDashboardService? dashboardService,
    TransportProfileService? profileService,
  })  : _dashboardService = dashboardService ?? TransportDashboardService(),
        _profileService = profileService ?? TransportProfileService();

  /// Initialize dashboard
  Future<void> initialize() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      // Load profile first
      await _loadProfile();

      if (isDisposed) return;

      // Load jobs and stats in parallel
      await Future.wait([
        _loadActiveJobs(),
        _loadStats(),
      ]);

      // Start location updates if available
      if (_isAvailable) {
        _startLocationUpdates();
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load dashboard: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Load profile
  Future<void> _loadProfile() async {
    final result = await _profileService.getMyProfile();
    if (result.success && result.profile != null) {
      _profile = result.profile;
      _isAvailable = result.profile!.available;
      notifyListeners();
    }
  }

  /// Load active jobs
  Future<void> _loadActiveJobs() async {
    final result = await _dashboardService.getMyActiveJobs();
    if (result.success && result.jobs != null) {
      _activeJobs = result.jobs!;
      _activeJobsCount = result.activeCount ?? 0;
      notifyListeners();
    }
  }

  /// Load dashboard stats
  Future<void> _loadStats() async {
    final result = await _dashboardService.getDashboardStats();
    if (result.success) {
      _pendingRequestsCount = result.pendingRequestsCount ?? 0;
      _completedTripsToday = result.completedTripsToday ?? 0;
      _totalEarningsToday = result.totalEarningsToday ?? 0.0;
      notifyListeners();
    }
  }

  /// Toggle availability
  Future<bool> toggleAvailability() async {
    if (isDisposed) return false;

    final newState = !_isAvailable;

    // If turning on, get location permission first
    if (newState) {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setError('Location permission required to go online');
        return false;
      }
    }

    // Optimistic update
    _isAvailable = newState;
    notifyListeners();

    try {
      final result = await _dashboardService.toggleAvailability(newState);

      if (isDisposed) return false;

      if (result.success) {
        _isAvailable = result.isAvailable ?? newState;

        // Start/stop location updates
        if (_isAvailable) {
          await _updateLocationNow();
          _startLocationUpdates();
        } else {
          _stopLocationUpdates();
        }

        notifyListeners();
        return true;
      } else {
        // Revert on failure
        _isAvailable = !newState;
        setError(result.errorMessage ?? 'Failed to update availability');
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Revert on error
      _isAvailable = !newState;
      if (!isDisposed) {
        setError('Failed to update availability: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Check location permission
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Update location now
  Future<void> _updateLocationNow() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (isDisposed) return;

      await _dashboardService.updateLocation(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      // Silently fail location updates
      // Don't want to show error for background location
    }
  }

  /// Start periodic location updates
  void _startLocationUpdates() {
    _stopLocationUpdates(); // Clear any existing timer

    _locationUpdateTimer = Timer.periodic(
      _locationUpdateInterval,
      (_) => _updateLocationNow(),
    );
  }

  /// Stop location updates
  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    if (isDisposed) return;

    clearError();

    try {
      await Future.wait([
        _loadProfile(),
        _loadActiveJobs(),
        _loadStats(),
      ]);
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to refresh dashboard: $e');
      }
    }
  }

  /// Reset state
  void reset() {
    _stopLocationUpdates();
    _profile = null;
    _activeJobs = [];
    _isAvailable = false;
    _activeJobsCount = 0;
    _pendingRequestsCount = 0;
    _completedTripsToday = 0;
    _totalEarningsToday = 0.0;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    super.dispose();
  }
}
