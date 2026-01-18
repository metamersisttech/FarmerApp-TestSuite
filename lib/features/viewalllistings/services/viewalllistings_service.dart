import 'package:flutter_app/data/models/listing_model.dart';

/// ViewAllListings Service - Handles data operations for marketplace feature
/// 
/// This service layer provides listing data.
/// Currently uses hardcoded data; will be replaced with API calls later.
class ViewAllListingsService {
  /// Fetch all marketplace listings
  /// Returns a list of ListingModel objects
  /// Currently hardcoded; TODO: Replace with API call
  Future<List<ListingModel>> fetchListings({Map<String, dynamic>? params}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    print('[ViewAllListingsService] fetchListings called with params: $params');

    // Hardcoded data matching the UI image
    final List<Map<String, dynamic>> hardcodedListings = [
      {
        'listing_id': 1,
        'title': 'Cow',
        'primary_image': 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
        'age_months': 36,
        'price': 85000,
        'location': 'Harrapur',
        'rating': 4.6,
        'is_verified': true,
      },
      {
        'listing_id': 2,
        'title': 'Murrah Buffalo',
        'primary_image': 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
        'age_months': 48,
        'price': 120000,
        'location': 'El Doab',
        'rating': 4.5,
        'is_verified': true,
      },
      {
        'listing_id': 3,
        'title': 'Sahiwal Cow',
        'primary_image': 'https://images.unsplash.com/photo-1504006833117-8886a355efbf?w=400',
        'age_months': 30,
        'price': 75000,
        'location': 'Mumbai',
        'rating': 4.3,
        'is_verified': false,
      },
      {
        'listing_id': 4,
        'title': 'Tharparkar Cow',
        'primary_image': 'https://images.unsplash.com/photo-1550006290-eb89f8a35cad?w=400',
        'age_months': 42,
        'price': 95000,
        'location': 'Rajasthan',
        'rating': 4.7,
        'is_verified': true,
      },
      {
        'listing_id': 5,
        'title': 'Gir Cow',
        'primary_image': 'https://images.unsplash.com/photo-1527153857715-3908f2bae5e8?w=400',
        'age_months': 24,
        'price': 65000,
        'location': 'Gujarat',
        'rating': 4.4,
        'is_verified': true,
      },
      {
        'listing_id': 6,
        'title': 'Jersey Cow',
        'primary_image': 'https://images.unsplash.com/photo-1598808503491-243193e8d44c?w=400',
        'age_months': 36,
        'price': 80000,
        'location': 'Punjab',
        'rating': 4.5,
        'is_verified': false,
      },
      {
        'listing_id': 7,
        'title': 'Holstein Friesian',
        'primary_image': 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
        'age_months': 48,
        'price': 110000,
        'location': 'Haryana',
        'rating': 4.8,
        'is_verified': true,
      },
      {
        'listing_id': 8,
        'title': 'Red Sindhi',
        'primary_image': 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
        'age_months': 30,
        'price': 70000,
        'location': 'Sindh',
        'rating': 4.2,
        'is_verified': false,
      },
    ];

    // Apply filters if provided
    List<Map<String, dynamic>> filteredListings = List.from(hardcodedListings);

    if (params != null) {
      // Filter by search query
      if (params['search'] != null && params['search'].toString().isNotEmpty) {
        final searchQuery = params['search'].toString().toLowerCase();
        filteredListings = filteredListings.where((listing) {
          final title = listing['title'].toString().toLowerCase();
          final location = listing['location'].toString().toLowerCase();
          return title.contains(searchQuery) || location.contains(searchQuery);
        }).toList();
      }

      // Filter by category
      if (params['category'] != null) {
        filteredListings = filteredListings.where((listing) {
          return listing['title'].toString().toLowerCase().contains(
            params['category'].toString().toLowerCase()
          );
        }).toList();
      }

      // Filter by price range
      if (params['min_price'] != null) {
        final minPrice = double.tryParse(params['min_price'].toString()) ?? 0;
        filteredListings = filteredListings.where((listing) {
          return listing['price'] >= minPrice;
        }).toList();
      }

      if (params['max_price'] != null) {
        final maxPrice = double.tryParse(params['max_price'].toString()) ?? double.infinity;
        filteredListings = filteredListings.where((listing) {
          return listing['price'] <= maxPrice;
        }).toList();
      }
    }

    // Convert to ListingModel objects
    final listings = filteredListings
        .map((item) => ListingModel.fromJson(item))
        .toList();

    print('[ViewAllListingsService] Returning ${listings.length} listings');
    
    return listings;
  }

  /// Search listings by query
  Future<List<ListingModel>> searchListings(String query) async {
    if (query.isEmpty) {
      return fetchListings();
    }

    return fetchListings(params: {'search': query});
  }

  /// Filter listings by category/type
  Future<List<ListingModel>> filterListings({
    String? category,
    String? animalType,
    double? minPrice,
    double? maxPrice,
  }) async {
    final params = <String, dynamic>{};
    
    if (category != null) params['category'] = category;
    if (animalType != null) params['animal_type'] = animalType;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();

    return fetchListings(params: params);
  }
}
