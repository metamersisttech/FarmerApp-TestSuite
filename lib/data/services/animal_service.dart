import 'package:flutter_app/core/constants/api_endpoints.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/data/models/animal_model.dart';
import 'package:flutter_app/data/services/api_service.dart';
import 'package:flutter_app/data/services/token_storage_service.dart';

/// Service for handling animal-related API operations
class AnimalService {
  final ApiService _apiService;
  final TokenStorageService _tokenService;

  AnimalService({
    ApiService? apiService,
    TokenStorageService? tokenService,
  })  : _apiService = apiService ?? ApiService(),
        _tokenService = tokenService ?? TokenStorageService();

  /// Get all animals from catalog
  /// Requires authentication (Bearer token)
  /// 
  /// Returns list of animals with species, breed, and other details
  /// Returns empty list if no animals found (404)
  /// Throws ApiException for other errors
  Future<List<AnimalModel>> fetchAnimals() async {
    try {
      // Get stored access token
      final token = await _tokenService.getAccessToken();
      
      if (token == null) {
        throw UnauthorizedException(
          message: 'Authentication required. Please login again.',
        );
      }

      // Set auth token in API service
      _apiService.setAuthToken(token);

      // Make GET request to animals endpoint
      final response = await _apiService.get(ApiEndpoints.animals);

      // Parse response data
      if (response.data is List) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => AnimalModel.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Invalid response format from server',
        );
      }
    } on NotFoundException catch (_) {
      // Return empty list if endpoint returns 404 (no animals found)
      return [];
    } on ApiException {
      rethrow; // Re-throw other API exceptions
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch animals: ${e.toString()}',
      );
    }
  }

  /// Get unique species list from animals
  Future<List<String>> fetchSpeciesList() async {
    try {
      final animals = await fetchAnimals();
      
      // Extract unique species
      final speciesSet = animals.map((animal) => animal.species).toSet();
      final speciesList = speciesSet.toList()..sort();
      
      return speciesList;
    } catch (e) {
      rethrow;
    }
  }

  /// Get breeds for a specific species
  Future<List<String>> fetchBreedsForSpecies(String species) async {
    try {
      final animals = await fetchAnimals();
      
      // Filter animals by species and extract breeds
      final breeds = animals
          .where((animal) => animal.species.toLowerCase() == species.toLowerCase())
          .map((animal) => animal.breed)
          .toSet()
          .toList()..sort();
      
      return breeds;
    } catch (e) {
      rethrow;
    }
  }
}
