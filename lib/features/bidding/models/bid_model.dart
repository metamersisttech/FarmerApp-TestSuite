import 'package:flutter/material.dart';

/// Model representing a bid on a listing
class BidModel {
  final int id;
  final int listingId;
  final int? bidderId;
  final String? bidderName;
  final double actualPrice;
  final double bidPrice;
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED
  final String? message;
  final String? approvedAt;
  final String? rejectedAt;
  final String createdAt;
  final String updatedAt;
  final BidListingInfo? listingInfo;
  final BidBidderInfo? bidder;

  const BidModel({
    required this.id,
    required this.listingId,
    this.bidderId,
    this.bidderName,
    required this.actualPrice,
    required this.bidPrice,
    required this.status,
    this.message,
    this.approvedAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
    this.listingInfo,
    this.bidder,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';

  String get formattedBidPrice => '\u20B9${bidPrice.toStringAsFixed(0)}';
  String get formattedActualPrice => '\u20B9${actualPrice.toStringAsFixed(0)}';

  Color get statusColor => switch (status) {
    'PENDING' => Colors.orange,
    'APPROVED' => Colors.green,
    'REJECTED' => Colors.red,
    'CANCELLED' => Colors.grey,
    _ => Colors.grey,
  };

  String get statusDisplay => switch (status) {
    'PENDING' => 'Pending',
    'APPROVED' => 'Approved',
    'REJECTED' => 'Rejected',
    'CANCELLED' => 'Cancelled',
    _ => status,
  };

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['bid_id'] as int? ?? json['id'] as int? ?? 0,
      listingId: json['listing_id'] as int? ?? json['listing'] as int? ?? 0,
      bidderId: json['bidder_id'] as int?
          ?? (json['bidder'] is Map ? json['bidder']['id'] as int? : json['bidder'] as int?),
      bidderName: json['bidder_name'] as String?
          ?? (json['bidder'] is Map ? json['bidder']['username'] as String? : null),
      actualPrice: _parseDouble(json['actual_price'] ?? json['listing_price']),
      bidPrice: _parseDouble(json['bid_price']),
      status: json['status'] as String? ?? 'PENDING',
      message: json['message'] as String?,
      approvedAt: json['approved_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      listingInfo: json['listing_info'] != null
          ? BidListingInfo.fromJson(json['listing_info'] as Map<String, dynamic>)
          : null,
      bidder: json['bidder_info'] is Map
          ? BidBidderInfo.fromJson(json['bidder_info'] as Map<String, dynamic>)
          : (json['bidder'] is Map
              ? BidBidderInfo.fromJson(json['bidder'] as Map<String, dynamic>)
              : null),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Listing info nested in my-bids response
class BidListingInfo {
  final int listingId;
  final String title;
  final String price;
  final String listingStatus;
  final int? sellerId;
  final String? sellerName;
  final String? imageUrl;

  const BidListingInfo({
    required this.listingId,
    required this.title,
    required this.price,
    required this.listingStatus,
    this.sellerId,
    this.sellerName,
    this.imageUrl,
  });

  factory BidListingInfo.fromJson(Map<String, dynamic> json) {
    return BidListingInfo(
      listingId: json['listing_id'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: json['price']?.toString() ?? '0',
      listingStatus: json['listing_status'] as String? ?? json['status'] as String? ?? '',
      sellerId: json['seller_id'] as int?,
      sellerName: json['seller_name'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
    );
  }
}

/// Bidder info nested in listing-bids response
class BidBidderInfo {
  final int id;
  final String username;
  final String? fullName;
  final bool isVerified;

  const BidBidderInfo({
    required this.id,
    required this.username,
    this.fullName,
    this.isVerified = false,
  });

  String get displayName => fullName ?? username;

  factory BidBidderInfo.fromJson(Map<String, dynamic> json) {
    return BidBidderInfo(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
