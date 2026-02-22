import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/profile/controllers/my_listings_controller.dart';
import 'package:flutter_app/features/profile/mixins/my_listings_state_mixin.dart';
import 'package:flutter_app/features/profile/widgets/listing_shimmer_card.dart';
import 'package:flutter_app/features/profile/widgets/listings_count_header.dart';
import 'package:flutter_app/features/profile/widgets/listings_filter_menu.dart';
import 'package:flutter_app/features/profile/widgets/my_listings_empty_state.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/shared/widgets/cards/listing_card.dart';

/// My Listings Page - Displays all user's listings
class MyListingsPage extends StatefulWidget {
  final bool showBackButton;
  
  const MyListingsPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage>
    with MyListingsStateMixin, ToastMixin {
  late MyListingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MyListingsController();

    // Add listener to rebuild when controller state changes
    _controller.addListener(_onControllerChanged);

    // Fetch listings after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListings();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Handle controller state changes
  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
      });

      // Show error if any (and clear it after showing)
      if (_controller.errorMessage != null) {
        showErrorToast(_controller.errorMessage!);
        _controller.clearError();
      }
    }
  }

  /// Fetch listings from API
  Future<void> _fetchListings() async {
    await _controller.fetchMyListings(status: selectedFilter);
    // No need for setState - listener handles it
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    await _controller.refreshListings();
    // No need for setState - listener handles it
  }

  /// Handle listing tap
  void _handleListingTap(ListingModel listing) {
    HomeNavigationService.toAnimalDetail(context, listing.id);
  }

  /// Handle filter change
  void _handleFilterChange(String? filter) {
    setFilter(filter); // From mixin
    _fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      child: Container(
        color: Colors.grey[100], // Add light grey background
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              // App Bar as Sliver
              SliverAppBar(
                backgroundColor: AppTheme.authPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: widget.showBackButton, // Show back button based on parameter
                leading: widget.showBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
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
                  ListingsFilterMenu(
                    currentFilter: selectedFilter,
                    onFilterChanged: _handleFilterChange,
                  ),
                ],
              ),
              // Body content as sliver
              SliverFillRemaining(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
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
      itemBuilder: (context, index) => const ListingShimmerCard(),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return MyListingsEmptyState(
      filterStatus: selectedFilter,
      onCreateListing: () {
        // Navigate to create listing
        Navigator.pop(context);
      },
    );
  }

  /// Build listings view
  Widget _buildListingsView() {
    return Column(
      children: [
        // Listings count header
        ListingsCountHeader(count: _controller.listingsCount),
        // Listings list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _controller.listings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final listing = _controller.listings[index];
              return Stack(
                children: [
                  ListingCard(
                    imageUrl: listing.imageUrl,
                    name: listing.name,
                    age: listing.age,
                    price: listing.price,
                    location: listing.location,
                    rating: listing.rating,
                    isVerified: listing.isVerified,
                    onTap: () => _handleListingTap(listing),
                  ),
                  // Edit icon button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _handleEditListing(listing),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: AppTheme.authPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Handle edit listing
  Future<void> _handleEditListing(ListingModel listing) async {
    final result = await Navigator.pushNamed(
      context, 
      AppRoutes.editListingDetails, 
      arguments: listing.id,
    );
    
    // Refresh listings if the edit was successful
    if (result == true && mounted) {
      await _fetchListings();
    }
  }
}
