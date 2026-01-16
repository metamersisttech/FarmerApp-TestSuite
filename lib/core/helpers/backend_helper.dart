/// Backend Helper - API endpoint methods
///
/// Contains all API endpoint methods for backend communication.
/// Similar to fakeBackendHelper in JS pattern.
library;

import 'package:dio/dio.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/constants/api_endpoints.dart';

/// Backend Helper
/// Contains all API endpoint methods
class BackendHelper {
  final APIClient _client;

  BackendHelper({APIClient? client}) : _client = client ?? APIClient();

  // ============ Auth Endpoints ============

  /// Send login OTP to phone number
  /// POST /api/auth/send-login-otp/
  /// Request: { "phone": "1234567890" }
  /// Response: { "message": "...", "otp": "123456", "user_id": 1 }
  Future<Map<String, dynamic>> postSendLoginOtp(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.sendLoginOtp, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify login OTP
  /// POST /api/auth/login/
  /// Request: { "phone": "1234567890", "otp": "123456" }
  /// Response: { "message": "...", "user": {...}, "tokens": {...} }
  Future<Map<String, dynamic>> postVerifyLoginOtp(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.verifyLoginOtp, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current authenticated user
  /// GET /api/auth/me/
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _client.get(ApiEndpoints.me);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout user
  /// POST /api/auth/logout/
  /// Request: { "refresh": "..." }
  Future<void> postLogout(Map<String, dynamic> data) async {
    try {
      await _client.post(ApiEndpoints.logout, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  /// POST /api/auth/token/refresh/
  /// Request: { "refresh": "..." }
  /// Response: { "access": "..." }
  Future<Map<String, dynamic>> postRefreshToken(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.refreshToken, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request password reset
  /// POST /api/auth/password/reset/
  /// Request: { "email": "..." }
  /// Response: { "message": "...", "token": "..." }
  Future<Map<String, dynamic>> postRequestPasswordReset(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.forgotPassword, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Confirm password reset with token
  /// POST /api/auth/password/reset/confirm/
  /// Request: { "token": "...", "new_password": "...", "new_password_confirm": "..." }
  /// Response: { "message": "Password reset successfully." }
  Future<Map<String, dynamic>> postConfirmPasswordReset(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.resetPassword, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ User Endpoints ============

  /// Get user profile
  /// GET /api/users/profile/
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.userProfile);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  /// PATCH /api/users/profile/update/
  Future<Map<String, dynamic>> putUpdateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _client.patch(ApiEndpoints.updateProfile, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Animal Endpoints ============

  /// Get all animals
  /// GET /api/animals/
  Future<dynamic> getAnimals({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.get(ApiEndpoints.animals, params: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Farm Endpoints ============

  /// Get current user's farms
  /// GET /api/farms/
  Future<List<dynamic>> getFarms() async {
    try {
      final response = await _client.get(ApiEndpoints.farms);
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      // Handle paginated response if needed
      if (response.data is Map && response.data['results'] != null) {
        return response.data['results'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new farm
  /// POST /api/farms/
  /// Request body:
  /// {
  ///   "name": "Green Valley Farm",
  ///   "area_sq_m": 50000.00,
  ///   "address": "Village Khed, Taluka Ambegaon, District Pune",
  ///   "latitude": 18.7546,
  ///   "longitude": 73.8854
  /// }
  Future<Map<String, dynamic>> postCreateFarm(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.farms, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Listing Endpoints ============

  /// Get all listings
  /// GET /api/listings/
  Future<dynamic> getListings({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.get(ApiEndpoints.mylistings, params: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new animal listing
  /// POST /api/listings/
  /// Request body:
  /// {
  ///   "title": "Healthy Gir Cow - 3 Years Old",
  ///   "description": "Beautiful Gir cow...",
  ///   "price": 75000.00,
  ///   "currency": "INR",
  ///   "animal": 1,
  ///   "farm": 1,
  ///   "age_months": 36,
  ///   "gender": "female",
  ///   "weight_kg": 450.00,
  ///   "height_cm": 140.00,
  ///   "color": "Red and White",
  ///   "health_status": "healthy"
  /// }
  Future<Map<String, dynamic>> postCreateListing(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(ApiEndpoints.listings, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single listing by ID
  /// GET /api/listings/{id}/
  Future<Map<String, dynamic>> getListingById(int listingId) async {
    try {
      final response = await _client.get('${ApiEndpoints.listings}$listingId/');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing animal listing
  /// PATCH /api/listings/{id}/
  /// Request body: partial update fields
  Future<Map<String, dynamic>> patchUpdateListing(int listingId, Map<String, dynamic> data) async {
    try {
      final response = await _client.patch('${ApiEndpoints.listings}$listingId/', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Upload Endpoints ============

  /// Upload a single file
  /// POST /api/upload/?category={category}
  /// Categories: listings, profile, documents, vet_certificates, general
  /// Response: { "key": "path/to/file.jpg", "url": "https://..." }
  Future<Map<String, dynamic>> postUploadFile(String filePath, String category) async {
    try {
      final response = await _client.uploadFile(
        '${ApiEndpoints.upload}?category=$category',
        filePath: filePath,
        fieldName: 'file',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multiple files
  /// POST /api/upload/multiple/?category={category}
  /// Categories: listings, profile, documents, vet_certificates, general
  /// Response: { "uploaded": [{ "key": "...", "url": "..." }, ...], "count": N }
  Future<List<Map<String, dynamic>>> postUploadMultipleFiles(List<String> filePaths, String category) async {
    try {
      final formData = FormData.fromMap({
        'files': await Future.wait(
          filePaths.map((path) => MultipartFile.fromFile(path)),
        ),
      });
      final response = await _client.post(
        '${ApiEndpoints.uploadMultiple}?category=$category',
        data: formData,
      );
      // Extract 'uploaded' list from response
      final data = response.data as Map<String, dynamic>;
      final uploaded = data['uploaded'] as List;
      return uploaded.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Error Handling ============

  /// Handle Dio errors and extract message
  Exception _handleError(DioException error) {
    String message = 'An error occurred';

    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
        // Try different error message formats
        message = data['message']?.toString() ??
            data['detail']?.toString() ??
            data['error']?.toString() ??
            _extractFieldErrors(data) ??
            'Request failed';
      } else if (data is String) {
        message = data;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection.';
    }

    return BackendException(
      message: message,
      statusCode: error.response?.statusCode,
      data: error.response?.data,
    );
  }

  /// Extract field-level errors from Django response
  String? _extractFieldErrors(Map<dynamic, dynamic> data) {
    final errors = <String>[];
    data.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        errors.add(value.first.toString());
      } else if (value is String && key != 'message' && key != 'detail' && key != 'error') {
        errors.add(value);
      }
    });
    return errors.isNotEmpty ? errors.join('\n') : null;
  }
}

/// Backend Exception
class BackendException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  BackendException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;

  /// Check if user was not found (404)
  bool get isUserNotFound => statusCode == 404;

  /// Check if unauthorized (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if bad request (400)
  bool get isBadRequest => statusCode == 400;
}
