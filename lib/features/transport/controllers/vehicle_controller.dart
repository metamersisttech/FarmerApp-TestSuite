/// Vehicle Controller
///
/// Manages vehicle CRUD operations and state.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';
import 'package:flutter_app/features/transport/services/vehicle_service.dart';

class VehicleController extends BaseController {
  final VehicleService _vehicleService;

  List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;
  bool _isUploading = false;
  String? _rcDocumentKey;
  String? _insuranceDocumentKey;
  List<String> _vehicleImageKeys = [];

  List<VehicleModel> get vehicles => _vehicles;
  VehicleModel? get selectedVehicle => _selectedVehicle;
  bool get isUploading => _isUploading;
  String? get rcDocumentKey => _rcDocumentKey;
  String? get insuranceDocumentKey => _insuranceDocumentKey;
  List<String> get vehicleImageKeys => _vehicleImageKeys;

  /// Get active vehicles only
  List<VehicleModel> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();

  /// Check if has vehicles
  bool get hasVehicles => _vehicles.isNotEmpty;

  /// Get vehicle count
  int get vehicleCount => _vehicles.length;

  VehicleController({
    VehicleService? vehicleService,
  }) : _vehicleService = vehicleService ?? VehicleService();

  /// Load all vehicles
  Future<void> loadVehicles() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _vehicleService.getMyVehicles();

      if (isDisposed) return;

      if (result.success) {
        _vehicles = result.vehicles ?? [];
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

  /// Load a specific vehicle
  Future<void> loadVehicle(int vehicleId) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _vehicleService.getVehicleById(vehicleId);

      if (isDisposed) return;

      if (result.success) {
        _selectedVehicle = result.vehicle;
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load vehicle');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load vehicle: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Add new vehicle
  Future<bool> addVehicle({
    required String vehicleType,
    required String registrationNumber,
    required String make,
    required String model,
    int? year,
    required double maxWeightKg,
    double? maxLengthCm,
    double? maxWidthCm,
    double? maxHeightCm,
  }) async {
    if (isDisposed) return false;

    // Validate uploads
    if (_rcDocumentKey == null) {
      setError('Please upload vehicle RC document');
      return false;
    }
    if (_insuranceDocumentKey == null) {
      setError('Please upload vehicle insurance document');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final result = await _vehicleService.addVehicle(
        vehicleType: vehicleType,
        registrationNumber: registrationNumber,
        make: make,
        model: model,
        year: year,
        maxWeightKg: maxWeightKg,
        maxLengthCm: maxLengthCm,
        maxWidthCm: maxWidthCm,
        maxHeightCm: maxHeightCm,
        rcDocumentKey: _rcDocumentKey!,
        insuranceDocumentKey: _insuranceDocumentKey!,
        vehicleImageKeys: _vehicleImageKeys,
      );

      if (isDisposed) return false;

      if (result.success) {
        // Add to local list
        if (result.vehicle != null) {
          _vehicles.add(result.vehicle!);
        }
        clearUploadedFiles();
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to add vehicle');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to add vehicle: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Update vehicle
  Future<bool> updateVehicle({
    required int vehicleId,
    String? vehicleType,
    String? registrationNumber,
    String? make,
    String? model,
    int? year,
    double? maxWeightKg,
    double? maxLengthCm,
    double? maxWidthCm,
    double? maxHeightCm,
    bool? isActive,
  }) async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      final result = await _vehicleService.updateVehicle(
        vehicleId: vehicleId,
        vehicleType: vehicleType,
        registrationNumber: registrationNumber,
        make: make,
        model: model,
        year: year,
        maxWeightKg: maxWeightKg,
        maxLengthCm: maxLengthCm,
        maxWidthCm: maxWidthCm,
        maxHeightCm: maxHeightCm,
        rcDocumentKey: _rcDocumentKey,
        insuranceDocumentKey: _insuranceDocumentKey,
        vehicleImageKeys: _vehicleImageKeys.isNotEmpty ? _vehicleImageKeys : null,
        isActive: isActive,
      );

      if (isDisposed) return false;

      if (result.success) {
        // Update in local list
        if (result.vehicle != null) {
          final index = _vehicles.indexWhere((v) => v.vehicleId == vehicleId);
          if (index != -1) {
            _vehicles[index] = result.vehicle!;
          }
          _selectedVehicle = result.vehicle;
        }
        clearUploadedFiles();
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to update vehicle');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to update vehicle: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Toggle vehicle active status
  Future<bool> toggleVehicleActive(int vehicleId, bool isActive) async {
    if (isDisposed) return false;

    // Optimistic update
    final index = _vehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (index == -1) return false;

    final previousState = _vehicles[index].isActive;
    _vehicles[index] = _vehicles[index].copyWith(isActive: isActive);
    notifyListeners();

    try {
      final result = await _vehicleService.toggleVehicleActive(vehicleId, isActive);

      if (isDisposed) return false;

      if (result.success) {
        if (result.vehicle != null) {
          _vehicles[index] = result.vehicle!;
          notifyListeners();
        }
        return true;
      } else {
        // Revert on failure
        _vehicles[index] = _vehicles[index].copyWith(isActive: previousState);
        setError(result.errorMessage ?? 'Failed to update vehicle status');
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Revert on error
      _vehicles[index] = _vehicles[index].copyWith(isActive: previousState);
      if (!isDisposed) {
        setError('Failed to update vehicle status: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Delete vehicle
  Future<bool> deleteVehicle(int vehicleId) async {
    if (isDisposed) return false;

    setLoading(true);
    clearError();

    try {
      final result = await _vehicleService.deleteVehicle(vehicleId);

      if (isDisposed) return false;

      if (result.success) {
        _vehicles.removeWhere((v) => v.vehicleId == vehicleId);
        if (_selectedVehicle?.vehicleId == vehicleId) {
          _selectedVehicle = null;
        }
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to delete vehicle');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to delete vehicle: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Upload RC document
  Future<bool> uploadRcDocument(String filePath) async {
    if (isDisposed) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final key = await _vehicleService.uploadDocument(filePath);
      if (isDisposed) return false;

      if (key != null) {
        _rcDocumentKey = key;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        setError('Failed to upload RC document');
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to upload RC document: $e');
        _isUploading = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Upload insurance document
  Future<bool> uploadInsuranceDocument(String filePath) async {
    if (isDisposed) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final key = await _vehicleService.uploadDocument(filePath);
      if (isDisposed) return false;

      if (key != null) {
        _insuranceDocumentKey = key;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        setError('Failed to upload insurance document');
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to upload insurance document: $e');
        _isUploading = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Upload vehicle images
  Future<bool> uploadVehicleImages(List<String> filePaths) async {
    if (isDisposed) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final keys = await _vehicleService.uploadVehicleImages(filePaths);
      if (isDisposed) return false;

      _vehicleImageKeys = keys;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to upload vehicle images: $e');
        _isUploading = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Clear uploaded files
  void clearUploadedFiles() {
    _rcDocumentKey = null;
    _insuranceDocumentKey = null;
    _vehicleImageKeys = [];
    notifyListeners();
  }

  /// Select a vehicle
  void selectVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  /// Clear selected vehicle
  void clearSelectedVehicle() {
    _selectedVehicle = null;
    notifyListeners();
  }

  /// Refresh vehicles
  Future<void> refreshVehicles() async {
    await loadVehicles();
  }

  /// Reset state
  void reset() {
    _vehicles = [];
    _selectedVehicle = null;
    clearUploadedFiles();
    clearError();
    notifyListeners();
  }
}
