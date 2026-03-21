import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/data/services/location_service.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/postlistings/details/services/details_service.dart';

/// Controller for details page operations
class DetailsController extends BaseController {
  final DetailsService _detailsService;
  final LocationService _locationService;

  // Callbacks for UI feedback
  Function(String field, String? error)? onFieldError;
  Function()? onClearErrors;
  Function(String message)? onShowSuccess;
  Function(String message)? onShowError;

  // Location permission state
  bool _isLocationPermissionGranted = false;
  bool _isCheckingLocationPermission = false;
  LocationData? _autoDetectedLocation;

  DetailsController({DetailsService? detailsService, LocationService? locationService})
      : _detailsService = detailsService ?? DetailsService(),
        _locationService = locationService ?? LocationService();

  // Location getters
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get isCheckingLocationPermission => _isCheckingLocationPermission;
  LocationData? get autoDetectedLocation => _autoDetectedLocation;
  LocationService get locationService => _locationService;

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

  /// Check if location permission is already granted
  /// Returns true if permission is granted
  Future<bool> checkLocationPermissionStatus() async {
    _isCheckingLocationPermission = true;
    notifyListeners();

    try {
      _isLocationPermissionGranted = await _locationService.isPermissionGranted();
      return _isLocationPermissionGranted;
    } finally {
      _isCheckingLocationPermission = false;
      notifyListeners();
    }
  }

  /// Request location permission
  /// Returns true if permission was granted
  Future<bool> requestLocationPermission() async {
    _isCheckingLocationPermission = true;
    notifyListeners();

    try {
      final result = await _locationService.requestLocationAccess();
      _isLocationPermissionGranted = result.success;
      return result.success;
    } finally {
      _isCheckingLocationPermission = false;
      notifyListeners();
    }
  }

  /// Fetch current location and create LocationData
  /// Returns LocationData if successful, null otherwise
  Future<LocationData?> fetchCurrentLocation() async {
    if (!_isLocationPermissionGranted) {
      return null;
    }

    try {
      final result = await _locationService.getCurrentLocation(includeAddress: true);

      if (result.success && result.position != null) {
        // Parse address to extract city/area
        String? city;
        String? area;

        if (result.address != null && result.address!.isNotEmpty) {
          final addressParts = result.address!.split(', ');
          if (addressParts.length >= 2) {
            area = addressParts[0];
            city = addressParts[1];
          } else if (addressParts.length == 1) {
            city = addressParts[0];
          }
        }

        _autoDetectedLocation = LocationData(
          latitude: result.position!.latitude,
          longitude: result.position!.longitude,
          city: city,
          area: area,
          fullAddress: result.address,
        );

        notifyListeners();
        return _autoDetectedLocation;
      }

      return null;
    } catch (e) {
      setError('Failed to get current location: ${e.toString()}');
      return null;
    }
  }

  /// Clear auto-detected location
  void clearAutoDetectedLocation() {
    _autoDetectedLocation = null;
    notifyListeners();
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

  /// Validate all required fields with detailed error feedback
  bool validateFormData({
    required bool hasValidLocationSource,
    required bool isLocationRequired,
    required LocationData? selectedLocation,
    required String? selectedAnimalType,
    required String? selectedBreed,
    required String? selectedGender,
    required String weightText,
    required String priceText,
  }) {
    bool isValid = true;

    onClearErrors?.call();

    // Consolidated location validation:
    // Must have one of: (1) farm with coordinates, (2) manual location, (3) auto-detected location
    // hasValidLocationSource tracks if we have permission OR farm with coords
    // isLocationRequired means farm is selected but lacks coordinates
    if (!hasValidLocationSource) {
      // No permission and no farm selected
      onFieldError?.call('location', 'Please grant location access or select a farm');
      isValid = false;
    } else if (isLocationRequired && selectedLocation == null) {
      // Farm selected but lacks coordinates, and no manual location provided
      onFieldError?.call('location', 'Selected farm has no location - please select a location');
      isValid = false;
    }

    // Validate Animal Type (required)
    if (selectedAnimalType == null || selectedAnimalType.isEmpty) {
      onFieldError?.call('animalType', 'Please select an animal type');
      isValid = false;
    }

    // Validate Breed (required)
    if (selectedBreed == null || selectedBreed.isEmpty) {
      onFieldError?.call('breed', 'Please select a breed');
      isValid = false;
    }

    // Validate Gender (required)
    if (selectedGender == null || selectedGender.isEmpty) {
      onFieldError?.call('gender', 'Please select a gender');
      isValid = false;
    }

    // Weight is optional - only validate if provided
    final weight = weightText.trim();
    if (weight.isNotEmpty) {
      final weightValue = double.tryParse(weight);
      if (weightValue == null || weightValue <= 0) {
        onFieldError?.call('weight', 'Please enter a valid weight');
        isValid = false;
      }
    }

    // Validate Price (required)
    final price = priceText.trim();
    if (price.isEmpty) {
      onFieldError?.call('price', 'Please enter price');
      isValid = false;
    } else {
      final priceValue = double.tryParse(price);
      if (priceValue == null || priceValue <= 0) {
        onFieldError?.call('price', 'Please enter a valid price');
        isValid = false;
      }
    }

    return isValid;
  }

  /// Convert age string to months
  int convertAgeToMonths(String? age) {
    switch (age) {
      case '1 Year':
        return 12;
      case '2 Years':
        return 24;
      case '3 Years':
        return 36;
      case '4 Years':
        return 48;
      case '5+ Years':
        return 60;
      default:
        return 0;
    }
  }

  /// Prepare form data for API submission
  Map<String, dynamic> prepareFormData({
    required int? selectedAnimalId,
    required String? selectedGender,
    required String? selectedAge,
    required int? selectedFarmId,
    required LocationData? selectedLocation,
    required String? selectedBreed,
    required String? selectedAnimalType,
    required String weightText,
    required String priceText,
  }) {
    final ageMonths = convertAgeToMonths(selectedAge);
    final ageYears = ageMonths > 0 ? (ageMonths / 12).round() : 0;
    final weight = double.tryParse(weightText.trim());

    // Generate title from form data
    String title = selectedBreed ?? selectedAnimalType ?? 'Animal';
    if (ageYears > 0) {
      title += ' - $ageYears ${ageYears == 1 ? 'Year' : 'Years'} Old';
    }

    // Generate description
    final descParts = <String>[];
    descParts.add(
        'Healthy ${selectedGender?.toLowerCase() ?? ''} ${selectedBreed ?? selectedAnimalType}.');
    if (ageYears > 0) {
      descParts.add('Age: $ageYears ${ageYears == 1 ? 'year' : 'years'}.');
    }
    if (weight != null && weight > 0) {
      descParts.add('Weight: ${weight.toStringAsFixed(0)} kg.');
    }
    final description = descParts.join(' ');

    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'animal': selectedAnimalId,
      'gender': selectedGender?.toLowerCase(),
      'price': double.tryParse(priceText.trim()) ?? 0,
      'currency': 'INR',
    };

    // Add optional fields only if they have values
    if (selectedFarmId != null) {
      data['farm'] = selectedFarmId;
    }
    if (ageMonths > 0) {
      data['age_months'] = ageMonths;
    }
    if (weight != null && weight > 0) {
      data['weight_kg'] = weight;
    }

    // Add location if selected (for listings where farm doesn't have lat/lng)
    if (selectedLocation != null && selectedLocation.latitude != null && selectedLocation.longitude != null) {
      data['location'] = {
        'lat': selectedLocation.latitude!,
        'long': selectedLocation.longitude!,
      };
    }

    return data;
  }
}
