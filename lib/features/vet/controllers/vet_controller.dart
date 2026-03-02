import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/services/vet_service.dart';

/// Controller for Vet Services feature
/// Handles business logic for vet listing, search, filtering, and pagination
class VetController extends BaseController {
  final VetService _vetService = VetService();

  List<VetModel> _vets = [];
  String _selectedBreed = 'All';
  String _searchQuery = '';
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  /// All loaded vets
  List<VetModel> get vets => _vets;

  /// Currently selected breed filter
  String get selectedBreed => _selectedBreed;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Available breeds for filtering
  List<String> get breeds => VetService.breeds;

  /// Whether more pages are available
  bool get hasMore => _hasMore;

  /// Whether currently loading more pages
  bool get isLoadingMore => _isLoadingMore;

  /// Filtered vets based on search query
  List<VetModel> get filteredVets {
    List<VetModel> result = _vets;

    // Apply search filter (client-side)
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      result = result.where((vet) {
        return vet.name.toLowerCase().contains(lowerQuery) ||
            vet.specialization.toLowerCase().contains(lowerQuery) ||
            (vet.clinicName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    return result;
  }

  /// Load first page of vets
  Future<void> loadVets() async {
    _currentPage = 1;
    _hasMore = true;

    await executeAsync(() async {
      final result = await _vetService.getVets(
        page: _currentPage,
        specialization: _selectedBreed != 'All' ? _selectedBreed : null,
      );

      if (result.success && result.vets != null) {
        _vets = result.vets!;
        _hasMore = result.nextPageUrl != null;
      } else {
        throw Exception(result.message ?? 'Failed to load vets');
      }
      return _vets;
    }, errorMessage: 'Failed to load vets');
  }

  /// Load next page (for infinite scroll)
  Future<void> loadMoreVets() async {
    if (isDisposed || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _vetService.getVets(
        page: _currentPage,
        specialization: _selectedBreed != 'All' ? _selectedBreed : null,
      );

      if (isDisposed) return;

      if (result.success && result.vets != null) {
        _vets.addAll(result.vets!);
        _hasMore = result.nextPageUrl != null;
      } else {
        _currentPage--; // revert page on failure
      }
    } catch (_) {
      _currentPage--;
    }

    _isLoadingMore = false;
    if (!isDisposed) notifyListeners();
  }

  /// Refresh (pull-to-refresh)
  Future<void> refreshVets() async {
    await loadVets();
  }

  /// Update selected breed filter
  void setSelectedBreed(String breed) {
    if (isDisposed) return;
    _selectedBreed = breed;
    notifyListeners();
    // Reload from API with new filter
    loadVets();
  }

  /// Update search query (client-side filtering)
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
