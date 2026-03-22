import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';
import 'package:flutter_app/features/home/services/animal_detail_service.dart';
import 'package:flutter_app/features/messaging/services/messaging_service.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// Animal Detail Controller
///
/// Manages the state and business logic for the Animal Detail page.
/// Uses AnimalDetailService for data operations.
/// Handles all business decisions and navigation logic.
class AnimalDetailController extends BaseController {
  final AnimalDetailService _animalDetailService;
  final MessagingService _messagingService;
  final CommonHelper _commonHelper;
  
  // Callbacks
  Function(String)? onShowComingSoon;
  Function(String)? onShowSuccess;
  Function(String)? onShowError;

  AnimalDetailModel? _animalDetail;
  bool _isFavorite = false;
  bool _isOwner = false;

  /// Current animal detail data
  AnimalDetailModel? get animalDetail => _animalDetail;

  /// Whether the listing is favorited
  bool get isFavorite => _isFavorite;
  
  /// Whether the current user owns this listing
  bool get isOwner => _isOwner;

  /// Check if data is loaded successfully
  bool get hasData => _animalDetail != null;

  /// Get listing ID
  int? get listingId => _animalDetail?.id;

  /// Get listing title
  String? get title => _animalDetail?.title;

  AnimalDetailController({
    AnimalDetailService? animalDetailService,
    MessagingService? messagingService,
    CommonHelper? commonHelper,
  })  : _animalDetailService = animalDetailService ?? AnimalDetailService(),
        _messagingService = messagingService ?? MessagingService(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// Fetch animal details from the API
  Future<void> fetchAnimalDetail(int listingId) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      debugPrint('[AnimalDetailController] Fetching listing $listingId...');

      _animalDetail = await _animalDetailService.fetchAnimalDetail(listingId);

      if (isDisposed) return;

      debugPrint('[AnimalDetailController] Loaded: ${_animalDetail?.title}');

      // Check favorite status
      await _checkFavoriteStatus(listingId);
      
      // Check ownership
      await _checkOwnership();

      notifyListeners();
    } catch (e) {
      debugPrint('[AnimalDetailController] Error: $e');
      if (!isDisposed) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        setError(errorMessage.isEmpty ? 'Failed to load listing details' : errorMessage);
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Check if listing is favorited
  Future<void> _checkFavoriteStatus(int listingId) async {
    try {
      _isFavorite = await _animalDetailService.isFavorited(listingId);
    } catch (e) {
      debugPrint('[AnimalDetailController] Error checking favorite status: $e');
    }
  }
  
  /// Check ownership of the listing
  Future<void> _checkOwnership() async {
    try {
      final user = await _commonHelper.getLoggedInUser();
      if (user != null && _animalDetail?.seller != null) {
        _isOwner = _animalDetail!.seller!.id == user.id;
      }
    } catch (e) {
      debugPrint('[AnimalDetailController] Error checking ownership: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (isDisposed || _animalDetail == null) return;

    final listingId = _animalDetail!.id;
    final previousState = _isFavorite;

    // Optimistic update
    _isFavorite = !_isFavorite;
    notifyListeners();

    try {
      if (_isFavorite) {
        await _animalDetailService.addToFavorites(listingId);
        debugPrint('[AnimalDetailController] Added to favorites: $listingId');
      } else {
        await _animalDetailService.removeFromFavorites(listingId);
        debugPrint('[AnimalDetailController] Removed from favorites: $listingId');
      }
      
      clearError();
      
      // Show success message
      if (onShowSuccess != null) {
        onShowSuccess!(_isFavorite ? 'Added to favorites' : 'Removed from favorites');
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (errorMessage.contains('already in your favorites')) {
        _isFavorite = true;
        notifyListeners();
        debugPrint('[AnimalDetailController] Listing already favorited');
        
        if (onShowError != null) {
          onShowError!('Already in favorites');
        }
      } else {
        _isFavorite = previousState;
        notifyListeners();
        
        debugPrint('[AnimalDetailController] Error toggling favorite: $e');
        if (onShowError != null) {
          onShowError!(errorMessage);
        }
      }
    }
  }

  /// Handle share action — share listing via system share sheet
  void handleShare() {
    final animal = _animalDetail;
    if (animal == null) return;

    final price = animal.formattedPrice;
    final title = animal.title;
    final breed = animal.breed ?? '';
    final location = animal.location ?? '';

    final text = StringBuffer()
      ..writeln('🐄 $title')
      ..writeln('💰 $price')
      ..writeln('📍 $location');
    if (breed.isNotEmpty) text.writeln('🐾 $breed');
    text.writeln();
    text.writeln('Check this listing on FarmerApp!');

    Share.share(text.toString());

    debugPrint('[AnimalDetailController] Shared: $title');
  }

  /// Handle call action
  void handleCall() {
    if (onShowComingSoon != null) {
      onShowComingSoon!('Call');
    }
  }

  /// Handle chat action - start or open conversation with seller
  Future<void> handleChat(BuildContext context, int listingId) async {
    try {
      final result = await _messagingService.startConversation(listingId);

      if (result.success && result.conversation != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.directChat,
          arguments: result.conversation,
        );
      } else {
        if (onShowError != null) {
          onShowError!(result.message ?? 'Failed to start conversation');
        }
      }
    } catch (e) {
      if (onShowError != null) {
        onShowError!('Failed to start conversation');
      }
    }
  }

  /// Handle video call action
  void handleVideo() {
    if (onShowComingSoon != null) {
      onShowComingSoon!('Video call');
    }
  }

  /// Handle buy now action
  void handleBuyNow() {
    if (onShowComingSoon != null) {
      onShowComingSoon!('Buy Now');
    }
  }

  /// Handle book transport action
  void handleBookTransport() {
    if (onShowComingSoon != null) {
      onShowComingSoon!('Book Transport');
    }
  }

  /// Handle seller contact action
  void handleSellerContact() {
    if (onShowComingSoon != null) {
      onShowComingSoon!('Contact Seller');
    }
  }

  /// Navigate to view bids
  void navigateToViewBids(BuildContext context, int listingId) {
    Navigator.pushNamed(context, AppRoutes.listingBids, arguments: listingId);
  }

  /// Navigate back
  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Report the listing
  Future<void> reportListing(String reason) async {
    if (isDisposed || _animalDetail == null) return;

    try {
      await _animalDetailService.reportListing(_animalDetail!.id, reason);
      debugPrint('[AnimalDetailController] Reported listing: ${_animalDetail!.id}');
    } catch (e) {
      debugPrint('[AnimalDetailController] Error reporting listing: $e');
      if (!isDisposed) {
        setError('Failed to report listing');
      }
      rethrow;
    }
  }

  /// Contact seller
  Future<void> contactSeller(String message) async {
    if (isDisposed || _animalDetail == null) return;

    try {
      await _animalDetailService.contactSeller(_animalDetail!.id, message);
      debugPrint('[AnimalDetailController] Contacted seller for: ${_animalDetail!.id}');
    } catch (e) {
      debugPrint('[AnimalDetailController] Error contacting seller: $e');
      if (!isDisposed) {
        setError('Failed to contact seller');
      }
      rethrow;
    }
  }

  /// Refresh the animal details
  Future<void> refresh(int listingId) async {
    await fetchAnimalDetail(listingId);
  }
}

