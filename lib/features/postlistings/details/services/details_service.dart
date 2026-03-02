import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/data/repositories/animal_repository.dart';

/// Result of details operations
class DetailsResult {
  final bool success;
  final int? listingId;
  final String? errorMessage;

  const DetailsResult({
    required this.success,
    this.listingId,
    this.errorMessage,
  });

  factory DetailsResult.success({required int listingId}) {
    return DetailsResult(
      success: true,
      listingId: listingId,
    );
  }

  factory DetailsResult.error(String message) {
    return DetailsResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Result of animals fetch operation
class AnimalsResult {
  final bool success;
  final List<AnimalModel>? animals;
  final List<String>? speciesList;
  final String? error;

  const AnimalsResult({
    required this.success,
    this.animals,
    this.speciesList,
    this.error,
  });

  factory AnimalsResult.success({
    required List<AnimalModel> animals,
    required List<String> speciesList,
  }) {
    return AnimalsResult(
      success: true,
      animals: animals,
      speciesList: speciesList,
    );
  }

  factory AnimalsResult.error(String message) {
    return AnimalsResult(
      success: false,
      error: message,
    );
  }
}

/// Result of breeds fetch operation
class BreedsResult {
  final bool success;
  final List<String>? breeds;
  final String? error;

  const BreedsResult({
    required this.success,
    this.breeds,
    this.error,
  });

  factory BreedsResult.success({required List<String> breeds}) {
    return BreedsResult(
      success: true,
      breeds: breeds,
    );
  }

  factory BreedsResult.error(String message) {
    return BreedsResult(
      success: false,
      error: message,
    );
  }
}

/// Result of farms fetch operation
class FarmsResult {
  final bool success;
  final List<Map<String, dynamic>>? farms;
  final String? error;

  const FarmsResult({
    required this.success,
    this.farms,
    this.error,
  });

  factory FarmsResult.success({required List<Map<String, dynamic>> farms}) {
    return FarmsResult(
      success: true,
      farms: farms,
    );
  }

  factory FarmsResult.error(String message) {
    return FarmsResult(
      success: false,
      error: message,
    );
  }
}

/// Service for details page operations
class DetailsService {
  final AnimalRepository _animalRepository;
  final BackendHelper _backendHelper;

  DetailsService({
    AnimalRepository? animalRepository,
    BackendHelper? backendHelper,
  })  : _animalRepository = animalRepository ?? AnimalRepository(),
        _backendHelper = backendHelper ?? BackendHelper();

  /// Get all animals with species list
  Future<AnimalsResult> getAnimals() async {
    try {
      // Fetch full animal data (with IDs)
      final animalsResult = await _animalRepository.getAnimals();
      if (!animalsResult.success || animalsResult.data == null) {
        return AnimalsResult.error(
            animalsResult.error ?? 'Failed to fetch animals');
      }

      // Fetch species list for dropdown
      final speciesResult = await _animalRepository.getSpeciesList();
      if (!speciesResult.success || speciesResult.data == null) {
        return AnimalsResult.error(
            speciesResult.error ?? 'Failed to fetch species list');
      }

      return AnimalsResult.success(
        animals: animalsResult.data!,
        speciesList: speciesResult.data!,
      );
    } catch (e) {
      return AnimalsResult.error(e.toString());
    }
  }

  /// Get breeds for a specific species
  Future<BreedsResult> getBreedsForSpecies(String species) async {
    try {
      final result = await _animalRepository.getBreedsForSpecies(species);

      if (!result.success || result.data == null) {
        return BreedsResult.error(result.error ?? 'Failed to fetch breeds');
      }

      return BreedsResult.success(breeds: result.data!);
    } catch (e) {
      return BreedsResult.error(e.toString());
    }
  }

  /// Get user's farms
  Future<FarmsResult> getFarms() async {
    try {
      final farms = await _backendHelper.getFarms();
      final farmsList =
          farms.map((farm) => farm as Map<String, dynamic>).toList();

      return FarmsResult.success(farms: farmsList);
    } catch (e) {
      return FarmsResult.error(e.toString());
    }
  }

  /// Create listing with details data
  Future<DetailsResult> postCreateListing(Map<String, dynamic> data) async {
    try {
      final response = await _backendHelper.postCreateListing(data);

      // Extract listing ID from response
      final listingId = response['listing_id'] ?? response['id'];
      if (listingId == null) {
        return DetailsResult.error('Failed to get listing ID from response');
      }

      return DetailsResult.success(listingId: listingId as int);
    } catch (e) {
      return DetailsResult.error(e.toString());
    }
  }
}
