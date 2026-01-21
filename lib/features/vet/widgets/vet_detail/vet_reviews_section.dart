import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/models/vet_review_model.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Reviews section displaying rating breakdown and review list
class VetReviewsSection extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<VetReviewModel> reviews;

  const VetReviewsSection({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.reviews = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              const Icon(
                Icons.star_outline,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$reviewCount reviews',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating summary
          _buildRatingSummary(),
          const SizedBox(height: 20),
          // Divider
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 16),
          // Reviews list
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No reviews yet',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.grey[200], height: 1),
              ),
              itemBuilder: (context, index) {
                return _buildReviewItem(reviews[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        // Large rating display
        Column(
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor()
                      ? Icons.star
                      : (index < rating ? Icons.star_half : Icons.star_border),
                  color: Colors.amber,
                  size: 18,
                );
              }),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Rating distribution
        Expanded(
          child: Column(
            children: [
              _buildRatingBar(5, _getRatingPercentage(5)),
              const SizedBox(height: 4),
              _buildRatingBar(4, _getRatingPercentage(4)),
              const SizedBox(height: 4),
              _buildRatingBar(3, _getRatingPercentage(3)),
              const SizedBox(height: 4),
              _buildRatingBar(2, _getRatingPercentage(2)),
              const SizedBox(height: 4),
              _buildRatingBar(1, _getRatingPercentage(1)),
            ],
          ),
        ),
      ],
    );
  }

  double _getRatingPercentage(int star) {
    if (reviews.isEmpty) return 0;
    final count = reviews.where((r) => r.rating.round() == star).length;
    return count / reviews.length;
  }

  Widget _buildRatingBar(int star, double percentage) {
    return Row(
      children: [
        Text(
          '$star',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(VetReviewModel review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Reviewer avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  review.initials,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Reviewer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Star rating
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating.floor()
                              ? Icons.star
                              : (index < review.rating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        review.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Animal type tag
            if (review.animalType != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.animalType!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Review text
        Text(
          review.reviewText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
