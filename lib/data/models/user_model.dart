/// User Model
///
/// Data class that matches Django's User serializer.
/// Handles JSON serialization/deserialization.
library;

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
  });

  /// Full name getter
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? username ?? email;
  }

  /// Create UserModel from Django JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      email: json['email'] as String,
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      kycStatus: json['kyc_status'] as String?,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  /// Convert UserModel to JSON for Django API request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'kyc_status': kycStatus,
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

