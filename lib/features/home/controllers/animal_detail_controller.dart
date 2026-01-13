import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';

/// Animal Detail Controller
///
/// Manages the state and business logic for the Animal Detail page.
/// Fetches listing details from the API and handles favorite/share actions.
class AnimalDetailController extends BaseController {
  final BackendHelper _backendHelper;

  AnimalDetailModel? _animalDetail;
  bool _isFavorite = false;

  /// Current animal detail data
  AnimalDetailModel? get animalDetail => _animalDetail;

  /// Whether the listing is favorited
  bool get isFavorite => _isFavorite;

  /// Check if data is loaded successfully
  bool get hasData => _animalDetail != null;

  AnimalDetailController({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Fetch animal details from the API
  Future<void> fetchAnimalDetail(int listingId) async {
    if (isDisposed) return;

    try {
      setLoading(true);
      clearError();

      debugPrint('[AnimalDetailController] Fetching listing $listingId...');

      final response = await _backendHelper.getListingById(listingId);

      if (isDisposed) return;

      debugPrint('[AnimalDetailController] Response: $response');

      _animalDetail = AnimalDetailModel.fromJson(response);

      debugPrint('[AnimalDetailController] Parsed: ${_animalDetail?.title}');

      notifyListeners();
    } catch (e) {
      debugPrint('[AnimalDetailController] Error: $e');
      if (!isDisposed) {
        setError(e.toString());
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Toggle favorite status
  void toggleFavorite() {
    if (isDisposed) return;
    _isFavorite = !_isFavorite;
    notifyListeners();
    // TODO: Implement API call to save favorite status
    debugPrint('[AnimalDetailController] Favorite toggled: $_isFavorite');
  }

  /// Share the animal listing
  void shareAnimal() {
    if (_animalDetail == null) return;
    // TODO: Implement share functionality
    debugPrint('[AnimalDetailController] Share: ${_animalDetail?.title}');
  }

  /// Refresh the animal details
  Future<void> refresh(int listingId) async {
    await fetchAnimalDetail(listingId);
  }
}
