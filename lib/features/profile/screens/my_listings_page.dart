import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/profile/controllers/my_listings_controller.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/cards/listing_card.dart';

/// My Listings Page - Displays all user's listings
class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  late MyListingsController _controller;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _controller = MyListingsController();
    
    // Fetch listings after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListings();
    });
  }

  /// Fetch listings from API
  Future<void> _fetchListings() async {
    await _controller.fetchMyListings(status: _selectedFilter);

    if (!mounted) return;

    // Show error if any
    if (_controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }

    setState(() {});
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    await _controller.refreshListings();
    
    if (!mounted) return;
    
    setState(() {});
  }

  /// Handle listing tap
  void _handleListingTap(ListingModel listing) {
    HomeNavigationService.toAnimalDetail(context, listing.id);
  }

  /// Handle filter change
  void _handleFilterChange(String? filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _fetchListings();
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(),
      ),
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.authPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'My Listings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // Filter button
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onSelected: _handleFilterChange,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: null,
              child: Text('All Listings'),
            ),
            const PopupMenuItem(
              value: 'active',
              child: Text('Active'),
            ),
            const PopupMenuItem(
              value: 'sold',
              child: Text('Sold'),
            ),
            const PopupMenuItem(
              value: 'expired',
              child: Text('Expired'),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the body
  Widget _buildBody() {
    if (_controller.isLoading && _controller.listings.isEmpty) {
      return _buildLoadingState();
    }

    if (_controller.listings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildListingsView();
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  /// Build shimmer loading card
  Widget _buildShimmerCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 18,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.post_add,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                _selectedFilter != null
                    ? 'No ${_selectedFilter} listings'
                    : 'No listings yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedFilter != null
                    ? 'Try changing the filter to see other listings'
                    : 'Start posting your animals for sale',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to create listing
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.authPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create Listing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build listings view
  Widget _buildListingsView() {
    return Column(
      children: [
        // Listings count header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Text(
            '${_controller.listingsCount} ${_controller.listingsCount == 1 ? 'Listing' : 'Listings'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        // Listings list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _controller.listings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final listing = _controller.listings[index];
              return ListingCard(
                imageUrl: listing.imageUrl,
                name: listing.name,
                age: listing.age,
                price: listing.price,
                location: listing.location,
                rating: listing.rating,
                isVerified: listing.isVerified,
                onTap: () => _handleListingTap(listing),
              );
            },
          ),
        ),
      ],
    );
  }
}
