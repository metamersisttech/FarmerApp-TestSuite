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

  ListingModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.age,
    required this.price,
    required this.location,
    this.rating = 0.0,
    this.isVerified = false,
  });

  /// Create from JSON response
  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Handle price formatting
    String formattedPrice;
    final priceValue = json['price'];
    if (priceValue is num) {
      formattedPrice = '\u20B9${priceValue.toStringAsFixed(0)}';
    } else if (priceValue is String) {
      formattedPrice = priceValue.startsWith('\u20B9') ? priceValue : '\u20B9$priceValue';
    } else {
      formattedPrice = '\u20B90';
    }

    // Handle age formatting
    String formattedAge;
    final ageValue = json['age'];
    if (ageValue is num) {
      formattedAge = '$ageValue Years';
    } else if (ageValue is String) {
      formattedAge = ageValue;
    } else {
      formattedAge = 'Unknown';
    }

    return ListingModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? json['title'] as String? ?? 'Unknown',
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      age: formattedAge,
      price: formattedPrice,
      location: json['location'] as String? ?? 'Unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? json['verified'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'age': age,
      'price': price,
      'location': location,
      'rating': rating,
      'is_verified': isVerified,
    };
  }

  @override
  String toString() {
    return 'ListingModel(id: $id, name: $name, price: $price, location: $location)';
  }
}
