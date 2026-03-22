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
import 'package:flutter_app/features/transport/screens/farmer/book_transport_screen.dart';
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

  const AnimalDetailPage({super.key, required this.listingId});

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAnimalDetail(listingId);
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
              onCallTap: () => controller.handleCall(),
              onChatTap: () => controller.handleChat(context, listingId),
              onVideoTap: () => controller.handleVideo(),
              onBuyNowTap: () => controller.handleBuyNow(),
              isOwner: controller.isOwner,
              onViewBidsTap: () => controller.navigateToViewBids(context, listingId),
            )
          : null,
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.authPrimaryColor),
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
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => controller.navigateBack(context),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => controller.fetchAnimalDetail(listingId),
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
            onBackTap: () => controller.navigateBack(context),
            onShareTap: () => controller.handleShare(),
            onFavoriteTap: () => controller.toggleFavorite(),
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
              onContactTap: () => controller.handleSellerContact(),
            ),

          // Transport Section
          TransportSection(
            isAvailable: animal.transportAvailable || true,
            estimatedCost: animal.estimatedTransportCost ?? 3500,
            onBookTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookTransportScreen(
                  listingId: animal.id,
                  animalName: animal.title,
                  sellerLocation: animal.seller?.location ?? animal.location,
                  animalSpecies: animal.breed,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
