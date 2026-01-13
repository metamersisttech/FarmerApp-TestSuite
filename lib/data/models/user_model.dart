/// User Model
///
/// Data class that matches Django's User serializer.
/// Handles JSON serialization/deserialization.
library;

import 'package:flutter_app/core/helpers/common_helper.dart';

class UserModel {
  final int id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImage;
  final bool isActive;
  final bool isVerified;
  final String? kycStatus;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  
  // New fields from updated profile API
  final String? fullName;
  final String? displayName;
  final String? dob;
  final String? address;
  final String? state;
  final String? district;
  final String? village;
  final String? pincode;
  final String? latitude;
  final String? longitude;
  final String? about;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImage,
    this.isActive = true,
    this.isVerified = false,
    this.kycStatus,
    this.dateJoined,
    this.lastLogin,
    this.fullName,
    this.displayName,
    this.dob,
    this.address,
    this.state,
    this.district,
    this.village,
    this.pincode,
    this.latitude,
    this.longitude,
    this.about,
  });

  /// Full name getter - handles both old and new field formats
  String get fullNameDisplay {
    // Prefer new fullName field if available
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    // Fall back to firstName + lastName
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? displayName ?? username ?? email;
  }
  
  /// Display name getter - handles both old and new field formats
  String get displayNameOrUsername {
    return displayName ?? username ?? firstName ?? email.split('@')[0];
  }

  /// Create UserModel from Django JSON response
  /// Handles both old (first_name, last_name, username) and new (full_name, display_name) field formats
  /// New format fields can be at top level OR nested in 'profile' object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if profile fields are nested
    final profile = json['profile'] as Map<String, dynamic>?;

    // Get profile image key from various possible fields
    final profileImageKey = json['profile_image'] as String? ??
        profile?['profile_image_gcs'] as String? ??
        json['profile_image_gcs'] as String?;

    // Convert key to full URL if it's not already a full URL
    final profileImageUrl = profileImageKey != null && profileImageKey.isNotEmpty
        ? CommonHelper.getImageUrl(profileImageKey)
        : null;

    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      email: json['email'] as String,
      // Old format fields
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      profileImage: profileImageUrl,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      kycStatus: json['kyc_status'] as String?,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      // New format fields - check nested 'profile' object first, then top level
      fullName: profile?['full_name'] as String? ?? json['full_name'] as String?,
      displayName: profile?['display_name'] as String? ?? json['display_name'] as String?,
      dob: profile?['dob'] as String? ?? json['dob'] as String?,
      address: profile?['address'] as String? ?? json['address'] as String?,
      state: profile?['state'] as String? ?? json['state'] as String?,
      district: profile?['district'] as String? ?? json['district'] as String?,
      village: profile?['village'] as String? ?? json['village'] as String?,
      pincode: profile?['pincode'] as String? ?? json['pincode'] as String?,
      latitude: (profile?['latitude'] ?? json['latitude'])?.toString(),
      longitude: (profile?['longitude'] ?? json['longitude'])?.toString(),
      about: profile?['about'] as String? ?? json['about'] as String?,
    );
  }

  /// Convert UserModel to JSON for Django API request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      // Include old format fields if available
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profile_image': profileImage,
      'is_verified': isVerified,
      if (kycStatus != null) 'kyc_status': kycStatus,
      // Include new format fields if available
      if (fullName != null) 'full_name': fullName,
      if (displayName != null) 'display_name': displayName,
      if (dob != null) 'dob': dob,
      if (address != null) 'address': address,
      if (state != null) 'state': state,
      if (district != null) 'district': district,
      if (village != null) 'village': village,
      if (pincode != null) 'pincode': pincode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (about != null) 'about': about,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    int? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    bool? isActive,
    bool? isVerified,
    String? kycStatus,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username)';
  }
}

/// Auth Response Model (for login/register responses)
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;
  final String? message;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    this.message,
  });

  /// Parse auth response from Django API
  /// Handles both nested tokens format:
  ///   { "tokens": { "access": "...", "refresh": "..." }, "user": {...} }
  /// And flat format:
  ///   { "access": "...", "refresh": "...", "user": {...} }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Check if tokens are nested
    final tokens = json['tokens'] as Map<String, dynamic>?;
    
    String accessToken;
    String? refreshToken;
    
    if (tokens != null) {
      // Nested format: { "tokens": { "access": "...", "refresh": "..." } }
      accessToken = tokens['access'] as String;
      refreshToken = tokens['refresh'] as String?;
    } else {
      // Flat format: { "access": "...", "refresh": "..." }
      accessToken = json['access'] as String? ?? json['access_token'] as String;
      refreshToken = json['refresh'] as String? ?? json['refresh_token'] as String?;
    }

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
}

