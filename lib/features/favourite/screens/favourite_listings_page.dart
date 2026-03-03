import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/home/screens/animal_detail_page.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Favourite Listings Page
///
/// Displays the user's saved/favourite listings.
/// Fetches from GET /api/auth/me/favorites/
class FavouriteListingsPage extends StatefulWidget {
  const FavouriteListingsPage({super.key});

  @override
  State<FavouriteListingsPage> createState() => _FavouriteListingsPageState();
}

class _FavouriteListingsPageState extends State<FavouriteListingsPage> {
  final BackendHelper _backendHelper = BackendHelper();
  final CommonHelper _commonHelper = CommonHelper();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accessToken = await _commonHelper.getAccessToken();
      if (accessToken != null) {
        APIClient().setAuthorization(accessToken);
      }

      final data = await _backendHelper.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = data is List ? data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load favorites';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(int listingId, int index) async {
    try {
      await _backendHelper.deleteFavoriteByListingId(listingId);
      if (mounted) {
        setState(() {
          _favorites.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove from favorites')),
        );
      }
    }
  }

  void _navigateToDetail(int listingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalDetailPage(listingId: listingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Saved Listings'),
        backgroundColor: AppTheme.authPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No saved listings yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on listings to save them',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final fav = _favorites[index];
          final listing = fav is Map ? (fav['listing'] ?? fav) : fav;
          final listingId = listing is Map ? (listing['id'] as int?) : null;
          final title = listing is Map ? (listing['title'] ?? 'Untitled') : 'Untitled';
          final price = listing is Map ? listing['price'] : null;
          final images = listing is Map ? (listing['images'] as List?) : null;
          final imageUrl = (images != null && images.isNotEmpty)
              ? (images[0] is Map ? images[0]['image'] : images[0])
              : null;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: listingId != null ? () => _navigateToDetail(listingId) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null
                          ? Image.network(
                              CommonHelper.getImageUrl(imageUrl.toString()),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (price != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '\u20B9$price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.authPrimaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Remove button
                    if (listingId != null)
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeFavorite(listingId, index),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
