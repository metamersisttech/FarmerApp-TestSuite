import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/data/services/animal_service.dart';

/// Repository result class
class AnimalRepositoryResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const AnimalRepositoryResult({
    required this.success,
    this.data,
    this.error,
  });

  factory AnimalRepositoryResult.success(T data) {
    return AnimalRepositoryResult(success: true, data: data);
  }

  factory AnimalRepositoryResult.failure(String error) {
    return AnimalRepositoryResult(success: false, error: error);
  }
}

/// Repository for animal data operations
/// 
/// Handles data fetching, caching, and error handling
class AnimalRepository {
  final AnimalService _animalService;

  // Cache for animals data
  List<AnimalModel>? _cachedAnimals;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  AnimalRepository({AnimalService? animalService})
      : _animalService = animalService ?? AnimalService();

  /// Get all animals with caching
  Future<AnimalRepositoryResult<List<AnimalModel>>> getAnimals({
    bool forceRefresh = false,
  }) async {
    try {
      // Return cached data if available and not expired
      if (!forceRefresh &&
          _cachedAnimals != null &&
          _cacheTime != null &&
          DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return AnimalRepositoryResult.success(_cachedAnimals!);
      }

      // Fetch fresh data
      final animals = await _animalService.fetchAnimals();

      // Update cache (even if empty)
      _cachedAnimals = animals;
      _cacheTime = DateTime.now();

      // Return success even with empty list
      return AnimalRepositoryResult.success(animals);
    } on UnauthorizedException catch (e) {
      return AnimalRepositoryResult.failure(
        e.message,
      );
    } on NetworkException {
      return AnimalRepositoryResult.failure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return AnimalRepositoryResult.failure(
        'Request timeout. Please try again.',
      );
    } on ServerException {
      return AnimalRepositoryResult.failure(
        'Server error. Please try again later.',
      );
    } on ApiException catch (e) {
      return AnimalRepositoryResult.failure(
        e.message,
      );
    } catch (e) {
      return AnimalRepositoryResult.failure(
        'Failed to fetch animals: ${e.toString()}',
      );
    }
  }

  /// Get unique species list
  Future<AnimalRepositoryResult<List<String>>> getSpeciesList({
    bool forceRefresh = false,
  }) async {
    try {
      final result = await getAnimals(forceRefresh: forceRefresh);

      if (!result.success || result.data == null) {
        return AnimalRepositoryResult.failure(
          result.error ?? 'Failed to fetch species',
        );
      }

      // Extract unique species
      final speciesSet = result.data!.map((animal) => animal.species).toSet();
      final speciesList = speciesSet.toList()..sort();

      return AnimalRepositoryResult.success(speciesList);
    } catch (e) {
      return AnimalRepositoryResult.failure(
        'Failed to fetch species: ${e.toString()}',
      );
    }
  }

  /// Get breeds for a specific species
  Future<AnimalRepositoryResult<List<String>>> getBreedsForSpecies(
    String species, {
    bool forceRefresh = false,
  }) async {
    try {
      final result = await getAnimals(forceRefresh: forceRefresh);

      if (!result.success || result.data == null) {
        return AnimalRepositoryResult.failure(
          result.error ?? 'Failed to fetch breeds',
        );
      }

      // Filter by species and extract breeds
      final breeds = result.data!
          .where((animal) =>
              animal.species.toLowerCase() == species.toLowerCase())
          .map((animal) => animal.breed)
          .toSet()
          .toList()
        ..sort();

      return AnimalRepositoryResult.success(breeds);
    } catch (e) {
      return AnimalRepositoryResult.failure(
        'Failed to fetch breeds: ${e.toString()}',
      );
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedAnimals = null;
    _cacheTime = null;
  }
}

