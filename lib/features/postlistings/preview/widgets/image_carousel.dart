import 'package:flutter/material.dart';

/// Image Carousel Widget
class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final PageController imagePageController;
  final int currentImageIndex;
  final Function(int) onPageChanged;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    required this.imagePageController,
    required this.currentImageIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280,
          color: Colors.grey[200],
          child: imageUrls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('No images',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: imagePageController,
                  itemCount: imageUrls.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.grey[500]),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        if (imageUrls.isNotEmpty)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${imageUrls.length} Photos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
