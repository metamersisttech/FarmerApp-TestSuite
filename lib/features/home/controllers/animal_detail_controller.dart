import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';
import 'package:flutter_app/features/home/services/animal_detail_service.dart';

/// Animal Detail Controller
///
/// Manages the state and business logic for the Animal Detail page.
/// Uses AnimalDetailService for data operations.
class AnimalDetailController extends BaseController {
  final AnimalDetailService _animalDetailService;

  AnimalDetailModel? _animalDetail;
  bool _isFavorite = false;

  /// Current animal detail data
  AnimalDetailModel? get animalDetail => _animalDetail;

  /// Whether the listing is favorited
  bool get isFavorite => _isFavorite;

  /// Check if data is loaded successfully
  bool get hasData => _animalDetail != null;

  /// Get listing ID
  int? get listingId => _animalDetail?.id;

  /// Get listing title
  String? get title => _animalDetail?.title;

  AnimalDetailController({AnimalDetailService? animalDetailService})
      : _animalDetailService = animalDetailService ?? AnimalDetailService();

  /// Fetch animal details from the API
  Future<void> fetchAnimalDetail(int listingId) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      debugPrint('[AnimalDetailController] Fetching listing $listingId...');

      _animalDetail = await _animalDetailService.fetchAnimalDetail(listingId);

      if (isDisposed) return;

      debugPrint('[AnimalDetailController] Loaded: ${_animalDetail?.title}');

      // Check favorite status
      await _checkFavoriteStatus(listingId);

      notifyListeners();
    } catch (e) {
      debugPrint('[AnimalDetailController] Error: $e');
      if (!isDisposed) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setError(errorMessage.isEmpty ? 'Failed to load listing details' : errorMessage);
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Check if listing is favorited
  Future<void> _checkFavoriteStatus(int listingId) async {
    try {
      _isFavorite = await _animalDetailService.isFavorited(listingId);
    } catch (e) {
      debugPrint('[AnimalDetailController] Error checking favorite status: $e');
      // Don't fail the whole load if favorite check fails
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (isDisposed || _animalDetail == null) return;

    final listingId = _animalDetail!.id;
    final previousState = _isFavorite;

    // Optimistic update
    _isFavorite = !_isFavorite;
    notifyListeners();

    try {
      if (_isFavorite) {
        await _animalDetailService.addToFavorites(listingId);
        debugPrint('[AnimalDetailController] Added to favorites: $listingId');
      } else {
        await _animalDetailService.removeFromFavorites(listingId);
        debugPrint('[AnimalDetailController] Removed from favorites: $listingId');
      }
    } catch (e) {
      // Revert on error
      _isFavorite = previousState;
      notifyListeners();
      
      debugPrint('[AnimalDetailController] Error toggling favorite: $e');
      if (!isDisposed) {
        setError('Failed to update favorite status');
      }
    }
  }

  /// Share the animal listing
  void shareAnimal() {
    if (_animalDetail == null) return;
    // TODO: Implement share functionality using share_plus package
    debugPrint('[AnimalDetailController] Share: ${_animalDetail?.title}');
  }

  /// Report the listing
  Future<void> reportListing(String reason) async {
    if (isDisposed || _animalDetail == null) return;

    try {
      await _animalDetailService.reportListing(_animalDetail!.id, reason);
      debugPrint('[AnimalDetailController] Reported listing: ${_animalDetail!.id}');
    } catch (e) {
      debugPrint('[AnimalDetailController] Error reporting listing: $e');
      if (!isDisposed) {
        setError('Failed to report listing');
      }
      rethrow;
    }
  }

  /// Contact seller
  Future<void> contactSeller(String message) async {
    if (isDisposed || _animalDetail == null) return;

    try {
      await _animalDetailService.contactSeller(_animalDetail!.id, message);
      debugPrint('[AnimalDetailController] Contacted seller for: ${_animalDetail!.id}');
    } catch (e) {
      debugPrint('[AnimalDetailController] Error contacting seller: $e');
      if (!isDisposed) {
        setError('Failed to contact seller');
      }
      rethrow;
    }
  }

  /// Refresh the animal details
  Future<void> refresh(int listingId) async {
    await fetchAnimalDetail(listingId);
  }
}

