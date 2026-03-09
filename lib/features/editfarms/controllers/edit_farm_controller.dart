import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/editfarms/services/edit_farm_service.dart';

/// Controller for edit farm: handles loading farm data and updating
class EditFarmController extends BaseController {
  final int farmId;
  final EditFarmService _editService;

  Map<String, dynamic>? _farmData;

  /// Current farm data
  Map<String, dynamic>? get farmData => _farmData;

  EditFarmController({
    required this.farmId,
    EditFarmService? editFarmService,
  }) : _editService = editFarmService ?? EditFarmService();

  /// Load farm by ID for pre-fill
  Future<Map<String, dynamic>?> loadFarm() async {
    setLoading(true);
    clearError();

    try {
      final data = await _editService.getFarmById(farmId);
      _farmData = data;
      setLoading(false);
      return data;
    } catch (e) {
      setError('Failed to load farm: ${e.toString()}');
      setLoading(false);
      return null;
    }
  }

  /// PATCH update farm with form data
  Future<EditFarmResult> updateFarm(Map<String, dynamic> formData) async {
    setLoading(true);
    clearError();

    final result = await _editService.patchUpdateFarm(farmId, formData);

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to update farm');
    } else {
      _farmData = result.data;
    }

    setLoading(false);
    return result;
  }
}
