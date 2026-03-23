import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/widgets/quick_actions_section.dart';
import 'package:flutter_app/features/home/widgets/recent_listing_section.dart';
import 'package:flutter_app/features/home/widgets/recently_viewed_section.dart';
import 'package:flutter_app/features/home/widgets/scrolling_templates.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';

/// Scrollable content section for home page
class HomeContent extends StatelessWidget {
  final List<TemplateCardData> templates;
  final VoidCallback onMarketplaceTap;
  final VoidCallback onVetServicesTap;
  final List<ListingModel> recentlyViewedListings;
  final bool isLoadingRecentlyViewed;
  final Function(dynamic) onListingTap;
  final VoidCallback onViewAllRecentlyViewed;
  final bool Function(int) isFavorite;
  final List<ListingModel> freshListings;
  final bool isLoadingFreshListings;
  final VoidCallback onViewAllFreshListings;

  const HomeContent({
    super.key,
    required this.templates,
    required this.onMarketplaceTap,
    required this.onVetServicesTap,
    required this.recentlyViewedListings,
    required this.isLoadingRecentlyViewed,
    required this.onListingTap,
    required this.onViewAllRecentlyViewed,
    required this.isFavorite,
    required this.freshListings,
    required this.isLoadingFreshListings,
    required this.onViewAllFreshListings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Scrolling Templates
          ScrollingTemplates(templates: templates),

          // Quick Actions Section
          QuickActionsSection(
            onMarketplaceTap: onMarketplaceTap,
            onVetServicesTap: onVetServicesTap,
          ),

          // Recently Viewed Ads Section
          RecentlyViewedSection(
            listings: recentlyViewedListings,
            isLoading: isLoadingRecentlyViewed,
            onListingTap: onListingTap,
            onViewAll: onViewAllRecentlyViewed,
            isFavorite: isFavorite,
          ),

          // Fresh Recommendations Section
          RecentListingSection(
            title: 'Fresh recommendations',
            listings: freshListings,
            isLoading: isLoadingFreshListings,
            onActionPressed: onViewAllFreshListings,
            onListingTap: onListingTap,
          ),

          // Bottom padding for bottom nav bar
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
