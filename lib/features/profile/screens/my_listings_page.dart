import 'package:flutter/material.dart';
import 'package:flutter_app/core/mixins/toast_mixin.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
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
                  // Status badge (top-left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildStatusBadge(listing.listingStatus),
                  ),
                  // Action menu (top-right)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildActionMenu(listing),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build status badge widget
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'PUBLISHED':
        bgColor = Colors.purple;
        textColor = Colors.white;
        label = 'Published';
        break;
      case 'SOLD':
        bgColor = Colors.blue;
        textColor = Colors.white;
        label = 'Sold';
        break;
      case 'DRAFT':
      default:
        bgColor = Colors.amber;
        textColor = Colors.black87;
        label = 'Draft';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build action menu for a listing
  Widget _buildActionMenu(ListingModel listing) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          size: 20,
          color: AppTheme.authPrimaryColor,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 20,
        onSelected: (value) => _handleMenuAction(value, listing),
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, size: 20, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ];

          if (listing.listingStatus == 'DRAFT') {
            items.add(const PopupMenuItem(
              value: 'publish',
              child: ListTile(
                leading: Icon(Icons.publish, size: 20, color: Colors.purple),
                title: Text('Publish'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ));
          }

          if (listing.listingStatus == 'PUBLISHED') {
            items.add(const PopupMenuItem(
              value: 'unpublish',
              child: ListTile(
                leading: Icon(Icons.unpublished, size: 20, color: Colors.orange),
                title: Text('Unpublish'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ));
            items.add(const PopupMenuItem(
              value: 'sold',
              child: ListTile(
                leading: Icon(Icons.sell, size: 20, color: Colors.blue),
                title: Text('Mark as Sold'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ));
          }

          return items;
        },
      ),
    );
  }

  /// Handle menu action selection
  Future<void> _handleMenuAction(String action, ListingModel listing) async {
    switch (action) {
      case 'edit':
        _handleEditListing(listing);
        break;
      case 'delete':
        _handleDeleteListing(listing);
        break;
      case 'publish':
        final success = await _controller.publishListing(listing.id);
        if (success && mounted) {
          showSuccessToast('Listing published successfully');
        }
        break;
      case 'unpublish':
        final success = await _controller.unpublishListing(listing.id);
        if (success && mounted) {
          showSuccessToast('Listing unpublished');
        }
        break;
      case 'sold':
        final success = await _controller.markAsSold(listing.id);
        if (success && mounted) {
          showSuccessToast('Listing marked as sold');
        }
        break;
    }
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

  /// Handle delete listing
  Future<void> _handleDeleteListing(ListingModel listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text(
          'Are you sure you want to delete "${listing.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _controller.deleteListing(listing.id);
      if (success && mounted) {
        showSuccessToast('Listing deleted successfully');
      }
    }
  }
}
