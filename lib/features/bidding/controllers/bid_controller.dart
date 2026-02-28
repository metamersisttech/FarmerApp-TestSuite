import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/bidding/models/bid_model.dart';
import 'package:flutter_app/features/bidding/services/bid_service.dart';

/// Controller for bidding operations
class BidController extends BaseController {
  final BidService _bidService;

  List<BidModel> _bids = [];

  BidController({BidService? bidService})
      : _bidService = bidService ?? BidService();

  List<BidModel> get bids => _bids;
  int get bidsCount => _bids.length;
  bool get hasBids => _bids.isNotEmpty;

  /// Place a bid on a listing
  Future<BidResult> placeBid({
    required int listingId,
    required double bidPrice,
    String? message,
  }) async {
    final result = await _bidService.placeBid(
      listingId: listingId,
      bidPrice: bidPrice,
      message: message,
    );
    return result;
  }

  /// Fetch current user's bids
  Future<void> fetchMyBids({String? status}) async {
    if (isDisposed) return;
    setLoading(true);
    clearError();

    final result = await _bidService.getMyBids(status: status);

    if (isDisposed) return;

    if (result.success) {
      _bids = result.bids ?? [];
    } else {
      setError(result.message ?? 'Failed to load bids.');
    }

    setLoading(false);
  }

  /// Fetch bids for a specific listing (seller view)
  Future<void> fetchListingBids({
    required int listingId,
    String? status,
  }) async {
    if (isDisposed) return;
    setLoading(true);
    clearError();

    final result = await _bidService.getListingBids(
      listingId: listingId,
      status: status,
    );

    if (isDisposed) return;

    if (result.success) {
      _bids = result.bids ?? [];
    } else {
      setError(result.message ?? 'Failed to load bids.');
    }

    setLoading(false);
  }

  /// Cancel a bid - returns true on success
  Future<bool> cancelBid({
    required int listingId,
    required int bidId,
  }) async {
    final result = await _bidService.cancelBid(
      listingId: listingId,
      bidId: bidId,
    );

    if (result.success && !isDisposed) {
      final index = _bids.indexWhere((b) => b.id == bidId);
      if (index != -1 && result.bid != null) {
        _bids[index] = result.bid!;
        notifyListeners();
      }
    }

    return result.success;
  }

  /// Approve a bid - returns true on success
  Future<bool> approveBid({
    required int listingId,
    required int bidId,
  }) async {
    final result = await _bidService.approveBid(
      listingId: listingId,
      bidId: bidId,
    );

    if (result.success && !isDisposed) {
      final index = _bids.indexWhere((b) => b.id == bidId);
      if (index != -1 && result.bid != null) {
        _bids[index] = result.bid!;
        notifyListeners();
      }
    }

    return result.success;
  }

  /// Reject a bid - returns true on success
  Future<bool> rejectBid({
    required int listingId,
    required int bidId,
  }) async {
    final result = await _bidService.rejectBid(
      listingId: listingId,
      bidId: bidId,
    );

    if (result.success && !isDisposed) {
      final index = _bids.indexWhere((b) => b.id == bidId);
      if (index != -1 && result.bid != null) {
        _bids[index] = result.bid!;
        notifyListeners();
      }
    }

    return result.success;
  }
}
