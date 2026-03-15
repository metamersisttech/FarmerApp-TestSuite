/// Vehicle Service
///
/// Handles vehicle CRUD operations for transport providers.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class VehicleService {
  final BackendHelper _backendHelper;

  VehicleService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get all vehicles for current provider
  Future<VehicleListResult> getMyVehicles() async {
    try {
      final response = await _backendHelper.getTransportVehicles();
      final vehicles = response
          .whereType<Map<String, dynamic>>()
          .map((v) => VehicleModel.fromJson(v))
          .toList();
      return VehicleListResult.successful(vehicles);
    } on BackendException catch (e) {
      return VehicleListResult.failed(e.message);
    } catch (e) {
      return VehicleListResult.failed('Failed to load vehicles: $e');
    }
  }

  /// Get a specific vehicle
  Future<VehicleResult> getVehicleById(int vehicleId) async {
    try {
      final response = await _backendHelper.getTransportVehicleById(vehicleId);
      final vehicle = VehicleModel.fromJson(response);
      return VehicleResult.successful(vehicle);
    } on BackendException catch (e) {
      return VehicleResult.failed(e.message);
    } catch (e) {
      return VehicleResult.failed('Failed to load vehicle: $e');
    }
  }

  /// Add a new vehicle
  Future<VehicleResult> addVehicle({
    required String vehicleType,
    required String registrationNumber,
    required String make,
    required String model,
    int? year,
    required double maxWeightKg,
    double? maxLengthCm,
    double? maxWidthCm,
    double? maxHeightCm,
    required String rcDocumentKey,
    required String insuranceDocumentKey,
    List<String> vehicleImageKeys = const [],
  }) async {
    try {
      final data = {
        'vehicle_type': vehicleType,
        'registration_number': registrationNumber,
        'make': make,
        'model': model,
        if (year != null) 'year': year,
        'max_weight_kg': maxWeightKg,
        if (maxLengthCm != null) 'max_length_cm': maxLengthCm,
        if (maxWidthCm != null) 'max_width_cm': maxWidthCm,
        if (maxHeightCm != null) 'max_height_cm': maxHeightCm,
        'rc_document': rcDocumentKey,
        'insurance_document': insuranceDocumentKey,
        'vehicle_images': vehicleImageKeys,
      };

      final response = await _backendHelper.postTransportVehicle(data);
      final vehicle = VehicleModel.fromJson(response);
      return VehicleResult.successful(vehicle);
    } on BackendException catch (e) {
      return VehicleResult.failed(e.message);
    } catch (e) {
      return VehicleResult.failed('Failed to add vehicle: $e');
    }
  }

  /// Update a vehicle
  Future<VehicleResult> updateVehicle({
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
    String? rcDocumentKey,
    String? insuranceDocumentKey,
    List<String>? vehicleImageKeys,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (vehicleType != null) data['vehicle_type'] = vehicleType;
      if (registrationNumber != null) data['registration_number'] = registrationNumber;
      if (make != null) data['make'] = make;
      if (model != null) data['model'] = model;
      if (year != null) data['year'] = year;
      if (maxWeightKg != null) data['max_weight_kg'] = maxWeightKg;
      if (maxLengthCm != null) data['max_length_cm'] = maxLengthCm;
      if (maxWidthCm != null) data['max_width_cm'] = maxWidthCm;
      if (maxHeightCm != null) data['max_height_cm'] = maxHeightCm;
      if (rcDocumentKey != null) data['rc_document'] = rcDocumentKey;
      if (insuranceDocumentKey != null) data['insurance_document'] = insuranceDocumentKey;
      if (vehicleImageKeys != null) data['vehicle_images'] = vehicleImageKeys;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _backendHelper.patchTransportVehicle(vehicleId, data);
      final vehicle = VehicleModel.fromJson(response);
      return VehicleResult.successful(vehicle);
    } on BackendException catch (e) {
      return VehicleResult.failed(e.message);
    } catch (e) {
      return VehicleResult.failed('Failed to update vehicle: $e');
    }
  }

  /// Toggle vehicle active status
  Future<VehicleResult> toggleVehicleActive(int vehicleId, bool isActive) async {
    return updateVehicle(vehicleId: vehicleId, isActive: isActive);
  }

  /// Delete a vehicle
  Future<DeleteResult> deleteVehicle(int vehicleId) async {
    try {
      await _backendHelper.deleteTransportVehicle(vehicleId);
      return DeleteResult.successful();
    } on BackendException catch (e) {
      return DeleteResult.failed(e.message);
    } catch (e) {
      return DeleteResult.failed('Failed to delete vehicle: $e');
    }
  }

  /// Upload vehicle document
  Future<String?> uploadDocument(String filePath) async {
    try {
      final response = await _backendHelper.postUploadFile(filePath, 'documents');
      return response['key'] as String?;
    } on BackendException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Upload vehicle images
  Future<List<String>> uploadVehicleImages(List<String> filePaths) async {
    try {
      final responses = await _backendHelper.postUploadMultipleFiles(
        filePaths,
        'listings',
      );
      return responses.map((r) => r['key'] as String).toList();
    } on BackendException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }
}
