import 'package:flutter/material.dart';
import 'package:flutter_app/features/favourite/mixins/favourite_listings_state_mixin.dart';
import 'package:flutter_app/features/profile/models/listing_model.dart';
import 'package:flutter_app/features/viewalllistings/widgets/listing_card.dart';
import 'package:flutter_app/main.dart' show routeObserver;
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Favourite Listings Page
///
/// Shows user's favourite listings
/// Fetches from GET /api/auth/me/favorites/
class FavouriteListingsPage extends StatefulWidget {
  const FavouriteListingsPage({super.key});

  @override
  State<FavouriteListingsPage> createState() => _FavouriteListingsPageState();
}

class _FavouriteListingsPageState extends State<FavouriteListingsPage>
    with FavouriteListingsStateMixin, RouteAware {
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
    // Called when the top route has been popped off, and the current route shows up
    // This fires when user returns from animal detail page
    debugPrint(
      '[FavouriteListingsPage] 🔄 didPopNext - User returned, reloading favorites...',
    );
    fetchFavorites().then((_) {
      if (mounted) {
        setState(() {});
        debugPrint(
          '[FavouriteListingsPage] ✅ UI refreshed after loading favorites',
        );
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    disposeController(); // Call mixin's dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    debugPrint('[FavouriteListingsPage] Building page...');
    debugPrint('[FavouriteListingsPage] isLoading: ${controller.isLoading}');
    debugPrint(
      '[FavouriteListingsPage] errorMessage: ${controller.errorMessage}',
    );
    debugPrint(
      '[FavouriteListingsPage] hasFavorites: ${controller.hasFavorites}',
    );
    debugPrint(
      '[FavouriteListingsPage] favoritesCount: ${controller.favoritesCount}',
    );

    return Material(
      color: Colors.grey[100],
      child: Container(
        color: Colors.grey[100],
        child: CustomScrollView(
          slivers: [
            // App Bar as Sliver
            SliverAppBar(
              backgroundColor: AppTheme.authPrimaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              title: const Text(
                'Favourite Listings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),

            // Body content as sliver
            if (controller.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.authPrimaryColor,
                  ),
                ),
              )
            else if (controller.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: handleRefresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.authPrimaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (!controller.hasFavorites)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Favourite Listings Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start saving your favourite listings',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Favourite listings with count header
              SliverList(
                delegate: SliverChildListDelegate([
                  // Count header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '${controller.favoritesCount} ${controller.favoritesCount == 1 ? 'Listing' : 'Listings'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  // Grid of favourite listings
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.70,
                          ),
                      itemCount: controller.favoritesCount,
                      itemBuilder: (context, index) {
                        final favorite = controller.favorites[index];
                        final listing = controller.getListingFromFavorite(
                          favorite,
                        );

                        if (listing == null) return const SizedBox();

                        final listingModel = ListingModel.fromJson(listing);

                        return ListingCard(
                          listing: listingModel,
                          onTap: () => handleListingTap(listing),
                          onFavoriteTap: () =>
                              handleRemoveFavorite(listingModel.id),
                          isFavorite: true,
                        );
                      },
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
