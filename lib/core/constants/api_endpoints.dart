/// Django API Endpoints
///
/// All API endpoint paths for the Django backend.
/// Usage: ApiEndpoints.login, ApiEndpoints.userProfile, etc.
library;

class ApiEndpoints {
  // ============ Authentication Endpoints ============
  static const String login = 'auth/login/';
  static const String register = 'auth/register/';
  static const String logout = 'auth/logout/';
  static const String refreshToken = 'auth/token/refresh/';
  static const String verifyToken = 'auth/token/verify/';
  static const String forgotPassword = 'auth/password/reset/';
  static const String resetPassword = 'auth/password/reset/confirm/';
  static const String changePassword = 'auth/password/change/';

  // Phone Authentication
  static const String sendLoginOtp = 'auth/send-login-otp/';
  static const String verifyLoginOtp = 'auth/login/'; // OTP verification endpoint
  static const String sendOtp = 'auth/otp/send/';
  static const String verifyOtp = 'auth/otp/verify/';
  
  // Current User
  static const String me = 'auth/me/'; // Get authenticated user info
  
  // Favorites
  static const String favorites = 'auth/me/favorites/'; // User favorites
  static String deleteFavoriteByListingId(int listingId) => 'auth/me/favorites/$listingId/'; // Delete favorite by listing ID

  // ============ Animal Endpoints ============
  static const String animals = 'animals/'; // Get all animals catalog

  // ============ Farm Endpoints ============
  static const String farms = 'farms/';

  // ============ Listing Endpoints ============
  static const String listings = 'listings/';
  static const String mylistings = 'listings/my/';
  static const String listingsBulk = 'listings/bulk/'; // Bulk fetch for delta sync (TODO: Backend to implement)
  static String listingPublish(int id) => 'listings/$id/publish/';
  static String listingUnpublish(int id) => 'listings/$id/unpublish/';
  static String listingSold(int id) => 'listings/$id/sold/';

  // ============ Bidding Endpoints ============
  static String listingBids(int listingId) => 'listings/$listingId/bids/';
  static const String myBids = 'listings/my-bids/';
  static String listingBidsList(int listingId) => 'listings/$listingId/bids/list/';
  static String bidCancel(int listingId, int bidId) => 'listings/$listingId/bids/$bidId/cancel/';
  static String bidApprove(int listingId, int bidId) => 'listings/$listingId/bids/$bidId/approve/';
  static String bidReject(int listingId, int bidId) => 'listings/$listingId/bids/$bidId/reject/';

  // ============ Upload Endpoints ============
  static const String upload = 'upload/';
  static const String uploadMultiple = 'upload/multiple/';

  // ============ User Endpoints ============
  static const String userProfile = 'users/profile/';
  static const String updateProfile = 'auth/me/profile/';
  static const String deleteAccount = 'users/delete/';

  // Get user by ID
  static String userById(int id) => 'users/$id/';

  // ============ Vet Onboarding Endpoints ============
  static const String vetVerificationStatus = 'auth/vet/verification-status/';
  static const String roleUpgrade = 'auth/role/upgrade/';
  static String roleUpgradeById(int id) => 'auth/role/upgrade/$id/';

  // ============ Transport Onboarding Endpoints ============
  static const String transportVerificationStatus = 'auth/transport/verification-status/';

  // ============ Vet Profile & Availability Endpoints ============
  static const String vetProfile = 'vets/me/';
  static const String vetAvailability = 'vets/me/availability/';
  static String vetAvailabilityById(int id) => 'vets/me/availability/$id/';
  static const String vetPricing = 'vets/me/pricing/';

  // ============ Public Vet Endpoints (Browse) ============
  static const String vets = 'vets/';
  static String vetById(int id) => 'vets/$id/';
  static String vetPublicAvailability(int id) => 'vets/$id/availability/';

  // ============ Appointment Endpoints ============
  static const String appointments = 'appointments/';
  static String appointmentById(int id) => 'appointments/$id/';
  static String appointmentCancel(int id) => 'appointments/$id/cancel/';

  // ============ Vet Appointment Endpoints ============
  static const String vetAppointments = 'appointments/vet/';
  static String vetAvailableSlots(int vetId) =>
      'appointments/vet/$vetId/available-slots/';
  static String appointmentApprove(int id) => 'appointments/$id/approve/';
  static String appointmentReject(int id) => 'appointments/$id/reject/';
  static String appointmentComplete(int id) => 'appointments/$id/complete/';

  // ============ Appointment Chat Endpoints ============
  static String appointmentMessages(int id) => 'appointments/$id/messages/';
  static String appointmentUnreadCount(int id) =>
      'appointments/$id/messages/unread-count/';
  static String appointmentMarkRead(int id) =>
      'appointments/$id/messages/read/';

  // ============ Direct Messaging Endpoints ============
  static const String conversations = 'messages/conversations/';
  static String conversationById(int id) => 'messages/conversations/$id/';
  static String conversationMessages(int id) =>
      'messages/conversations/$id/messages/';
  static String conversationMarkRead(int id) =>
      'messages/conversations/$id/messages/read/';
  static String listingChat(int listingId) => 'listings/$listingId/chat/';

  // ============ FCM Endpoints ============
  static const String fcmRegister = 'fcm/register/';
  static const String fcmUnregister = 'fcm/unregister/';
  static const String fcmTokens = 'fcm/tokens/';
  static const String fcmTest = 'fcm/test/';

  // ============ Notification Endpoints ============
  static const String notifications = 'notifications/';
  static String notificationById(int id) => 'notifications/$id/';
  static String notificationMarkRead(int id) => 'notifications/$id/read/';
  static const String notificationsReadAll = 'notifications/read-all/';
  static const String notificationsUnreadCount = 'notifications/unread-count/';

  // ============ Location Search Endpoints ============
  static const String locationSearch = 'locationsearch/';

  // ============ Transport Provider Endpoints ============
  /// Get/update transport provider profile
  static const String transportMe = 'transport/me/';
  /// Update transport provider availability
  static const String transportAvailability = 'transport/me/availability/';
  /// Update transport provider location
  static const String transportLocation = 'transport/me/location/';

  // ============ Transport Vehicle Endpoints ============
  /// Get all vehicles / Add new vehicle
  static const String transportVehicles = 'transport/me/vehicles/';
  /// Get/update/delete specific vehicle
  static String transportVehicleById(int vehicleId) => 'transport/me/vehicles/$vehicleId/';

  // ============ Transport Request Endpoints (Provider) ============
  /// Get nearby requests for provider
  static const String transportProviderRequests = 'transport/provider/requests/';
  /// Accept a transport request
  static String transportRequestAccept(int requestId) => 'transport/provider/requests/$requestId/accept/';
  /// Propose fare for a transport request
  static String transportRequestProposeFare(int requestId) => 'transport/provider/requests/$requestId/propose-fare/';
  /// Confirm pickup for a transport request
  static String transportRequestConfirmPickup(int requestId) => 'transport/provider/requests/$requestId/confirm-pickup/';
  /// Cancel a transport job
  static String transportRequestCancel(int requestId) => 'transport/provider/requests/$requestId/cancel/';
  /// Get single transport request details
  static String transportRequestById(int requestId) => 'transport/provider/requests/$requestId/';

  // ============ Transport Chat Endpoints ============
  /// Get messages for a transport request
  static String transportMessages(int requestId) => 'transport/requests/$requestId/messages/';
  /// Mark messages as read for a transport request
  static String transportMessagesRead(int requestId) => 'transport/requests/$requestId/messages/read/';
  /// Get unread message count for a transport request
  static String transportMessagesUnreadCount(int requestId) => 'transport/requests/$requestId/messages/unread-count/';

  // ============ Transport Jobs Endpoints ============
  /// Get provider's jobs (with status filter)
  static const String transportMyJobs = 'transport/provider/my-jobs/';

  // ============ Transport Stats Endpoints ============
  /// Get provider dashboard stats
  static const String transportDashboardStats = 'transport/provider/stats/';

  // ============ Example CRUD Endpoints ============
  // Add your Django model endpoints here

  // Products (example)
  static const String products = 'products/';
  static String productById(int id) => 'products/$id/';

  // Categories (example)
  static const String categories = 'categories/';
  static String categoryById(int id) => 'categories/$id/';
}

