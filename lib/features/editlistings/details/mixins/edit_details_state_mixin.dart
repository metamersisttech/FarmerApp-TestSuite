import 'package:flutter/material.dart';
import 'package:flutter_app/features/postlistings/details/mixins/details_state_mixin.dart';

/// Mixin for edit details page: adds pre-fill from API listing response.
mixin EditDetailsStateMixin<T extends StatefulWidget> on State<T>, DetailsStateMixin<T> {
  /// Map age_months from API to dropdown string
  static String? ageMonthsToLabel(int? ageMonths) {
    if (ageMonths == null || ageMonths <= 0) return null;
    if (ageMonths <= 12) return '1 Year';
    if (ageMonths <= 24) return '2 Years';
    if (ageMonths <= 36) return '3 Years';
    if (ageMonths <= 48) return '4 Years';
    return '5+ Years';
  }

  /// Pre-fill form from listing API response (getListingById).
  void preFillFromListing(Map<String, dynamic> listing) {
    if (!mounted) return;

    // Animal: id or object with id, species, breed
    int? animalId;
    String? species;
    String? breed;
    final animal = listing['animal'];
    if (animal is int) {
      animalId = animal;
    } else if (animal is Map<String, dynamic>) {
      animalId = _parseInt(animal['id'] ?? animal['animal_id']);
      species = animal['species']?.toString();
      breed = animal['breed']?.toString() ?? animal['name']?.toString();
    }
    if (species == null && listing['species'] != null) {
      species = listing['species'].toString();
    }
    if (breed == null && listing['breed'] != null) {
      breed = listing['breed'].toString();
    }

    // Farm: id or object with id, name
    int? farmId;
    String? farmName;
    final farm = listing['farm'];
    if (farm is int) {
      farmId = farm;
    } else if (farm is Map<String, dynamic>) {
      farmId = _parseInt(farm['id'] ?? farm['farm_id']);
      farmName = farm['name']?.toString();
    }

    final gender = listing['gender']?.toString();
    final ageMonths = _parseInt(listing['age_months']);
    final ageLabel = ageMonthsToLabel(ageMonths);
    final weightKg = _parseDouble(listing['weight_kg']);
    final price = _parseDouble(listing['price']);
    final priceType = listing['price_type']?.toString() ?? 'Fixed';

    setState(() {
      if (species != null) {
        selectedAnimalType = species;
        animalSearchController.text = species;
      }
      if (breed != null) {
        selectedBreed = breed;
        selectedAnimalId = animalId;
        breedSearchController.text = breed;
      }
      if (gender != null && gender.isNotEmpty) {
        // Capitalize first letter to match UI expected format (Male/Female)
        selectedGender = gender[0].toUpperCase() + gender.substring(1).toLowerCase();
      }
      if (ageLabel != null) selectedAge = ageLabel;
      if (weightKg != null && weightKg > 0) {
        weightController.text = weightKg.toStringAsFixed(0);
      }
      if (price != null && price > 0) {
        priceController.text = price.toStringAsFixed(0);
      }
      selectedPriceType = priceType;
      if (farmId != null) {
        selectedFarmId = farmId;
        selectedFarmName = farmName;
        // Note: hasValidLocationSource will be set by checkFarmCoordinatesAfterLoad()
        // after farms list is fetched, to properly verify farm has coordinates
        if (farmName != null) farmSearchController.text = farmName;
      }
    });
  }

  /// Check farm coordinates after farms list is loaded.
  /// Call this after fetchFarms() completes to properly set location flags.
  void checkFarmCoordinatesAfterLoad(List<Map<String, dynamic>> farms, bool hasLocationPermission) {
    if (!mounted) return;
    if (selectedFarmId == null) {
      // No farm selected - rely on location permission
      setState(() {
        hasValidLocationSource = hasLocationPermission;
        selectedFarmHasCoordinates = false;
        isLocationRequired = false;
      });
      return;
    }

    // Find the selected farm
    final farm = farms.firstWhere(
      (f) {
        final id = f['farm_id'];
        final fId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        return fId == selectedFarmId;
      },
      orElse: () => <String, dynamic>{},
    );

    if (farm.isEmpty) {
      // Farm not found in list - rely on location permission
      setState(() {
        hasValidLocationSource = hasLocationPermission;
        selectedFarmHasCoordinates = false;
        isLocationRequired = true;
      });
      return;
    }

    final lat = farm['latitude'];
    final lng = farm['longitude'];
    final farmHasCoords = lat != null && lng != null;

    setState(() {
      selectedFarmHasCoordinates = farmHasCoords;
      isLocationRequired = !farmHasCoords;
      // Valid if farm has coords OR we have location permission
      hasValidLocationSource = farmHasCoords || hasLocationPermission;
    });
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    return null;
  }
}
