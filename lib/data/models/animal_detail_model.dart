/// Animal Detail Model
///
/// Comprehensive model for animal listing details from the backend API.
/// Used in the Animal Detail Page to display full information.
class AnimalDetailModel {
  final int id;
  final String title;
  final String? description;
  final String? breed;
  final String? gender;
  final double price;
  final double? originalPrice;
  final String? currency;
  final bool isVerified;

  // Stats
  final int? ageMonths;
  final double? weightKg;
  final double? heightCm;
  final double? milkPerDay;
  final int? lactationNumber;
  final String? color;

  // AI Price Estimate
  final double? aiPriceMin;
  final double? aiPriceMax;
  final String? priceAssessment;

  // Health
  final String? healthStatus;
  final String? vaccinationStatus;
  final List<VaccinationRecord> vaccinations;

  // Images
  final List<String> imageUrls;
  final String? primaryImage;

  // Seller
  final SellerInfo? seller;

  // Farm/Location
  final FarmInfo? farm;

  // Transport
  final bool transportAvailable;
  final double? estimatedTransportCost;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnimalDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.breed,
    this.gender,
    required this.price,
    this.originalPrice,
    this.currency = 'INR',
    this.isVerified = false,
    this.ageMonths,
    this.weightKg,
    this.heightCm,
    this.milkPerDay,
    this.lactationNumber,
    this.color,
    this.aiPriceMin,
    this.aiPriceMax,
    this.priceAssessment,
    this.healthStatus,
    this.vaccinationStatus,
    this.vaccinations = const [],
    this.imageUrls = const [],
    this.primaryImage,
    this.seller,
    this.farm,
    this.transportAvailable = false,
    this.estimatedTransportCost,
    this.createdAt,
    this.updatedAt,
  });

  /// Helper to safely parse a double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    }
    return null;
  }

  /// Helper to safely parse an int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Create from JSON response
  factory AnimalDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse price
    double parsedPrice = _parseDouble(json['price']) ?? 0.0;

    // Parse original price if exists
    double? parsedOriginalPrice = _parseDouble(json['original_price'] ?? json['originalPrice']);

    // Parse images - check multiple possible field names
    List<String> images = [];
    final imageData = json['animal_images'] ?? json['images'] ?? json['image_urls'];
    if (imageData is List) {
      images = imageData
          .map((e) => e is Map ? (e['url'] ?? e['image_url'] ?? e['image'] ?? '').toString() : e.toString())
          .where((url) => url.isNotEmpty)
          .toList();
    }

    // Add primary image if not in list
    final primaryImg = json['primary_image'] as String? ??
                       json['image_url'] as String? ??
                       json['image'] as String?;
    if (primaryImg != null && primaryImg.isNotEmpty && !images.contains(primaryImg)) {
      images.insert(0, primaryImg);
    }

    // Parse vaccinations
    List<VaccinationRecord> vaccinationList = [];
    if (json['vaccinations'] is List) {
      vaccinationList = (json['vaccinations'] as List)
          .map((v) => VaccinationRecord.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    // Parse seller info
    SellerInfo? sellerInfo;
    if (json['seller'] is Map) {
      sellerInfo = SellerInfo.fromJson(json['seller'] as Map<String, dynamic>);
    } else if (json['owner'] is Map) {
      sellerInfo = SellerInfo.fromJson(json['owner'] as Map<String, dynamic>);
    }

    // Parse farm info
    FarmInfo? farmInfo;
    if (json['farm'] is Map) {
      farmInfo = FarmInfo.fromJson(json['farm'] as Map<String, dynamic>);
    }

    // Parse animal info for breed
    String? breed = json['breed'] as String?;
    if (breed == null && json['animal'] is Map) {
      final animal = json['animal'] as Map<String, dynamic>;
      breed = animal['breed'] as String? ?? animal['name'] as String?;
    }

    return AnimalDetailModel(
      id: _parseInt(json['listing_id']) ?? _parseInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Unknown',
      description: json['description']?.toString(),
      breed: breed,
      gender: json['gender']?.toString(),
      price: parsedPrice,
      originalPrice: parsedOriginalPrice,
      currency: json['currency']?.toString() ?? 'INR',
      isVerified: json['is_verified'] == true || json['verified'] == true,
      ageMonths: _parseInt(json['age_months']),
      weightKg: _parseDouble(json['weight_kg']),
      heightCm: _parseDouble(json['height_cm']),
      milkPerDay: _parseDouble(json['milk_per_day']) ?? _parseDouble(json['milk_yield']),
      lactationNumber: _parseInt(json['lactation_number']) ?? _parseInt(json['lactation']),
      color: json['color']?.toString(),
      aiPriceMin: _parseDouble(json['ai_price_min']),
      aiPriceMax: _parseDouble(json['ai_price_max']),
      priceAssessment: json['price_assessment']?.toString(),
      healthStatus: json['health_status']?.toString(),
      vaccinationStatus: json['vaccination_status']?.toString(),
      vaccinations: vaccinationList,
      imageUrls: images,
      primaryImage: primaryImg,
      seller: sellerInfo,
      farm: farmInfo,
      transportAvailable: json['transport_available'] == true,
      estimatedTransportCost: _parseDouble(json['estimated_transport_cost']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Get formatted price with currency symbol
  String get formattedPrice => '\u20B9${price.toStringAsFixed(0)}';

  /// Get formatted original price with currency symbol
  String? get formattedOriginalPrice =>
      originalPrice != null ? '\u20B9${originalPrice!.toStringAsFixed(0)}' : null;

  /// Get formatted age string
  String get formattedAge {
    if (ageMonths == null) return 'Unknown';
    if (ageMonths! >= 12) {
      final years = (ageMonths! / 12).floor();
      return '$years ${years == 1 ? 'Year' : 'Years'}';
    }
    return '$ageMonths ${ageMonths == 1 ? 'Month' : 'Months'}';
  }

  /// Get formatted weight string
  String? get formattedWeight => weightKg != null ? '${weightKg!.toStringAsFixed(0)} kg' : null;

  /// Get formatted milk per day string
  String? get formattedMilkPerDay =>
      milkPerDay != null ? '${milkPerDay!.toStringAsFixed(0)} Liters' : null;

  /// Get formatted lactation string
  String? get formattedLactation {
    if (lactationNumber == null) return null;
    final suffix = _getOrdinalSuffix(lactationNumber!);
    return '$lactationNumber$suffix';
  }

  /// Get ordinal suffix for a number
  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  /// Get breed and gender display string
  String get breedGenderDisplay {
    final parts = <String>[];
    if (breed != null && breed!.isNotEmpty) parts.add(breed!);
    if (gender != null && gender!.isNotEmpty) {
      parts.add(gender![0].toUpperCase() + gender!.substring(1).toLowerCase());
    }
    return parts.join(' \u2022 ');
  }

  /// Get location string
  String get location => farm?.address ?? 'Location not available';

  /// Check if AI price estimate is available
  bool get hasAiPriceEstimate => aiPriceMin != null && aiPriceMax != null;

  /// Get AI price range display
  String? get aiPriceRangeDisplay {
    if (!hasAiPriceEstimate) return null;
    return '\u20B9${aiPriceMin!.toStringAsFixed(0)} - \u20B9${aiPriceMax!.toStringAsFixed(0)}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'breed': breed,
      'gender': gender,
      'price': price,
      'original_price': originalPrice,
      'currency': currency,
      'is_verified': isVerified,
      'age_months': ageMonths,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'milk_per_day': milkPerDay,
      'lactation_number': lactationNumber,
      'color': color,
      'ai_price_min': aiPriceMin,
      'ai_price_max': aiPriceMax,
      'price_assessment': priceAssessment,
      'health_status': healthStatus,
      'vaccination_status': vaccinationStatus,
      'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
      'images': imageUrls,
      'primary_image': primaryImage,
      'seller': seller?.toJson(),
      'farm': farm?.toJson(),
      'transport_available': transportAvailable,
      'estimated_transport_cost': estimatedTransportCost,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Vaccination Record
class VaccinationRecord {
  final String name;
  final DateTime? date;
  final bool isCompleted;
  final String? notes;

  VaccinationRecord({
    required this.name,
    this.date,
    this.isCompleted = true,
    this.notes,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      name: json['name']?.toString() ?? json['vaccine_name']?.toString() ?? 'Unknown',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      isCompleted: json['is_completed'] == true || json['completed'] == true,
      notes: json['notes']?.toString(),
    );
  }

  /// Get formatted date string
  String get formattedDate {
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date!.month - 1]} ${date!.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date?.toIso8601String(),
      'is_completed': isCompleted,
      'notes': notes,
    };
  }
}

/// Seller Information
class SellerInfo {
  final int id;
  final String name;
  final String? profileImage;
  final String? location;
  final double rating;
  final int reviewCount;
  final String? phone;
  final bool isVerified;

  SellerInfo({
    required this.id,
    required this.name,
    this.profileImage,
    this.location,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.phone,
    this.isVerified = false,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    // Handle name from different fields
    String sellerName = 'Unknown Seller';
    if (json['name'] != null) {
      sellerName = json['name'].toString();
    } else if (json['first_name'] != null || json['last_name'] != null) {
      final firstName = json['first_name']?.toString() ?? '';
      final lastName = json['last_name']?.toString() ?? '';
      sellerName = '$firstName $lastName'.trim();
      if (sellerName.isEmpty) sellerName = 'Unknown Seller';
    } else if (json['username'] != null) {
      sellerName = json['username'].toString();
    }

    // Helper to parse int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper to parse double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return SellerInfo(
      id: parseInt(json['id']) ?? parseInt(json['user_id']) ?? 0,
      name: sellerName,
      profileImage: json['profile_image']?.toString() ??
                    json['avatar']?.toString() ??
                    json['image']?.toString(),
      location: json['location']?.toString() ?? json['address']?.toString(),
      rating: parseDouble(json['rating']) ?? 0.0,
      reviewCount: parseInt(json['review_count']) ?? parseInt(json['reviews']) ?? 0,
      phone: json['phone']?.toString() ?? json['phone_number']?.toString(),
      isVerified: json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'location': location,
      'rating': rating,
      'review_count': reviewCount,
      'phone': phone,
      'is_verified': isVerified,
    };
  }
}

/// Farm Information
class FarmInfo {
  final int? id;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? areaSqM;

  FarmInfo({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.areaSqM,
  });

  factory FarmInfo.fromJson(Map<String, dynamic> json) {
    // Helper to parse int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper to parse double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return FarmInfo(
      id: parseInt(json['id']) ?? parseInt(json['farm_id']),
      name: json['name']?.toString(),
      address: json['address']?.toString() ?? json['location']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      areaSqM: parseDouble(json['area_sq_m']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'area_sq_m': areaSqM,
    };
  }
}
