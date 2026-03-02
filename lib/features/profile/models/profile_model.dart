import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';

/// Profile statistics model
class ProfileStats {
  final int animalsSold;
  final int transactions;
  final int memberYears;

  const ProfileStats({
    this.animalsSold = 0,
    this.transactions = 0,
    this.memberYears = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      animalsSold: json['animals_sold'] as int? ?? 0,
      transactions: json['transactions'] as int? ?? 0,
      memberYears: json['member_years'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animals_sold': animalsSold,
      'transactions': transactions,
      'member_years': memberYears,
    };
  }
}

/// Profile data model
class ProfileModel {
  final int id;
  final String name;
  final String? profileImage;
  final String? identity; // farmer, broker, etc.
  final String? location;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final String? kycStatus; // verified, pending, not_verified
  final ProfileStats stats;
  final DateTime? memberSince;

  const ProfileModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.identity,
    this.location,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.kycStatus,
    this.stats = const ProfileStats(),
    this.memberSince,
  });

  /// Check if KYC is verified
  bool get isKycVerified => kycStatus == 'verified';

  /// Get formatted member duration
  String get memberDuration {
    if (memberSince == null) return '${stats.memberYears}yr';
    final years = DateTime.now().difference(memberSince!).inDays ~/ 365;
    return '${years}yr';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Convert profile image key to full URL
    final profileImageKey = json['profile_image'] as String? ??
                            json['profile_image_gcs'] as String?;
    final profileImageUrl = profileImageKey != null && profileImageKey.isNotEmpty
        ? CommonHelper.getImageUrl(profileImageKey)
        : null;

    return ProfileModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      profileImage: profileImageUrl,
      identity: json['identity'] as String?,
      location: json['location'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      kycStatus: json['kyc_status'] as String?,
      stats: json['stats'] != null
          ? ProfileStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const ProfileStats(),
      memberSince: json['member_since'] != null
          ? DateTime.parse(json['member_since'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'identity': identity,
      'location': location,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'kyc_status': kycStatus,
      'stats': stats.toJson(),
      'member_since': memberSince?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    int? id,
    String? name,
    String? profileImage,
    String? identity,
    String? location,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    String? kycStatus,
    ProfileStats? stats,
    DateTime? memberSince,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      identity: identity ?? this.identity,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      stats: stats ?? this.stats,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

/// Profile menu item model
class ProfileMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final int? badgeCount;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.badgeCount,
    this.onTap,
  });

  /// Predefined menu items
  static List<ProfileMenuItem> defaultMenuItems({
    int myListingsCount = 0,
    int savedItemsCount = 0,
    int bookingsCount = 0,
    int myBidsCount = 0,
    int messagesCount = 0,
    int notificationsCount = 0,
    VoidCallback? onMyListingsTap,
    VoidCallback? onSavedItemsTap,
    VoidCallback? onBookingsTap,
    VoidCallback? onMyBidsTap,
    VoidCallback? onMessagesTap,
    VoidCallback? onWalletTap,
    VoidCallback? onReviewsTap,
    VoidCallback? onNotificationsTap,
    VoidCallback? onLanguageTap,
    VoidCallback? onPrivacyTap,
    VoidCallback? onHelpTap,
  }) {
    return [
      ProfileMenuItem(
        id: 'my_listings',
        title: 'My Listings',
        icon: Icons.inventory_2_outlined,
        badgeCount: myListingsCount > 0 ? myListingsCount : null,
        onTap: onMyListingsTap,
      ),
      ProfileMenuItem(
        id: 'saved_items',
        title: 'Saved Items',
        icon: Icons.favorite_border,
        badgeCount: savedItemsCount > 0 ? savedItemsCount : null,
        onTap: onSavedItemsTap,
      ),
      ProfileMenuItem(
        id: 'my_bookings',
        title: 'My Bookings',
        icon: Icons.calendar_today_outlined,
        badgeCount: bookingsCount > 0 ? bookingsCount : null,
        onTap: onBookingsTap,
      ),
      ProfileMenuItem(
        id: 'my_bids',
        title: 'My Bids',
        icon: Icons.gavel_outlined,
        badgeCount: myBidsCount > 0 ? myBidsCount : null,
        onTap: onMyBidsTap,
      ),
      ProfileMenuItem(
        id: 'messages',
        title: 'Messages',
        icon: Icons.chat_bubble_outline,
        badgeCount: messagesCount > 0 ? messagesCount : null,
        onTap: onMessagesTap,
      ),
      ProfileMenuItem(
        id: 'wallet',
        title: 'Wallet & Payments',
        icon: Icons.account_balance_wallet_outlined,
        onTap: onWalletTap,
      ),
      ProfileMenuItem(
        id: 'reviews',
        title: 'Reviews & Ratings',
        icon: Icons.star_border,
        onTap: onReviewsTap,
      ),
      ProfileMenuItem(
        id: 'notifications',
        title: 'Notifications',
        icon: Icons.notifications_none,
        badgeCount: notificationsCount > 0 ? notificationsCount : null,
        onTap: onNotificationsTap,
      ),
      ProfileMenuItem(
        id: 'language',
        title: 'Language',
        icon: Icons.language,
        onTap: onLanguageTap,
      ),
      ProfileMenuItem(
        id: 'privacy',
        title: 'Privacy & Security',
        icon: Icons.security,
        onTap: onPrivacyTap,
      ),
      ProfileMenuItem(
        id: 'help',
        title: 'Help & Support',
        icon: Icons.help_outline,
        onTap: onHelpTap,
      ),
    ];
  }
}

