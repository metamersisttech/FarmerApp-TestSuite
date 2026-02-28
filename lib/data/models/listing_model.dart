/// Listing Model
///
/// Represents a livestock listing from the backend API
class ListingModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String age;
  final String price;
  final String location;
  final double rating;
  final bool isVerified;
  final String? species;
  final String? breed;
  final String? gender;
  final int? ageMonths;
  final String? currency;
  final String listingStatus;

  ListingModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.age,
    required this.price,
    required this.location,
    this.rating = 0.0,
    this.isVerified = false,
    this.species,
    this.breed,
    this.gender,
    this.ageMonths,
    this.currency,
    this.listingStatus = 'DRAFT',
  });

  /// Create from JSON response (API format)
  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Handle price formatting with currency
    String formattedPrice;
    final priceValue = json['price'];
    final currency = json['currency'] as String? ?? 'INR';
    
    if (priceValue is num) {
      // Format price with currency symbol
      final currencySymbol = currency == 'INR' ? '\u20B9' : currency;
      formattedPrice = '$currencySymbol${priceValue.toStringAsFixed(0)}';
    } else if (priceValue is String) {
      // Parse string price
      final numericPrice = double.tryParse(priceValue.replaceAll(RegExp(r'[^\d.]'), ''));
      if (numericPrice != null) {
        final currencySymbol = currency == 'INR' ? '\u20B9' : currency;
        formattedPrice = '$currencySymbol${numericPrice.toStringAsFixed(0)}';
      } else {
        formattedPrice = priceValue.startsWith('\u20B9') ? priceValue : '\u20B9$priceValue';
      }
    } else {
      formattedPrice = '\u20B90';
    }

    // Handle age formatting from age_months
    String formattedAge;
    final ageMonths = json['age_months'];
    
    if (ageMonths != null) {
      final months = ageMonths is num ? ageMonths.toInt() : int.tryParse(ageMonths.toString()) ?? 0;
      if (months >= 12) {
        final years = (months / 12).floor();
        final remainingMonths = months % 12;
        if (remainingMonths > 0) {
          formattedAge = '$years ${years == 1 ? 'Year' : 'Years'} $remainingMonths ${remainingMonths == 1 ? 'Month' : 'Months'}';
        } else {
          formattedAge = '$years ${years == 1 ? 'Year' : 'Years'}';
        }
      } else {
        formattedAge = '$months ${months == 1 ? 'Month' : 'Months'}';
      }
    } else {
      formattedAge = 'Unknown';
    }

    // Handle image URL - use primary_image from API
    final imageUrl = json['primary_image'] as String?;

    // Location is not yet handled by API - keep as Unknown
    String location = 'Unknown';
    
    // Handle farm object if present (for future use)
    final farm = json['farm'];
    if (farm is Map && farm['address'] != null) {
      location = farm['address'].toString();
    } else if (json['location'] != null) {
      location = json['location'].toString();
    }

    return ListingModel(
      id: json['listing_id'] as int? ?? json['id'] as int? ?? 0,
      name: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      imageUrl: imageUrl,
      age: formattedAge,
      price: formattedPrice,
      location: location,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      // Map is_featured to isVerified as requested
      isVerified: json['is_featured'] as bool? ?? json['is_verified'] as bool? ?? false,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      gender: json['gender'] as String?,
      ageMonths: json['age_months'] as int?,
      currency: currency,
      listingStatus: json['listing_status'] as String? ?? 'DRAFT',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'listing_id': id,
      'title': name,
      'primary_image': imageUrl,
      'age_months': ageMonths,
      'price': price,
      'location': location,
      'rating': rating,
      'is_featured': isVerified,
      'species': species,
      'breed': breed,
      'gender': gender,
      'currency': currency,
      'listing_status': listingStatus,
    };
  }

  /// Create a copy with updated fields
  ListingModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? age,
    String? price,
    String? location,
    double? rating,
    bool? isVerified,
    String? species,
    String? breed,
    String? gender,
    int? ageMonths,
    String? currency,
    String? listingStatus,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      age: age ?? this.age,
      price: price ?? this.price,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      ageMonths: ageMonths ?? this.ageMonths,
      currency: currency ?? this.currency,
      listingStatus: listingStatus ?? this.listingStatus,
    );
  }

  @override
  String toString() {
    return 'ListingModel(id: $id, name: $name, price: $price, location: $location)';
  }
}
