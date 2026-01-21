/// Vet review data model representing a review for a veterinarian
class VetReviewModel {
  final int id;
  final String reviewerName;
  final String? reviewerImage;
  final double rating;
  final String reviewText;
  final DateTime reviewDate;
  final String? animalType;

  const VetReviewModel({
    required this.id,
    required this.reviewerName,
    this.reviewerImage,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
    this.animalType,
  });

  /// Create VetReviewModel from JSON (for future API integration)
  factory VetReviewModel.fromJson(Map<String, dynamic> json) {
    return VetReviewModel(
      id: json['id'] as int,
      reviewerName: json['reviewer_name'] as String,
      reviewerImage: json['reviewer_image'] as String?,
      rating: (json['rating'] as num).toDouble(),
      reviewText: json['review_text'] as String,
      reviewDate: DateTime.parse(json['review_date'] as String),
      animalType: json['animal_type'] as String?,
    );
  }

  /// Convert VetReviewModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer_name': reviewerName,
      'reviewer_image': reviewerImage,
      'rating': rating,
      'review_text': reviewText,
      'review_date': reviewDate.toIso8601String(),
      'animal_type': animalType,
    };
  }

  /// Get initials from reviewer name
  String get initials {
    return reviewerName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  /// Format the review date for display
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[reviewDate.month - 1]} ${reviewDate.day}, ${reviewDate.year}';
  }
}
