import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/services/vet_service.dart';

/// Controller for Vet Services feature
/// Handles business logic for vet listing, search, and filtering
class VetController extends BaseController {
  final VetService _vetService = VetService();

  List<VetModel> _vets = [];
  String _selectedBreed = 'All';
  String _searchQuery = '';

  /// All loaded vets
  List<VetModel> get vets => _vets;

  /// Currently selected breed filter
  String get selectedBreed => _selectedBreed;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Available breeds for filtering
  List<String> get breeds => VetService.breeds;

  /// Filtered vets based on search query and breed selection
  List<VetModel> get filteredVets {
    List<VetModel> result = _vets;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      result = result.where((vet) {
        return vet.name.toLowerCase().contains(lowerQuery) ||
            vet.specialization.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return result;
  }

  /// Load vets from service
  Future<void> loadVets() async {
    await executeAsync(() async {
      _vets = await _vetService.getVets();
      return _vets;
    }, errorMessage: 'Failed to load vets');
  }

  /// Update selected breed filter
  void setSelectedBreed(String breed) {
    if (isDisposed) return;
    _selectedBreed = breed;
    notifyListeners();
  }

  /// Update search query
  void searchVets(String query) {
    if (isDisposed) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    if (isDisposed) return;
    _searchQuery = '';
    notifyListeners();
  }
}
