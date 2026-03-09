import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/features/postlistings/details/services/details_service.dart';

/// Controller for details page operations
class DetailsController extends BaseController {
  final DetailsService _detailsService;

  DetailsController({DetailsService? detailsService})
      : _detailsService = detailsService ?? DetailsService();

  // Form state
  List<AnimalModel> _allAnimalModels = [];
  List<String> _allAnimals = [];
  List<String> _allBreeds = [];
  List<Map<String, dynamic>> _farms = [];

  String? _selectedAnimalType;
  String? _selectedBreed;
  int? _selectedAnimalId;
  int? _selectedFarmId;

  bool _isLoadingAnimals = false;
  bool _isLoadingBreeds = false;
  bool _isLoadingFarms = false;

  // Getters
  List<AnimalModel> get allAnimalModels => _allAnimalModels;
  List<String> get allAnimals => _allAnimals;
  List<String> get allBreeds => _allBreeds;
  List<Map<String, dynamic>> get farms => _farms;

  String? get selectedAnimalType => _selectedAnimalType;
  String? get selectedBreed => _selectedBreed;
  int? get selectedAnimalId => _selectedAnimalId;
  int? get selectedFarmId => _selectedFarmId;

  bool get isLoadingAnimals => _isLoadingAnimals;
  bool get isLoadingBreeds => _isLoadingBreeds;
  bool get isLoadingFarms => _isLoadingFarms;

  /// Fetch animals and species list
  Future<void> fetchAnimals() async {
    _isLoadingAnimals = true;
    notifyListeners();

    final result = await _detailsService.getAnimals();

    if (result.success && result.animals != null && result.speciesList != null) {
      _allAnimalModels = result.animals!;
      _allAnimals = result.speciesList!;
    } else {
      setError(result.error ?? 'Failed to fetch animals');
    }

    _isLoadingAnimals = false;
    notifyListeners();
  }

  /// Fetch breeds for selected species
  Future<void> fetchBreedsForSpecies(String species) async {
    _isLoadingBreeds = true;
    notifyListeners();

    final result = await _detailsService.getBreedsForSpecies(species);

    if (result.success && result.breeds != null) {
      _allBreeds = result.breeds!;
      // Clear breed selection when species changes
      _selectedBreed = null;
    } else {
      setError(result.error ?? 'Failed to fetch breeds');
    }

    _isLoadingBreeds = false;
    notifyListeners();
  }

  /// Fetch user's farms
  Future<void> fetchFarms() async {
    _isLoadingFarms = true;
    notifyListeners();

    final result = await _detailsService.getFarms();

    if (result.success && result.farms != null) {
      _farms = result.farms!;
    } else {
      setError(result.error ?? 'Failed to fetch farms');
    }

    _isLoadingFarms = false;
    notifyListeners();
  }

  /// Set selected animal type
  void setSelectedAnimalType(String? animalType) {
    _selectedAnimalType = animalType;
    notifyListeners();
  }

  /// Set selected breed
  void setSelectedBreed(String? breed) {
    _selectedBreed = breed;
    notifyListeners();
  }

  /// Set selected animal ID
  void setSelectedAnimalId(int? animalId) {
    _selectedAnimalId = animalId;
    notifyListeners();
  }

  /// Set selected farm ID
  void setSelectedFarmId(int? farmId) {
    _selectedFarmId = farmId;
    notifyListeners();
  }

  /// Create listing with form data
  Future<DetailsResult> createListing(Map<String, dynamic> formData) async {
    setLoading(true);
    clearError();

    final result = await _detailsService.postCreateListing(formData);

    if (!result.success) {
      setError(result.errorMessage ?? 'Failed to create listing');
    }

    setLoading(false);
    return result;
  }

  /// Delete a farm
  Future<void> deleteFarm(int farmId) async {
    setLoading(true);
    clearError();

    try {
      await _detailsService.deleteFarm(farmId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Validate form (basic checks)
  bool validateBasicFields({
    required String? animalType,
    required String? breed,
    required String? gender,
    required String? price,
  }) {
    if (animalType == null || animalType.isEmpty) {
      setError('Please select an animal type');
      return false;
    }

    if (breed == null || breed.isEmpty) {
      setError('Please select a breed');
      return false;
    }

    if (gender == null || gender.isEmpty) {
      setError('Please select a gender');
      return false;
    }

    if (price == null || price.isEmpty) {
      setError('Please enter price');
      return false;
    }

    final priceValue = double.tryParse(price);
    if (priceValue == null || priceValue <= 0) {
      setError('Please enter a valid price');
      return false;
    }

    clearError();
    return true;
  }
}
