import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Media cache configuration for images
/// 
/// Separate from data cache - handles image files independently.
/// Uses cached_network_image package for progressive loading.
class MediaCacheConfig {
  /// Custom cache manager for listing images
  static final imageCache = CacheManager(
    Config(
      'listingImages', // Cache key prefix
      stalePeriod: const Duration(days: 7), // TTL
      maxNrOfCacheObjects: 200, // Max images
      repo: JsonCacheInfoRepository(databaseName: 'listingImages'),
      fileService: HttpFileService(),
    ),
  );
  
  /// Clear image cache (useful for testing or low storage)
  static Future<void> clearImageCache() async {
    await imageCache.emptyCache();
    print('🗑️ Image cache cleared');
  }
}