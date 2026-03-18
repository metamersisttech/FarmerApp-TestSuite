/// Accept Request Controller
///
/// Manages request acceptance flow with vehicle selection.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';
import 'package:flutter_app/features/transport/services/transport_request_service.dart';
import 'package:flutter_app/features/transport/services/vehicle_service.dart';

class AcceptRequestController extends BaseController {
  final TransportRequestService _requestService;
  final VehicleService _vehicleService;

  TransportRequestModel? _request;
  List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;
  bool _isAccepting = false;

  TransportRequestModel? get request => _request;
  List<VehicleModel> get vehicles => _vehicles;
  VehicleModel? get selectedVehicle => _selectedVehicle;
  bool get isAccepting => _isAccepting;

  /// Get active vehicles only
  List<VehicleModel> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();

  /// Check if has active vehicles
  bool get hasActiveVehicles => activeVehicles.isNotEmpty;

  /// Check if vehicle is selected
  bool get hasSelectedVehicle => _selectedVehicle != null;

  /// Check if selected vehicle has enough capacity
  bool get isVehicleCapacitySufficient {
    if (_selectedVehicle == null || _request == null) return false;
    return _selectedVehicle!.maxWeightKg >= _request!.estimatedWeightKg;
  }

  /// Get capacity warning message
  String? get capacityWarning {
    if (_selectedVehicle == null || _request == null) return null;
    if (_selectedVehicle!.maxWeightKg < _request!.estimatedWeightKg) {
      return 'Warning: Vehicle capacity (${_selectedVehicle!.formattedMaxWeight}) is less than estimated cargo weight (${_request!.formattedWeight})';
    }
    return null;
  }

  AcceptRequestController({
    TransportRequestService? requestService,
    VehicleService? vehicleService,
  })  : _requestService = requestService ?? TransportRequestService(),
        _vehicleService = vehicleService ?? VehicleService();

  /// Initialize with request
  void setRequest(TransportRequestModel request) {
    _request = request;
    notifyListeners();
  }

  /// Load vehicles
  Future<void> loadVehicles() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _vehicleService.getMyVehicles();

      if (isDisposed) return;

      if (result.success) {
        _vehicles = result.vehicles ?? [];

        // Auto-select if only one active vehicle
        final active = activeVehicles;
        if (active.length == 1) {
          _selectedVehicle = active.first;
        }

        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load vehicles');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load vehicles: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Select a vehicle
  void selectVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    clearError();
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedVehicle = null;
    notifyListeners();
  }

  /// Accept request with selected vehicle
  Future<TransportRequestModel?> acceptRequest() async {
    if (isDisposed) return null;

    if (_request == null) {
      setError('No request to accept');
      return null;
    }

    if (_selectedVehicle == null) {
      setError('Please select a vehicle');
      return null;
    }

    _isAccepting = true;
    clearError();
    notifyListeners();

    try {
      final result = await _requestService.acceptRequest(
        _request!.requestId,
        _selectedVehicle!.vehicleId,
      );

      if (isDisposed) return null;

      _isAccepting = false;

      if (result.success) {
        _request = result.request;
        notifyListeners();
        return result.request;
      } else {
        setError(result.errorMessage ?? 'Failed to accept request');
        notifyListeners();
        return null;
      }
    } catch (e) {
      if (!isDisposed) {
        _isAccepting = false;
        setError('Failed to accept request: $e');
        notifyListeners();
      }
      return null;
    }
  }

  /// Reset state
  void reset() {
    _request = null;
    _vehicles = [];
    _selectedVehicle = null;
    _isAccepting = false;
    clearError();
    notifyListeners();
  }
}
