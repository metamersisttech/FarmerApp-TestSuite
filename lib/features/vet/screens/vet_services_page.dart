import 'package:flutter/material.dart';
import 'package:flutter_app/features/vet/mixins/vet_state_mixin.dart';
import 'package:flutter_app/features/vet/widgets/breed_filter_chips.dart';
import 'package:flutter_app/features/vet/widgets/vet_card.dart';
import 'package:flutter_app/features/vet/widgets/vet_promo_banner.dart';
import 'package:flutter_app/features/vet/widgets/vet_search_bar.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Vet Services Page
///
/// Main screen for browsing and booking veterinary services.
/// Features search, breed filtering, promo banner, and vet listings.
///
/// Architecture:
/// - UI only in this file (build methods)
/// - State management in VetStateMixin
/// - Business logic in VetController
/// - Data operations in VetService
class VetServicesPage extends StatefulWidget {
  const VetServicesPage({super.key});

  @override
  State<VetServicesPage> createState() => _VetServicesPageState();
}

class _VetServicesPageState extends State<VetServicesPage> with VetStateMixin {
  @override
  void initState() {
    super.initState();
    initializeVetController();

    // Load data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadVets();
    });
  }

  @override
  void dispose() {
    disposeVetController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: VetSearchBar(
              controller: searchController,
              onChanged: handleSearch,
            ),
          ),

          // Breed filter chips
          BreedFilterChips(
            breeds: vetController.breeds,
            selectedBreed: vetController.selectedBreed,
            onSelected: handleBreedSelected,
          ),

          const SizedBox(height: 16),

          // Scrollable content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: handleBackTap,
      ),
      title: const Text(
        'Vet Services',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    if (vetController.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (vetController.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              vetController.errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadVets,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredVets = vetController.filteredVets;

    if (filteredVets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No vets found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promo banner
          VetPromoBanner(onBookNowTap: handlePromoBannerTap),

          const SizedBox(height: 20),

          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Vets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${filteredVets.length} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Vet cards list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: filteredVets.length,
            itemBuilder: (context, index) {
              final vet = filteredVets[index];
              return VetCard(
                vet: vet,
                onTap: () => handleVetCardTap(vet),
                onCallTap: () => handleCallTap(vet),
                onVideoTap: () => handleVideoTap(vet),
                onChatTap: () => handleChatTap(vet),
                onBookTap: () => handleBookTap(vet),
              );
            },
          ),
        ],
      ),
    );
  }
}
