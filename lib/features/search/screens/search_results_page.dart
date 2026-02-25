import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Search Results Page
///
/// Displays search results in a grid view (same UI as Browse Livestock)
class SearchResultsPage extends StatelessWidget {
  final String query;
  final List<dynamic> results;
  final VoidCallback onBack;

  const SearchResultsPage({
    super.key,
    required this.query,
    required this.results,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Results',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            '${results.length} results for "$query"',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (results.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh
      },
      color: AppTheme.authPrimaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          
          // Convert to ListingModel to use ListingCard widget (same as Browse Livestock)
          if (item is Map) {
            try {
              // Cast to Map<String, dynamic> for ListingModel.fromJson
              final jsonMap = Map<String, dynamic>.from(item);
              final listing = ListingModel.fromJson(jsonMap);
              return ListingCard(
                listing: listing,
                onTap: () {
                  HomeNavigationService.toAnimalDetail(context, listing.id);
                },
                onFavoriteTap: () {
                  // TODO: Implement favorite functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorite feature coming soon!')),
                  );
                },
              );
            } catch (e) {
              // Fallback if conversion fails
              return const SizedBox.shrink();
            }
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search query',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
