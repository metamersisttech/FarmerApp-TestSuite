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

  // ============ Animal Endpoints ============
  static const String animals = 'animals/'; // Get all animals catalog

  // ============ Farm Endpoints ============
  static const String farms = 'farms/';

  // ============ Listing Endpoints ============
  static const String listings = 'listings/';
  static const String mylistings = 'listings/my/';
  static const String listingsBulk = 'listings/bulk/'; // Bulk fetch for delta sync (TODO: Backend to implement)

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

  // ============ Example CRUD Endpoints ============
  // Add your Django model endpoints here

  // Products (example)
  static const String products = 'products/';
  static String productById(int id) => 'products/$id/';

  // Categories (example)
  static const String categories = 'categories/';
  static String categoryById(int id) => 'categories/$id/';
}

