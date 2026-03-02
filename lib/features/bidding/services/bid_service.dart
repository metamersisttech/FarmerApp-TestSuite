import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/bidding/models/bid_model.dart';

/// Result of bid operations
class BidResult {
  final bool success;
  final String? message;
  final BidModel? bid;
  final List<BidModel>? bids;
  final int? totalCount;

  const BidResult({
    required this.success,
    this.message,
    this.bid,
    this.bids,
    this.totalCount,
  });

  factory BidResult.ok({
    BidModel? bid,
    List<BidModel>? bids,
    int? totalCount,
    String? message,
  }) {
    return BidResult(
      success: true,
      bid: bid,
      bids: bids,
      totalCount: totalCount,
      message: message,
    );
  }

  factory BidResult.error(String message) {
    return BidResult(success: false, message: message);
  }
}

/// Service for bidding CRUD operations
class BidService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  BidService({
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// Initialize API client with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _commonHelper.getAccessToken();
    if (accessToken != null) {
      APIClient().setAuthorization(accessToken);
    }
  }

  /// Place a bid on a listing
  /// POST /api/listings/{listingId}/bids/
  Future<BidResult> placeBid({
    required int listingId,
    required double bidPrice,
    String? message,
  }) async {
    try {
      await _initializeAuth();

      final data = <String, dynamic>{
        'bid_price': bidPrice,
      };
      if (message != null && message.isNotEmpty) {
        data['message'] = message;
      }

      final json = await _backendHelper.postPlaceBid(listingId, data);

      final bid = BidModel.fromJson(json);
      return BidResult.ok(bid: bid, message: 'Bid placed successfully!');
    } on BackendException catch (e) {
      debugPrint('BackendException placing bid: ${e.message}');
      return BidResult.error(e.message);
    } catch (e, stackTrace) {
      debugPrint('Error placing bid: $e');
      debugPrint('Stack trace: $stackTrace');
      return BidResult.error('Failed to place bid.');
    }
  }

  /// Get current user's bids
  /// GET /api/listings/my-bids/
  Future<BidResult> getMyBids({String? status}) async {
    try {
      await _initializeAuth();

      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }

      final data = await _backendHelper.getMyBids(params: params);

      List<dynamic> results;
      int? totalCount;
      if (data is List) {
        results = data;
      } else if (data is Map) {
        results = data['results'] as List<dynamic>? ?? [];
        totalCount = data['count'] as int?;
      } else {
        results = [];
      }

      final bids = results
          .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return BidResult.ok(
        bids: bids,
        totalCount: totalCount ?? bids.length,
      );
    } on BackendException catch (e) {
      debugPrint('BackendException getting my bids: ${e.message}');
      return BidResult.error(e.message);
    } catch (e, stackTrace) {
      debugPrint('Error getting my bids: $e');
      debugPrint('Stack trace: $stackTrace');
      return BidResult.error('Failed to load your bids.');
    }
  }

  /// Cancel a bid
  /// POST /api/listings/{listingId}/bids/{bidId}/cancel/
  Future<BidResult> cancelBid({
    required int listingId,
    required int bidId,
  }) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postCancelBid(listingId, bidId);
      final bid = BidModel.fromJson(json);
      return BidResult.ok(
        bid: bid,
        message: json['message'] as String? ?? 'Bid cancelled.',
      );
    } on BackendException catch (e) {
      return BidResult.error(e.message);
    } catch (e) {
      debugPrint('Error cancelling bid: $e');
      return BidResult.error('Failed to cancel bid.');
    }
  }

  /// Get bids for a listing (seller view)
  /// GET /api/listings/{listingId}/bids/list/
  Future<BidResult> getListingBids({
    required int listingId,
    String? status,
  }) async {
    try {
      await _initializeAuth();

      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }

      final data = await _backendHelper.getListingBids(
        listingId,
        params: params,
      );

      List<dynamic> results;
      int? totalCount;
      if (data is List) {
        results = data;
      } else if (data is Map) {
        results = data['results'] as List<dynamic>? ?? [];
        totalCount = data['count'] as int?;
      } else {
        results = [];
      }

      final bids = results
          .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return BidResult.ok(
        bids: bids,
        totalCount: totalCount ?? bids.length,
      );
    } on BackendException catch (e) {
      debugPrint('BackendException getting listing bids: ${e.message}');
      return BidResult.error(e.message);
    } catch (e, stackTrace) {
      debugPrint('Error getting listing bids: $e');
      debugPrint('Stack trace: $stackTrace');
      return BidResult.error('Failed to load bids for this listing.');
    }
  }

  /// Approve a bid
  /// POST /api/listings/{listingId}/bids/{bidId}/approve/
  Future<BidResult> approveBid({
    required int listingId,
    required int bidId,
  }) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postApproveBid(listingId, bidId);
      final bid = BidModel.fromJson(json);
      return BidResult.ok(
        bid: bid,
        message: json['message'] as String? ?? 'Bid approved.',
      );
    } on BackendException catch (e) {
      return BidResult.error(e.message);
    } catch (e) {
      debugPrint('Error approving bid: $e');
      return BidResult.error('Failed to approve bid.');
    }
  }

  /// Reject a bid
  /// POST /api/listings/{listingId}/bids/{bidId}/reject/
  Future<BidResult> rejectBid({
    required int listingId,
    required int bidId,
  }) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postRejectBid(listingId, bidId);
      final bid = BidModel.fromJson(json);
      return BidResult.ok(
        bid: bid,
        message: json['message'] as String? ?? 'Bid rejected.',
      );
    } on BackendException catch (e) {
      return BidResult.error(e.message);
    } catch (e) {
      debugPrint('Error rejecting bid: $e');
      return BidResult.error('Failed to reject bid.');
    }
  }
}
