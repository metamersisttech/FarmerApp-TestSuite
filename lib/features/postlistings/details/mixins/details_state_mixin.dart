import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/postlistings/details/controllers/details_controller.dart';

/// Mixin for details page state management
mixin DetailsStateMixin<T extends StatefulWidget> on State<T> {
  late DetailsController detailsController;

  // Text controllers
  late TextEditingController animalSearchController;
  late TextEditingController breedSearchController;
  late TextEditingController farmSearchController;
  late TextEditingController weightController;
  late TextEditingController priceController;
  late TextEditingController locationController;

  // Selected values
  String? selectedAnimalType;
  String? selectedBreed;
  int? selectedAnimalId;
  String? selectedGender;
  String? selectedAge;
  String? selectedPriceType;
  int? selectedFarmId;
  String? selectedFarmName;
  LocationData? selectedLocation;
  bool isLocationRequired = false;
  bool hasValidLocationSource = false;  // True if location permission granted OR farm with coordinates selected
  bool selectedFarmHasCoordinates = false;  // True if selected farm has lat/lng

  // Error states for validation
  String? farmError;
  String? animalTypeError;
  String? breedError;
  String? genderError;
  String? ageError;
  String? weightError;
  String? priceError;
  String? locationError;

  // Loading states
  bool isSubmitting = false;

  /// Initialize controller and text controllers
  void initializeDetailsController(
    DetailsController controller, {
    Function(int)? onNext,
    Function(String)? onShowSuccess,
    Function(String)? onShowError,
    Function(String)? onShowInfo,
    Future<LocationData?> Function()? onNavigateToLocation,
    Future<Map<String, dynamic>?> Function(int, Map<String, dynamic>)? onNavigateToEditFarm,
  }) {
    detailsController = controller;
    _onNext = onNext;
    _onShowSuccess = onShowSuccess;
    _onShowError = onShowError;
    _onShowInfo = onShowInfo;
    _onNavigateToLocation = onNavigateToLocation;
    _onNavigateToEditFarm = onNavigateToEditFarm;

    // Set up callbacks
    detailsController.onFieldError = _handleFieldError;
    detailsController.onClearErrors = _handleClearErrors;

    // Listen to controller changes
    detailsController.addListener(_onControllerChanged);

    // Initialize text controllers
    animalSearchController = TextEditingController();
    breedSearchController = TextEditingController();
    farmSearchController = TextEditingController();
    weightController = TextEditingController();
    priceController = TextEditingController();
    locationController = TextEditingController();
  }

  // Callbacks
  Function(int)? _onNext;
  Function(String)? _onShowSuccess;
  Function(String)? _onShowError;
  Function(String)? _onShowInfo;
  Future<LocationData?> Function()? _onNavigateToLocation;
  Future<Map<String, dynamic>?> Function(int farmId, Map<String, dynamic> farm)? _onNavigateToEditFarm;

  /// Handle controller changes
  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle field error from controller
  void _handleFieldError(String field, String? error) {
    setFieldError(field, error);
  }

  /// Handle clear errors from controller
  void _handleClearErrors() {
    clearAllErrors();
  }

  /// Dispose controller and text controllers
  void disposeDetailsController() {
    detailsController.removeListener(_onControllerChanged);
    animalSearchController.dispose();
    breedSearchController.dispose();
    farmSearchController.dispose();
    weightController.dispose();
    priceController.dispose();
    locationController.dispose();
  }

  /// Set selected animal type
  void setSelectedAnimal(String? animalType) {
    if (mounted) {
      setState(() {
        selectedAnimalType = animalType;
        animalTypeError = null;
        if (animalType != null) {
          animalSearchController.text = animalType;
        }
      });
    }
  }

  /// Set selected breed
  void setSelectedBreed(String? breed, int? animalId) {
    if (mounted) {
      setState(() {
        selectedBreed = breed;
        selectedAnimalId = animalId;
        breedError = null;
        if (breed != null) {
          breedSearchController.text = breed;
        }
      });
    }
  }

  /// Set selected farm
  void setSelectedFarm(int? farmId, String? farmName) {
    if (mounted) {
      setState(() {
        selectedFarmId = farmId;
        selectedFarmName = farmName;
        farmError = null;
        if (farmName != null) {
          farmSearchController.text = farmName;
        }
      });
    }
  }

  /// Set selected location
  void setSelectedLocation(LocationData? location) {
    if (mounted) {
      setState(() {
        selectedLocation = location;
        locationError = null;
        if (location != null) {
          locationController.text = location.displayLocation;
        }
      });
    }
  }

  /// Clear location selection
  void clearLocationSelection() {
    if (mounted) {
      setState(() {
        selectedLocation = null;
        locationController.clear();
        locationError = null;
      });
    }
  }

  /// Set location requirement
  void setLocationRequired(bool required) {
    if (mounted) {
      setState(() {
        isLocationRequired = required;
      });
    }
  }

  /// Set whether we have a valid location source (location permission OR farm with coordinates selected)
  void setHasValidLocationSource(bool hasValid) {
    if (mounted) {
      setState(() {
        hasValidLocationSource = hasValid;
      });
    }
  }

  /// Set whether the selected farm has coordinates
  void setSelectedFarmHasCoordinates(bool hasCoordinates) {
    if (mounted) {
      setState(() {
        selectedFarmHasCoordinates = hasCoordinates;
      });
    }
  }

  /// Set selected gender
  void setSelectedGender(String? gender) {
    if (mounted) {
      setState(() {
        selectedGender = gender;
        genderError = null;
      });
    }
  }

  /// Set selected age
  void setSelectedAge(String? age) {
    if (mounted) {
      setState(() {
        selectedAge = age;
        ageError = null;
      });
    }
  }

  /// Set selected price type
  void setSelectedPriceType(String? priceType) {
    if (mounted) {
      setState(() {
        selectedPriceType = priceType;
      });
    }
  }

  /// Set error for specific field
  void setFieldError(String field, String? error) {
    if (mounted) {
      setState(() {
        switch (field) {
          case 'farm':
            farmError = error;
            break;
          case 'animalType':
            animalTypeError = error;
            break;
          case 'breed':
            breedError = error;
            break;
          case 'gender':
            genderError = error;
            break;
          case 'age':
            ageError = error;
            break;
          case 'weight':
            weightError = error;
            break;
          case 'price':
            priceError = error;
            break;
          case 'location':
            locationError = error;
            break;
        }
      });
    }
  }

  /// Clear all errors
  void clearAllErrors() {
    if (mounted) {
      setState(() {
        farmError = null;
        animalTypeError = null;
        breedError = null;
        genderError = null;
        ageError = null;
        weightError = null;
        priceError = null;
        locationError = null;
      });
    }
  }

  /// Set submitting state
  void setSubmitting(bool submitting) {
    if (mounted) {
      setState(() {
        isSubmitting = submitting;
      });
    }
  }

  /// Default toast implementations
  void _defaultShowSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _defaultShowError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _defaultShowInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Check location permission on page load
  Future<void> checkLocationPermissionOnLoad() async {
    final hasPermission = await detailsController.checkLocationPermissionStatus();

    if (hasPermission) {
      await autoPopulateLocation();
    } else {
      // Schedule dialog to show after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          promptForLocationPermission();
        }
      });
    }
  }

  /// Auto-populate location from device GPS
  Future<void> autoPopulateLocation() async {
    final location = await detailsController.fetchCurrentLocation();

    if (location != null && mounted) {
      setHasValidLocationSource(true);
      setSelectedLocation(location);
      (_onShowSuccess ?? _defaultShowSuccess)('Location detected: ${location.displayLocation}');
    } else if (mounted) {
      if (!selectedFarmHasCoordinates) {
        setHasValidLocationSource(false);
      }
      (_onShowInfo ?? _defaultShowInfo)('Could not detect location - please select manually');
    }
  }

  /// Prompt user for location permission
  Future<void> promptForLocationPermission() async {
    if (!mounted) return;

    // Import needed
    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text('Allow app to access your location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (shouldEnable == true && mounted) {
      final granted = await detailsController.requestLocationPermission();

      if (granted) {
        await autoPopulateLocation();
      } else {
        (_onShowInfo ?? _defaultShowInfo)('Please select a farm to continue');
      }
    }
  }

  /// Handle Next button press
  Future<void> handleNext() async {
    // Validate form using controller
    final isValid = detailsController.validateFormData(
      hasValidLocationSource: hasValidLocationSource,
      isLocationRequired: isLocationRequired,
      selectedLocation: selectedLocation,
      selectedAnimalType: selectedAnimalType,
      selectedBreed: selectedBreed,
      selectedGender: selectedGender,
      weightText: weightController.text,
      priceText: priceController.text,
    );

    if (!isValid) {
      (_onShowError ?? _defaultShowError)('Please fill all required fields');
      return;
    }

    setSubmitting(true);

    try {
      // Prepare form data using controller
      final formData = detailsController.prepareFormData(
        selectedAnimalId: selectedAnimalId,
        selectedGender: selectedGender,
        selectedAge: selectedAge,
        selectedFarmId: selectedFarmId,
        selectedLocation: selectedLocation,
        selectedBreed: selectedBreed,
        selectedAnimalType: selectedAnimalType,
        weightText: weightController.text,
        priceText: priceController.text,
      );

      final result = await detailsController.createListing(formData);

      if (!mounted) return;

      if (result.success && result.listingId != null) {
        setSubmitting(false);
        (_onShowSuccess ?? _defaultShowSuccess)('Listing created successfully!');
        _onNext?.call(result.listingId!);
      } else {
        setSubmitting(false);
        (_onShowError ?? _defaultShowError)(result.errorMessage ?? 'Failed to create listing');
      }
    } catch (e) {
      if (!mounted) return;
      setSubmitting(false);
      (_onShowError ?? _defaultShowError)(e.toString());
    }
  }

  /// Handle animal type selection
  void onAnimalTypeSelected(String? value) {
    setSelectedAnimal(value);
    detailsController.setSelectedAnimalType(value);

    if (value != null) {
      setSelectedBreed(null, null);
      breedSearchController.clear();
      detailsController.fetchBreedsForSpecies(value);
    }
  }

  /// Handle breed selection
  void onBreedSelected(String? value) {
    if (value != null) {
      // Find and set the animal ID
      final animal = detailsController.allAnimalModels.firstWhere(
        (a) =>
            a.species.toLowerCase() == selectedAnimalType?.toLowerCase() &&
            a.breed.toLowerCase() == value.toLowerCase(),
        orElse: () => throw Exception('Animal not found'),
      );
      final animalId = animal.animalId > 0 ? animal.animalId : null;
      setSelectedBreed(value, animalId);
      detailsController.setSelectedBreed(value);
      detailsController.setSelectedAnimalId(animalId);
    }
  }

  /// Handle create farm result
  void onFarmCreated(Map<String, dynamic>? result) {
    if (result != null) {
      detailsController.fetchFarms();

      final farmId = result['farm_id'] ?? result['id'];
      if (farmId != null) {
        final farmName = result['name']?.toString();
        setSelectedFarm(
          farmId is int ? farmId : int.tryParse(farmId.toString()),
          farmName,
        );

        // Check if farm has lat/lng and update location requirement
        final farmHasCoords = checkFarmLocation(result);

        // Set valid source based on farm coords or location permission
        if (farmHasCoords || detailsController.isLocationPermissionGranted) {
          setHasValidLocationSource(true);
        } else {
          setHasValidLocationSource(false);
        }
      }
    }
  }

  /// Check if selected farm has location data
  bool checkFarmLocation(Map<String, dynamic> farm) {
    // Handle empty map (farm not found)
    if (farm.isEmpty) {
      setLocationRequired(true);
      setSelectedFarmHasCoordinates(false);
      return false;
    }

    final lat = farm['latitude'];
    final lng = farm['longitude'];

    // Check if both exist and are non-null
    final hasCoordinates = lat != null && lng != null;

    if (hasCoordinates) {
      // Farm has coordinates - user doesn't need to provide location manually
      setLocationRequired(false);
      setSelectedFarmHasCoordinates(true);
      return true;
    } else {
      setLocationRequired(true);
      setSelectedFarmHasCoordinates(false);
      return false;
    }
  }

  /// Handle location selection navigation
  Future<void> handleLocationSelection() async {
    final result = await _onNavigateToLocation?.call();
    if (result != null) {
      setSelectedLocation(result);
    }
  }

  /// Handle edit farm action
  Future<void> handleEditFarm(int farmId) async {
    // Find the farm data
    final farm = detailsController.farms.firstWhere(
      (f) {
        final id = f['farm_id'];
        final fId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        return fId == farmId;
      },
      orElse: () => {},
    );

    if (farm.isEmpty) {
      (_onShowError ?? _defaultShowError)('Farm not found');
      return;
    }

    // Navigate to edit farm page
    final result = await _onNavigateToEditFarm?.call(farmId, farm);

    // Refresh farms list if edit was successful
    if (result != null) {
      await detailsController.fetchFarms();
      
      // Update selected farm if it was the one edited
      if (selectedFarmId == farmId) {
        final updatedFarmName = result['name']?.toString();
        setSelectedFarm(farmId, updatedFarmName);
      }
      
      (_onShowSuccess ?? _defaultShowSuccess)('Farm updated successfully!');
    }
  }

  /// Handle delete farm action
  Future<void> handleDeleteFarm(int farmId) async {
    // Find the farm data
    final farm = detailsController.farms.firstWhere(
      (f) {
        final id = f['farm_id'];
        final fId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        return fId == farmId;
      },
      orElse: () => {},
    );

    if (farm.isEmpty) {
      (_onShowError ?? _defaultShowError)('Farm not found');
      return;
    }

    final farmName = farm['name']?.toString() ?? 'this farm';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Farm'),
          content: Text('Are you sure you want to delete "$farmName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Proceed with deletion
    try {
      await detailsController.deleteFarm(farmId);

      if (!mounted) return;

      // If the deleted farm was selected, clear selection
      if (selectedFarmId == farmId) {
        setSelectedFarm(null, null);
        detailsController.setSelectedFarmId(null);
      }

      // Refresh farms list
      await detailsController.fetchFarms();

      (_onShowSuccess ?? _defaultShowSuccess)('Farm deleted successfully!');
    } catch (e) {
      if (!mounted) return;
      (_onShowError ?? _defaultShowError)(e.toString());
    }
  }
}
