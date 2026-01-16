import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/mixins/animal_detail_state_mixin.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/ai_price_estimate_card.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/animal_stats_row.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/basic_info_section.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/bottom_action_bar.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/health_vaccination_section.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/image_gallery_section.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/seller_info_card.dart';
import 'package:flutter_app/features/home/widgets/animal_detail/transport_section.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Animal Detail Page
///
/// Displays comprehensive information about a livestock listing.
/// Includes image gallery, price, stats, health info, seller info, and transport.
/// 
/// Architecture:
/// - UI only (build methods)
/// - Functionality in AnimalDetailStateMixin
/// - Business logic in AnimalDetailController
/// - Data operations in AnimalDetailService
class AnimalDetailPage extends StatefulWidget {
  final int listingId;

  const AnimalDetailPage({
    super.key,
    required this.listingId,
  });

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage>
    with AnimalDetailStateMixin {
  
  @override
  int get listingId => widget.listingId;

  @override
  void initState() {
    super.initState();
    initializeAnimalDetail();

    // Fetch animal details after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDetails();
    });
  }

  @override
  void dispose() {
    disposeAnimalDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: controller.isLoading
          ? _buildLoadingState()
          : controller.errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: controller.hasData
          ? BottomActionBar(
              onCallTap: handleCallTap,
              onChatTap: handleChatTap,
              onVideoTap: handleVideoTap,
              onBuyNowTap: handleBuyNowTap,
            )
          : null,
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.authPrimaryColor,
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'An error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: handleBackTap,
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: fetchDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.authPrimaryColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build main content
  Widget _buildContent() {
    final animal = controller.animalDetail;
    if (animal == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          ImageGallerySection(
            imageUrls: animal.imageUrls,
            currentIndex: currentImageIndex,
            pageController: imagePageController,
            onPageChanged: setImageIndex,
            onBackTap: handleBackTap,
            onShareTap: handleShareTap,
            onFavoriteTap: handleFavoriteTap,
            isFavorite: controller.isFavorite,
          ),

          // Basic Info (Name, Breed, Price)
          BasicInfoSection(
            name: animal.title,
            breedGender: animal.breedGenderDisplay,
            price: animal.formattedPrice,
            originalPrice: animal.formattedOriginalPrice,
            isVerified: animal.isVerified,
          ),

          // AI Price Estimate
          if (animal.hasAiPriceEstimate)
            AiPriceEstimateCard(
              priceRange: animal.aiPriceRangeDisplay!,
              assessment: animal.priceAssessment ?? 'Fair Price',
            ),

          // Stats Row (Age, Weight, Milk, Lactation)
          AnimalStatsRow(
            age: animal.formattedAge,
            weight: animal.formattedWeight,
            milkPerDay: animal.formattedMilkPerDay,
            lactation: animal.formattedLactation,
          ),

          // Health & Vaccination
          if (animal.vaccinations.isNotEmpty)
            HealthVaccinationSection(
              vaccinations: animal.vaccinations,
              healthStatus: animal.healthStatus,
            ),

          // Seller Info
          if (animal.seller != null)
            SellerInfoCard(
              seller: animal.seller!,
              onContactTap: handleSellerContactTap,
            ),

          // Transport Section
          if (animal.transportAvailable)
            TransportSection(
              isAvailable: animal.transportAvailable,
              estimatedCost: animal.estimatedTransportCost,
              onBookTap: handleBookTransportTap,
            ),

          // Bottom padding for bottom action bar
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
