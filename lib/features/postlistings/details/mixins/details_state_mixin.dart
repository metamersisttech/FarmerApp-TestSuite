import 'package:flutter/material.dart';
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
  void initializeDetailsController(DetailsController controller) {
    detailsController = controller;

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
}
