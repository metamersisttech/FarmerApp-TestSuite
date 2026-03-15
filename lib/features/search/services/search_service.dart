import 'package:flutter_app/core/helpers/backend_helper.dart';

/// Search Service
///
/// Handles all search-related API calls using backend helper
class SearchService {
  final BackendHelper _backendHelper = BackendHelper();

  /// Known species list for intelligent search
  static const List<String> _knownSpecies = [
    'cow',
    'buffalo',
    'sheep',
    'goat',
    'pig',
    'chicken',
    'horse',
    'camel',
    'cattle',
    'poultry',
  ];

  /// Search animals by species or breed name
  /// 
  /// Parameters:
  /// - query: Search query string (species or breed name)
  /// - latitude: Optional latitude coordinate
  /// - longitude: Optional longitude coordinate
  /// - category: Optional category filter (species)
  /// 
  /// Returns: List of search results from listings endpoint
  /// 
  /// API Example: GET /api/listings/?has_location=true&lat=17.56&long=18.4&species=cow
  Future<List<dynamic>> searchAnimals({
    required String query,
    double? latitude,
    double? longitude,
    String? category,
  }) async {
    try {
      // Build query parameters for the listings endpoint
      final params = <String, dynamic>{};
      
      // Always set has_location=true for search
      params['has_location'] = 'true';
      
      // Add lat/long if location is selected
      if (latitude != null && longitude != null) {
        params['lat'] = latitude.toString();
        params['long'] = longitude.toString();
      }
      
      // If category is explicitly provided, use it as species filter
      if (category != null && category.isNotEmpty) {
        params['species'] = category.toLowerCase();
        
        // If query is also provided, treat it as breed
        if (query.isNotEmpty) {
          params['breed'] = query.toLowerCase();
        }
      } else if (query.isNotEmpty) {
        // No category provided - intelligently detect if query is species or breed
        final queryLower = query.toLowerCase().trim();
        
        // Check if query matches a known species
        if (_knownSpecies.contains(queryLower)) {
          // Query is a species
          params['species'] = queryLower;
        } else {
          // Query is likely a breed - search by breed
          params['breed'] = queryLower;
        }
      }

      // Debug: Print params being sent
      print('🔍 [SearchService] Calling getListings with params: $params');
      
      // Call getListings from backend helper with filter params
      // Example: GET /api/listings/?has_location=true&lat=17.56&long=18.4&species=cow
      final response = await _backendHelper.getListings(params: params);
      
      // Handle both paginated and non-paginated responses
      if (response is Map) {
        // Paginated response with 'results' key
        if (response['results'] != null) {
          return response['results'] as List<dynamic>;
        }
        // Single object wrapped in Map
        return [response];
      } else if (response is List) {
        // Direct list response
        return response;
      }
      
      return [];
    } on BackendException catch (e) {
      throw Exception('Search failed: ${e.message}');
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  /// Search listings by query (alternative endpoint for listings)
  /// 
  /// Parameters:
  /// - query: Search query string
  /// - latitude: Optional latitude coordinate
  /// - longitude: Optional longitude coordinate
  /// - category: Optional category filter
  /// 
  /// Returns: List of listing search results
  Future<List<dynamic>> searchListings({
    required String query,
    double? latitude,
    double? longitude,
    String? category,
  }) async {
    try {
      // Build query parameters for the listings endpoint
      final params = <String, dynamic>{
        'search': query, // Search by name/title/description
        'has_location': 'true', // Always set has_location=true
      };
      
      // Add lat/long if location is selected
      if (latitude != null && longitude != null) {
        params['lat'] = latitude.toString();
        params['long'] = longitude.toString();
      }
      
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }

      // Call getListings from backend helper with search params
      final response = await _backendHelper.getListings(params: params);
      
      // Handle both paginated and non-paginated responses
      if (response is Map) {
        // Paginated response with 'results' key
        if (response['results'] != null) {
          return response['results'] as List<dynamic>;
        }
        // Single object wrapped in Map
        return [response];
      } else if (response is List) {
        // Direct list response
        return response;
      }
      
      return [];
    } on BackendException catch (e) {
      throw Exception('Search failed: ${e.message}');
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  /// Get search suggestions based on partial query
  /// 
  /// Parameters:
  /// - query: Partial search query
  /// 
  /// Returns: List of suggested search terms
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      // Get animals matching partial query
      final animals = await searchAnimals(query: query);
      
      // Extract names/breeds for suggestions
      final suggestions = <String>[];
      for (var animal in animals) {
        if (animal is Map) {
          final name = animal['name']?.toString();
          final breed = animal['breed']?.toString();
          
          if (name != null && !suggestions.contains(name)) {
            suggestions.add(name);
          }
          if (breed != null && !suggestions.contains(breed)) {
            suggestions.add(breed);
          }
        }
      }
      
      // Limit to 10 suggestions
      return suggestions.take(10).toList();
    } catch (e) {
      // Return empty list on error (don't fail the whole search)
      return [];
    }
  }

  /// Get popular search categories
  /// 
  /// Returns: List of popular categories
  Future<List<Map<String, dynamic>>> getPopularCategories() async {
    try {
      // Get all animals to determine popular categories
      final response = await _backendHelper.getAnimals();
      
      final animals = <dynamic>[];
      if (response is Map && response['results'] != null) {
        animals.addAll(response['results'] as List);
      } else if (response is List) {
        animals.addAll(response);
      }

      // Count animals by species
      final categoryCount = <String, int>{};
      for (var animal in animals) {
        if (animal is Map) {
          final species = animal['species']?.toString() ?? 'Unknown';
          categoryCount[species] = (categoryCount[species] ?? 0) + 1;
        }
      }

      // Convert to list and sort by count
      final categories = categoryCount.entries.map((entry) {
        return {
          'name': entry.key,
          'icon': _getCategoryIcon(entry.key),
          'count': entry.value,
        };
      }).toList();

      categories.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return categories.take(4).toList(); // Return top 4
    } catch (e) {
      // Return default categories on error
      return [
        {'name': 'Cow', 'icon': '🐄', 'count': 0},
        {'name': 'Sheep', 'icon': '🐑', 'count': 0},
        {'name': 'Buffalo', 'icon': '🐃', 'count': 0},
        {'name': 'Goat', 'icon': '🐐', 'count': 0},
      ];
    }
  }

  /// Get emoji icon for category
  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cow':
      case 'cattle':
        return '🐄';
      case 'sheep':
        return '🐑';
      case 'buffalo':
      case 'water buffalo':
        return '🐃';
      case 'goat':
        return '🐐';
      case 'pig':
      case 'swine':
        return '🐷';
      case 'chicken':
      case 'poultry':
        return '🐔';
      case 'horse':
        return '🐴';
      case 'camel':
        return '🐫';
      default:
        return '🐾';
    }
  }
}
