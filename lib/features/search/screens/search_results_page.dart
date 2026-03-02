import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/data/models/listing_model.dart';
import 'package:flutter_app/features/home/services/home_navigation_service.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_card.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/main.dart' show routeObserver;

/// Search Results Page
///
/// Displays search results in a grid view (same UI as Browse Livestock)
class SearchResultsPage extends StatefulWidget {
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
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> with RouteAware {
  final BackendHelper _backendHelper = BackendHelper();
  Set<int> _favoriteListingIds = {};
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    
    // Load favorites after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    // Called when user returns from animal detail page
    print('[SearchResults] 🔄 didPopNext - User returned from detail page, reloading favorites...');
    _loadFavorites();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Load user's favorites
  Future<void> _loadFavorites() async {
    try {
      print('[SearchResults] 🔍 Loading favorites...');
      final favorites = await _backendHelper.getFavorites();
      
      // Handle both List and paginated response
      List<dynamic> favoritesList = [];
      if (favorites is Map && favorites['results'] != null) {
        favoritesList = favorites['results'] as List<dynamic>;
      } else if (favorites is List) {
        favoritesList = favorites;
      }
      
      // Extract listing IDs from favorites
      _favoriteListingIds = favoritesList.map((fav) {
        if (fav is Map) {
          final listing = fav['listing'];
          if (listing is Map) {
            // Check for both 'listing_id' and 'id' fields in nested listing
            if (listing['listing_id'] != null) {
              return listing['listing_id'] as int;
            }
            if (listing['id'] != null) {
              return listing['id'] as int;
            }
          }
          // Fallback to listing_id field at root level
          if (fav['listing_id'] != null) {
            return fav['listing_id'] as int;
          }
        }
        return null;
      }).whereType<int>().toSet();
      
      print('[SearchResults] ✅ Loaded ${_favoriteListingIds.length} favorite IDs: $_favoriteListingIds');
      
      if (mounted) {
        setState(() {
          _favoritesLoaded = true;
        });
      }
    } catch (e) {
      print('[SearchResults] ❌ Error loading favorites: $e');
      // Don't fail the whole page if favorites fail to load
      if (mounted) {
        setState(() {
          _favoritesLoaded = true;
        });
      }
    }
  }

  /// Check if a listing is favorited
  bool _isListingFavorited(int listingId) {
    return _favoriteListingIds.contains(listingId);
  }

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
        onPressed: widget.onBack,
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
            '${widget.results.length} results for "${widget.query}"',
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
    if (widget.results.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadFavorites();
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
        itemCount: widget.results.length,
        itemBuilder: (context, index) {
          final item = widget.results[index];
          
          // Convert to ListingModel to use ListingCard widget (same as Browse Livestock)
          if (item is Map) {
            try {
              // Cast to Map<String, dynamic> for ListingModel.fromJson
              final jsonMap = Map<String, dynamic>.from(item);
              final listing = ListingModel.fromJson(jsonMap);
              final isFavorited = _favoritesLoaded ? _isListingFavorited(listing.id) : false;
              
              return ListingCard(
                listing: listing,
                onTap: () {
                  HomeNavigationService.toAnimalDetail(context, listing.id);
                },
                onFavoriteTap: null, // Disable toggle on listing cards
                isFavorite: isFavorited,
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
