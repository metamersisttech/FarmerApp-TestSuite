import 'package:flutter/material.dart';

/// Image Gallery Section for Animal Detail Page
///
/// Displays a hero image carousel with thumbnails, back button, and share/favorite buttons.
class ImageGallerySection extends StatelessWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onBackTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const ImageGallerySection({
    super.key,
    required this.imageUrls,
    required this.currentIndex,
    required this.pageController,
    this.onPageChanged,
    this.onBackTap,
    this.onShareTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = imageUrls.isNotEmpty;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // Image Carousel
          if (hasImages)
            PageView.builder(
              controller: pageController,
              itemCount: imageUrls.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                );
              },
            )
          else
            _buildPlaceholder(),

          // Top Row: Back Button + Share/Favorite
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: onBackTap,
                ),
                // Share & Favorite
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.share_outlined,
                      onTap: onShareTap,
                    ),
                    const SizedBox(width: 8),
                    _CircleButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorite ? Colors.red : null,
                      onTap: onFavoriteTap,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom: Thumbnails
          if (hasImages && imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildThumbnails(),
            ),
        ],
      ),
    );
  }

  /// Build placeholder for no images
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.pets,
          size: 80,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  /// Build thumbnail indicators
  Widget _buildThumbnails() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(imageUrls.length, (index) {
            final isActive = index == currentIndex;
            return GestureDetector(
              onTap: () {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: isActive ? 32 : 24,
                height: isActive ? 32 : 24,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey.shade300);
                    },
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Circle button for back/share/favorite actions
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.grey.shade800,
          size: 20,
        ),
      ),
    );
  }
}
