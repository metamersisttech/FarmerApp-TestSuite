/// Backend Helper - API endpoint methods
///
/// Contains all API endpoint methods for backend communication.
/// Similar to fakeBackendHelper in JS pattern.
library;

import 'package:dio/dio.dart';
import 'package:flutter_app/core/constants/api_endpoints.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';

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
  Future<Map<String, dynamic>> postSendLoginOtp(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.sendLoginOtp,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify login OTP
  /// POST /api/auth/login/
  /// Request: { "phone": "1234567890", "otp": "123456" }
  /// Response: { "message": "...", "user": {...}, "tokens": {...} }
  Future<Map<String, dynamic>> postVerifyLoginOtp(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.verifyLoginOtp,
        data: data,
      );
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
  Future<Map<String, dynamic>> postRefreshToken(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.refreshToken,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Request password reset
  /// POST /api/auth/password/reset/
  /// Request: { "email": "..." }
  /// Response: { "message": "...", "token": "..." }
  Future<Map<String, dynamic>> postRequestPasswordReset(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.forgotPassword,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Confirm password reset with token
  /// POST /api/auth/password/reset/confirm/
  /// Request: { "token": "...", "new_password": "...", "new_password_confirm": "..." }
  /// Response: { "message": "Password reset successfully." }
  Future<Map<String, dynamic>> postConfirmPasswordReset(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.resetPassword,
        data: data,
      );
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
  Future<Map<String, dynamic>> putUpdateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.updateProfile,
        data: data,
      );
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
      final response = await _client.get(ApiEndpoints.listings, params: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Bulk fetch listings by IDs (for delta sync)
  /// GET /api/listings/bulk/?ids=1,2,3
  /// Response: Array of listing objects
  /// 
  /// TODO: Backend to implement this endpoint
  /// For now, will fallback to fetching individual listings
  Future<dynamic> getBulkListings(List<int> ids) async {
    try {
      if (ids.isEmpty) {
        return [];
      }
      
      // Convert IDs to comma-separated string
      final idsParam = ids.join(',');
      
      final response = await _client.get(
        ApiEndpoints.listingsBulk,
        params: {'ids': idsParam},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get current user listings

  Future<dynamic> getMyListings({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.mylistings,
        params: params,
      );
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
  Future<Map<String, dynamic>> postCreateListing(
    Map<String, dynamic> data,
  ) async {
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
  Future<Map<String, dynamic>> patchUpdateListing(
    int listingId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.patch(
        '${ApiEndpoints.listings}$listingId/',
        data: data,
      );
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
  Future<Map<String, dynamic>> postUploadFile(
    String filePath,
    String category,
  ) async {
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
  Future<List<Map<String, dynamic>>> postUploadMultipleFiles(
    List<String> filePaths,
    String category,
  ) async {
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

  // ============ Vet Onboarding Endpoints ============

  /// Get vet verification status
  /// GET /api/auth/vet/verification-status/
  Future<Map<String, dynamic>> getVetVerificationStatus() async {
    try {
      final response = await _client.get(ApiEndpoints.vetVerificationStatus);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit role upgrade request
  /// POST /api/auth/role/upgrade/
  Future<Map<String, dynamic>> postRoleUpgrade(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(ApiEndpoints.roleUpgrade, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Resubmit documents for a role upgrade request
  /// PATCH /api/auth/role/upgrade/{id}/
  Future<Map<String, dynamic>> patchRoleUpgrade(
    int requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.roleUpgradeById(requestId),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Vet Profile Endpoints ============

  /// Get vet profile (own)
  /// GET /api/vets/me/
  Future<Map<String, dynamic>> getVetProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.vetProfile);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update vet profile
  /// PATCH /api/vets/me/
  Future<Map<String, dynamic>> patchVetProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.vetProfile,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Vet Availability Endpoints ============

  /// Get vet availability slots
  /// GET /api/vets/me/availability/
  Future<List<dynamic>> getVetAvailability() async {
    try {
      final response = await _client.get(ApiEndpoints.vetAvailability);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add a new availability slot
  /// POST /api/vets/me/availability/
  Future<Map<String, dynamic>> postVetAvailability(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.vetAvailability,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an availability slot
  /// PATCH /api/vets/me/availability/{id}/
  Future<Map<String, dynamic>> patchVetAvailability(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.vetAvailabilityById(id),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an availability slot
  /// DELETE /api/vets/me/availability/{id}/
  Future<void> deleteVetAvailability(int id) async {
    try {
      await _client.delete(ApiEndpoints.vetAvailabilityById(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Vet Pricing Endpoints ============

  /// Get vet pricing
  /// GET /api/vets/me/pricing/
  Future<Map<String, dynamic>> getVetPricing() async {
    try {
      final response = await _client.get(ApiEndpoints.vetPricing);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update vet pricing
  /// PATCH /api/vets/me/pricing/
  Future<Map<String, dynamic>> patchVetPricing(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.vetPricing,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Public Vet Endpoints (Browse) ============

  /// Get vet list (may be paginated Map or plain List)
  /// GET /api/vets/
  Future<dynamic> getVets({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.get(ApiEndpoints.vets, params: params);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get vet detail by ID (public)
  /// GET /api/vets/{id}/
  Future<Map<String, dynamic>> getVetById(int vetId) async {
    try {
      final response = await _client.get(ApiEndpoints.vetById(vetId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get vet public availability
  /// GET /api/vets/{id}/availability/
  Future<List<dynamic>> getVetPublicAvailability(int vetId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.vetPublicAvailability(vetId),
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Appointment Endpoints ============

  /// Get user's appointments (paginated, supports ?status= filter)
  /// GET /api/appointments/
  Future<Map<String, dynamic>> getAppointments({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.appointments,
        params: params,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get appointment by ID
  /// GET /api/appointments/{id}/
  Future<Map<String, dynamic>> getAppointmentById(int id) async {
    try {
      final response = await _client.get(ApiEndpoints.appointmentById(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create appointment
  /// POST /api/appointments/
  Future<Map<String, dynamic>> postCreateAppointment(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.appointments,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel appointment
  /// POST /api/appointments/{id}/cancel/
  Future<Map<String, dynamic>> postCancelAppointment(int id) async {
    try {
      final response = await _client.post(ApiEndpoints.appointmentCancel(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Vet Appointment Endpoints ============

  /// Get vet's incoming appointments (paginated, supports ?status= filter)
  /// GET /api/appointments/vet/
  Future<Map<String, dynamic>> getVetAppointments({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.vetAppointments,
        params: params,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get available time slots for a vet on a specific date
  /// GET /api/appointments/vet/{vetId}/available-slots/?date=YYYY-MM-DD
  Future<Map<String, dynamic>> getVetAvailableSlots(
    int vetId, {
    required String date,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.vetAvailableSlots(vetId),
        params: {'date': date},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Approve an appointment with scheduled date and time
  /// POST /api/appointments/{id}/approve/
  Future<Map<String, dynamic>> postApproveAppointment(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.appointmentApprove(id),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reject an appointment with reason
  /// POST /api/appointments/{id}/reject/
  Future<Map<String, dynamic>> postRejectAppointment(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.appointmentReject(id),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete an appointment with prescription and notes
  /// POST /api/appointments/{id}/complete/
  Future<Map<String, dynamic>> postCompleteAppointment(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.appointmentComplete(id),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Appointment Chat Endpoints ============

  /// Get messages for an appointment
  /// GET /api/appointments/{id}/messages/
  Future<Map<String, dynamic>> getAppointmentMessages(
    int appointmentId,
  ) async {
    try {
      final response = await _client.get(
        ApiEndpoints.appointmentMessages(appointmentId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send a message on an appointment
  /// POST /api/appointments/{id}/messages/
  Future<Map<String, dynamic>> postSendMessage(
    int appointmentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.appointmentMessages(appointmentId),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get unread message count for an appointment
  /// GET /api/appointments/{id}/messages/unread-count/
  Future<Map<String, dynamic>> getUnreadMessageCount(
    int appointmentId,
  ) async {
    try {
      final response = await _client.get(
        ApiEndpoints.appointmentUnreadCount(appointmentId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all messages as read for an appointment
  /// POST /api/appointments/{id}/messages/read/
  Future<Map<String, dynamic>> postMarkMessagesRead(
    int appointmentId,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.appointmentMarkRead(appointmentId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ Direct Messaging Endpoints ============

  /// Start or get conversation from a listing
  /// POST /api/listings/{listing_id}/chat/
  Future<Map<String, dynamic>> postStartConversation(int listingId) async {
    try {
      final response = await _client.post(
        ApiEndpoints.listingChat(listingId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if conversation exists with listing seller
  /// GET /api/listings/{listing_id}/chat/
  Future<Map<String, dynamic>> getListingConversation(int listingId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.listingChat(listingId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all conversations (inbox)
  /// GET /api/messages/conversations/
  Future<dynamic> getConversations() async {
    try {
      final response = await _client.get(ApiEndpoints.conversations);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get conversation detail
  /// GET /api/messages/conversations/{id}/
  Future<Map<String, dynamic>> getConversationById(
    int conversationId,
  ) async {
    try {
      final response = await _client.get(
        ApiEndpoints.conversationById(conversationId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get messages for a conversation (paginated)
  /// GET /api/messages/conversations/{id}/messages/?limit=50&before=<message_id>
  Future<dynamic> getConversationMessages(
    int conversationId, {
    int? limit,
    int? beforeMessageId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit;
      if (beforeMessageId != null) params['before'] = beforeMessageId;

      final response = await _client.get(
        ApiEndpoints.conversationMessages(conversationId),
        params: params,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send a message in a conversation
  /// POST /api/messages/conversations/{id}/messages/
  Future<Map<String, dynamic>> postConversationMessage(
    int conversationId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.conversationMessages(conversationId),
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark conversation messages as read
  /// POST /api/messages/conversations/{id}/messages/read/
  Future<Map<String, dynamic>> postConversationMarkRead(
    int conversationId,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.conversationMarkRead(conversationId),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============ FCM Endpoints ============

  /// Register FCM token with backend
  /// POST /api/fcm/register/
  Future<Map<String, dynamic>> postFcmRegister(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(ApiEndpoints.fcmRegister, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unregister FCM token from backend
  /// POST /api/fcm/unregister/
  Future<Map<String, dynamic>> postFcmUnregister(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.fcmUnregister,
        data: data,
      );
      return response.data as Map<String, dynamic>;
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
        message =
            data['message']?.toString() ??
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
      } else if (value is String &&
          key != 'message' &&
          key != 'detail' &&
          key != 'error') {
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

  BackendException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;

  /// Check if user was not found (404)
  bool get isUserNotFound => statusCode == 404;

  /// Check if unauthorized (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if bad request (400)
  bool get isBadRequest => statusCode == 400;
}
