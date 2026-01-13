import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/home/controllers/animal_detail_controller.dart';
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
    with AnimalDetailStateMixin, ToastMixin {
  late final AnimalDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimalDetailController();
    initImageController();

    // Fetch animal details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    disposeImageController();
    super.dispose();
  }

  /// Fetch animal details from API
  Future<void> _fetchDetails() async {
    await _controller.fetchAnimalDetail(widget.listingId);

    if (!mounted) return;

    setState(() {});

    if (_controller.errorMessage != null) {
      showErrorToast(_controller.errorMessage!);
    }
  }

  /// Handle back button tap
  void _handleBackTap() {
    Navigator.of(context).pop();
  }

  /// Handle share button tap
  void _handleShareTap() {
    _controller.shareAnimal();
    showComingSoonAction('Share');
  }

  /// Handle favorite button tap
  void _handleFavoriteTap() {
    _controller.toggleFavorite();
    setState(() {});
    showSuccessToast(
      _controller.isFavorite ? 'Added to favorites' : 'Removed from favorites',
    );
  }

  /// Handle call button tap
  void _handleCallTap() {
    showComingSoonAction('Call');
  }

  /// Handle chat button tap
  void _handleChatTap() {
    showComingSoonAction('Chat');
  }

  /// Handle video button tap
  void _handleVideoTap() {
    showComingSoonAction('Video call');
  }

  /// Handle buy now button tap
  void _handleBuyNowTap() {
    showComingSoonAction('Buy Now');
  }

  /// Handle book transport tap
  void _handleBookTransportTap() {
    showComingSoonAction('Book Transport');
  }

  /// Handle seller contact tap
  void _handleSellerContactTap() {
    showComingSoonAction('Contact Seller');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller.isLoading
          ? _buildLoadingState()
          : _controller.errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: _controller.hasData
          ? BottomActionBar(
              onCallTap: _handleCallTap,
              onChatTap: _handleChatTap,
              onVideoTap: _handleVideoTap,
              onBuyNowTap: _handleBuyNowTap,
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
              _controller.errorMessage ?? 'An error occurred',
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
                  onPressed: _handleBackTap,
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _fetchDetails,
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
    final animal = _controller.animalDetail;
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
            onBackTap: _handleBackTap,
            onShareTap: _handleShareTap,
            onFavoriteTap: _handleFavoriteTap,
            isFavorite: _controller.isFavorite,
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
              onContactTap: _handleSellerContactTap,
            ),

          // Transport Section
          if (animal.transportAvailable)
            TransportSection(
              isAvailable: animal.transportAvailable,
              estimatedCost: animal.estimatedTransportCost,
              onBookTap: _handleBookTransportTap,
            ),

          // Bottom padding for bottom action bar
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
