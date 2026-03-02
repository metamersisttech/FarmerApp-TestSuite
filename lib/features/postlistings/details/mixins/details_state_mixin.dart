import 'package:flutter/material.dart';

/// Mixin for details page state management
mixin DetailsStateMixin<T extends StatefulWidget> on State<T> {
  // Text controllers
  late TextEditingController animalSearchController;
  late TextEditingController breedSearchController;
  late TextEditingController farmSearchController;
  late TextEditingController weightController;
  late TextEditingController priceController;

  // Selected values
  String? selectedAnimalType;
  String? selectedBreed;
  int? selectedAnimalId;
  String? selectedGender;
  String? selectedAge;
  String? selectedPriceType;
  int? selectedFarmId;
  String? selectedFarmName;

  // Error states for validation
  String? farmError;
  String? animalTypeError;
  String? breedError;
  String? genderError;
  String? ageError;
  String? weightError;
  String? priceError;

  // Loading states
  bool isSubmitting = false;

  /// Initialize text controllers
  void initializeControllers() {
    animalSearchController = TextEditingController();
    breedSearchController = TextEditingController();
    farmSearchController = TextEditingController();
    weightController = TextEditingController();
    priceController = TextEditingController();
  }

  /// Dispose text controllers
  void disposeControllers() {
    animalSearchController.dispose();
    breedSearchController.dispose();
    farmSearchController.dispose();
    weightController.dispose();
    priceController.dispose();
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

  /// Validate all required fields
  bool validateForm() {
    bool isValid = true;

    clearAllErrors();

    // Validate Animal Type (required)
    if (selectedAnimalType == null || selectedAnimalType!.isEmpty) {
      setFieldError('animalType', 'Please select an animal type');
      isValid = false;
    }

    // Validate Breed (required)
    if (selectedBreed == null || selectedBreed!.isEmpty) {
      setFieldError('breed', 'Please select a breed');
      isValid = false;
    }

    // Validate Gender (required)
    if (selectedGender == null || selectedGender!.isEmpty) {
      setFieldError('gender', 'Please select a gender');
      isValid = false;
    }

    // Weight is optional - only validate if provided
    final weight = weightController.text.trim();
    if (weight.isNotEmpty) {
      final weightValue = double.tryParse(weight);
      if (weightValue == null || weightValue <= 0) {
        setFieldError('weight', 'Please enter a valid weight');
        isValid = false;
      }
    }

    // Validate Price (required)
    final price = priceController.text.trim();
    if (price.isEmpty) {
      setFieldError('price', 'Please enter price');
      isValid = false;
    } else {
      final priceValue = double.tryParse(price);
      if (priceValue == null || priceValue <= 0) {
        setFieldError('price', 'Please enter a valid price');
        isValid = false;
      }
    }

    return isValid;
  }

  /// Convert age string to months
  int getAgeInMonths() {
    switch (selectedAge) {
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

  /// Get form data as Map for API
  Map<String, dynamic> getFormData() {
    final ageMonths = getAgeInMonths();
    final ageYears = ageMonths > 0 ? (ageMonths / 12).round() : 0;
    final weight = double.tryParse(weightController.text.trim());

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
      'price': double.tryParse(priceController.text.trim()) ?? 0,
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

    return data;
  }
}
