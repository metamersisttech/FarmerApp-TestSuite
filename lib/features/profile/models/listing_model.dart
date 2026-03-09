/// Farm Model (nested in listing)
class FarmModel {
  final int farmId;
  final String name;
  final String? areaSqM;
  final String? address;
  final String? latitude;
  final String? longitude;
  final DateTime? createdAt;

  FarmModel({
    required this.farmId,
    required this.name,
    this.areaSqM,
    this.address,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      farmId: json['farm_id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      areaSqM: json['area_sq_m']?.toString(),
      address: json['address'] as String?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farm_id': farmId,
      'name': name,
      'area_sq_m': areaSqM,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

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
  final DateTime? postedAt;
  final String? lat;
  final String? lon;
  final FarmModel? farm;
  final bool isFeatured;
  final int? views;
  final String? sellerName;
  final String? imageCount;
  final String? healthStatus;

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
    this.postedAt,
    this.lat,
    this.lon,
    this.farm,
    this.isFeatured = false,
    this.views,
    this.sellerName,
    this.imageCount,
    this.healthStatus,
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

    // Handle farm object
    FarmModel? farmModel;
    final farmJson = json['farm'];
    if (farmJson is Map<String, dynamic>) {
      farmModel = FarmModel.fromJson(farmJson);
    }

    // Determine location from multiple sources
    String location = 'Unknown';
    if (json['location'] != null && json['location'].toString().isNotEmpty) {
      location = json['location'].toString();
    } else if (farmModel?.address != null && farmModel!.address!.isNotEmpty) {
      location = farmModel.address!;
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
      postedAt: json['posted_at'] != null 
          ? DateTime.tryParse(json['posted_at'] as String)
          : null,
      lat: json['lat']?.toString(),
      lon: json['lon']?.toString(),
      farm: farmModel,
      isFeatured: json['is_featured'] as bool? ?? false,
      views: json['views'] as int?,
      sellerName: json['seller_name'] as String?,
      imageCount: json['image_count']?.toString(),
      healthStatus: json['health_status'] as String?,
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
      'is_featured': isFeatured,
      'species': species,
      'breed': breed,
      'gender': gender,
      'currency': currency,
      'listing_status': listingStatus,
      'posted_at': postedAt?.toIso8601String(),
      'lat': lat,
      'lon': lon,
      'farm': farm?.toJson(),
      'views': views,
      'seller_name': sellerName,
      'image_count': imageCount,
      'health_status': healthStatus,
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
    DateTime? postedAt,
    String? lat,
    String? lon,
    FarmModel? farm,
    bool? isFeatured,
    int? views,
    String? sellerName,
    String? imageCount,
    String? healthStatus,
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
      postedAt: postedAt ?? this.postedAt,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      farm: farm ?? this.farm,
      isFeatured: isFeatured ?? this.isFeatured,
      views: views ?? this.views,
      sellerName: sellerName ?? this.sellerName,
      imageCount: imageCount ?? this.imageCount,
      healthStatus: healthStatus ?? this.healthStatus,
    );
  }

  @override
  String toString() {
    return 'ListingModel(id: $id, name: $name, price: $price, location: $location)';
  }
}
