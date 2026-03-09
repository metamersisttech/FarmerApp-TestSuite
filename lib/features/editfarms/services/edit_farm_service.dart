import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Result of edit/update farm operation
class EditFarmResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const EditFarmResult({
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory EditFarmResult.success(Map<String, dynamic> data) {
    return EditFarmResult(
      success: true,
      data: data,
    );
  }

  factory EditFarmResult.error(String message) {
    return EditFarmResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Service for edit farm: load farm by ID and PUT update
class EditFarmService {
  final BackendHelper _backendHelper;

  EditFarmService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get a single farm by ID for pre-fill
  Future<Map<String, dynamic>?> getFarmById(int farmId) async {
    try {
      return await _backendHelper.getFarmById(farmId);
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH update an existing farm
  /// Converts numeric values to strings as required by API
  Future<EditFarmResult> patchUpdateFarm(
    int farmId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Convert numeric values to strings for API
      final apiData = {
        'name': data['name'].toString(),
        'address': data['address'].toString(),
        // Convert numbers to strings
        if (data['area_sq_m'] != null)
          'area_sq_m': data['area_sq_m'].toString(),
        if (data['latitude'] != null)
          'latitude': data['latitude'].toString(),
        if (data['longitude'] != null)
          'longitude': data['longitude'].toString(),
      };

      final result = await _backendHelper.patchUpdateFarm(farmId, apiData);
      return EditFarmResult.success(result);
    } catch (e) {
      return EditFarmResult.error(e.toString());
    }
  }
}
