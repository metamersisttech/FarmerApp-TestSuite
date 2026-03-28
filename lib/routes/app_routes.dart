import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/features/language/screens/language_selection_screen.dart';
import 'package:flutter_app/features/settings/screens/settings_screen.dart';
import 'package:flutter_app/features/auth/screens/email_login_page.dart';
import 'package:flutter_app/features/auth/screens/otp_verification_page.dart';
import 'package:flutter_app/features/auth/screens/register_page.dart';
import 'package:flutter_app/features/auth/screens/sendOtp_page.dart';
import 'package:flutter_app/features/editprofile/screens/edit_profile_page.dart';
import 'package:flutter_app/features/forgotPassword/screens/forgot_password_page.dart';
import 'package:flutter_app/features/home/screens/animal_detail_page.dart';
import 'package:flutter_app/features/home/screens/main_shell_page.dart';
import 'package:flutter_app/features/profile/screens/profile_page.dart';
import 'package:flutter_app/features/resetPassword/screens/reset_password_page.dart';
import 'package:flutter_app/features/postlistings/screens/create_farm_page.dart';
import 'package:flutter_app/features/vet/screens/vet_detail_page.dart';
import 'package:flutter_app/features/vet/screens/vet_services_page.dart';
import 'package:flutter_app/features/vet/screens/vet_onboarding_carousel_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_document_upload_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_verification_status_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_document_reupload_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_profile_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_availability_screen.dart';
import 'package:flutter_app/features/vet/screens/vet_pricing_screen.dart';
import 'package:flutter_app/features/vet/models/vet_verification_status_model.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/appointment/screens/book_appointment_screen.dart';
import 'package:flutter_app/features/appointment/screens/my_appointments_screen.dart';
import 'package:flutter_app/features/appointment/screens/appointment_detail_screen.dart';
import 'package:flutter_app/features/appointment/screens/vet_appointments_screen.dart';
import 'package:flutter_app/features/appointment/screens/approve_appointment_screen.dart';
import 'package:flutter_app/features/appointment/screens/reject_appointment_screen.dart';
import 'package:flutter_app/features/appointment/screens/complete_appointment_screen.dart';
import 'package:flutter_app/features/appointment/screens/appointment_chat_screen.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/vet_dashboard/screens/vet_home_page.dart';
import 'package:flutter_app/features/vet_dashboard/screens/vet_dashboard_profile_page.dart';
import 'package:flutter_app/features/recentlyviewed/screens/recentlyviewed_page.dart';
import 'package:flutter_app/features/editlistings/screens/edit_listing_page.dart';
import 'package:flutter_app/features/messaging/models/conversation_model.dart';
import 'package:flutter_app/features/messaging/screens/conversations_page.dart';
import 'package:flutter_app/features/messaging/screens/direct_chat_screen.dart';
import 'package:flutter_app/features/bidding/screens/my_bids_page.dart';
import 'package:flutter_app/features/bidding/screens/listing_bids_page.dart';
import 'package:flutter_app/features/notifications/screens/notification_screen.dart';
import 'package:flutter_app/features/favourite/screens/favourite_listings_page.dart';
import 'package:flutter_app/features/useridentity/screens/choose_identity_page.dart';
// Transport feature imports
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/screens/farmer/book_transport_screen.dart';
import 'package:flutter_app/features/transport/screens/farmer/my_transport_bookings_screen.dart';
import 'package:flutter_app/features/transport/screens/farmer/farmer_transport_detail_screen.dart';
import 'package:flutter_app/features/transport/screens/chat/transport_chat_screen.dart';
import 'package:flutter_app/features/transport/screens/home/transport_dashboard_screen.dart';
import 'package:flutter_app/features/transport/screens/onboarding/license_upload_screen.dart';
import 'package:flutter_app/features/transport/screens/onboarding/onboarding_form_screen.dart';
import 'package:flutter_app/features/transport/screens/onboarding/pending_approval_screen.dart';
import 'package:flutter_app/features/transport/screens/onboarding/role_request_screen.dart';
import 'package:flutter_app/features/transport/screens/profile/transport_profile_screen.dart';
import 'package:flutter_app/features/transport/screens/requests/nearby_requests_screen.dart';
import 'package:flutter_app/features/transport/screens/requests/request_detail_screen.dart';
import 'package:flutter_app/features/transport/screens/requests/accept_request_screen.dart';
import 'package:flutter_app/features/transport/screens/trip/trip_completion_screen.dart';
import 'package:flutter_app/features/transport/screens/trip/trip_progress_screen.dart';
import 'package:flutter_app/features/transport/screens/vehicles/vehicle_form_screen.dart';
import 'package:flutter_app/features/transport/screens/vehicles/vehicle_list_screen.dart';
// Transport requester screens
import 'package:flutter_app/features/transport/screens/requester/create_request_screen.dart';
import 'package:flutter_app/features/transport/screens/requester/my_requests_screen.dart';
import 'package:flutter_app/features/transport/screens/requester/requester_request_detail_screen.dart';
import 'package:flutter_app/features/transport/screens/requester/delivery_confirmation_screen.dart';

/// App Routes
///
/// Centralized navigation configuration.
/// Usage:
///   Navigator.pushNamed(context, AppRoutes.login);
///   Navigator.pushNamed(context, AppRoutes.home);

class AppRoutes {
  // ============ Route Names ============
  static const String languageSelection = '/language-selection';
  static const String login = '/'; // Login is now the initial route
  static const String signup = '/signup'; // Alias for login
  // static const String phoneLogin = '/phone-login'; // Alias for login
  static const String welcome = '/';
  static const String phoneLogin = '/phone-login';
  static const String emailLogin = '/email-login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String createFarm = '/create-farm';
  static const String animalDetail = '/animal-detail';
  static const String vetServices = '/vet-services';
  static const String vetDetail = '/vet-detail';
  static const String vetOnboardingCarousel = '/vet-onboarding-carousel';
  static const String vetDocumentUpload = '/vet-document-upload';
  static const String vetVerificationStatus = '/vet-verification-status';
  static const String vetDocumentReupload = '/vet-document-reupload';
  static const String vetProfile = '/vet-profile';
  static const String vetAvailability = '/vet-availability';
  static const String vetPricing = '/vet-pricing';
  static const String bookAppointment = '/book-appointment';
  static const String myAppointments = '/my-appointments';
  static const String appointmentDetail = '/appointment-detail';
  static const String vetAppointments = '/vet-appointments';
  static const String vetApproveAppointment = '/vet-approve-appointment';
  static const String vetRejectAppointment = '/vet-reject-appointment';
  static const String vetCompleteAppointment = '/vet-complete-appointment';
  static const String appointmentChat = '/appointment-chat';
  static const String vetHome = '/vet-home';
  static const String vetDashboardProfile = '/vet-dashboard-profile';
  static const String recentlyViewed = '/recently-viewed';
  static const String editListingDetails = '/edit-listing-details';
  static const String conversations = '/conversations';
  static const String directChat = '/direct-chat';
  static const String myBids = '/my-bids';
  static const String listingBids = '/listing-bids';
  static const String notifications = '/notifications';
  static const String favouriteListings = '/favourite-listings';
  static const String chooseIdentity = '/choose-identity';

  // ============ Farmer Transport Routes ============
  static const String bookTransport = '/transport/book';
  static const String myTransportBookings = '/transport/my-bookings';
  static const String farmerTransportDetail = '/transport/booking-detail';

  // ============ Transport Provider Routes ============
  static const String transportRoleRequest = '/transport/role-request';
  static const String transportOnboarding = '/transport/onboarding';
  static const String transportPendingApproval = '/transport/pending-approval';
  static const String transportLicenseUpload = '/transport/license-upload';
  static const String transportProfile = '/transport/profile';
  static const String transportVehicleList = '/transport/vehicles';
  static const String transportVehicleForm = '/transport/vehicles/form';
  static const String transportDashboard = '/transport/dashboard';
  static const String transportNearbyRequests = '/transport/requests/nearby';
  static const String transportRequestDetail = '/transport/requests/detail';
  static const String transportAcceptRequest = '/transport/requests/accept';
  static const String transportTripProgress = '/transport/trip/progress';
  static const String transportTripCompletion = '/transport/trip/completion';
  static const String transportChat = '/transport/chat';

  // ============ Transport Requester Routes ============
  static const String transportCreateRequest = '/transport/requester/create';
  static const String transportMyRequests = '/transport/requester/my-requests';
  static const String transportRequesterRequestDetail = '/transport/requester/request-detail';
  static const String transportDeliveryConfirmation = '/transport/requester/delivery-confirmation';

  // ============ Route Guard Definitions ============

  /// Routes that do NOT require authentication (public routes)
  static const Set<String> _publicRoutes = {
    login,
    signup,
    phoneLogin,
    // welcome is same as login ('/')
    emailLogin,
    forgotPassword,
    resetPassword,
    register,
    otpVerification,
    languageSelection,
  };

  /// Routes that require the 'vet' app mode
  static const Set<String> _vetRoutes = {
    vetOnboardingCarousel,
    vetDocumentUpload,
    vetVerificationStatus,
    vetDocumentReupload,
    vetProfile,
    vetAvailability,
    vetPricing,
    vetAppointments,
    vetApproveAppointment,
    vetRejectAppointment,
    vetCompleteAppointment,
    vetHome,
    vetDashboardProfile,
  };

  /// Routes that require the 'transport' app mode
  static const Set<String> _transportProviderRoutes = {
    transportDashboard,
    transportNearbyRequests,
    transportRequestDetail,
    transportAcceptRequest,
    transportTripProgress,
    transportTripCompletion,
    transportVehicleList,
    transportVehicleForm,
    transportRoleRequest,
    transportOnboarding,
    transportPendingApproval,
    transportLicenseUpload,
    transportProfile,
  };

  /// Determine required app mode for a route (null = any authenticated user)
  static String? _requiredModeForRoute(String? routeName) {
    if (_vetRoutes.contains(routeName)) return 'vet';
    if (_transportProviderRoutes.contains(routeName)) return 'transport';
    return null;
  }

  // ============ Route Generator ============
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Build the destination widget from the switch/case
    final Widget destinationWidget = _resolveWidget(settings);

    // Public routes: no guard needed
    if (_publicRoutes.contains(settings.name)) {
      return _buildRoute(destinationWidget, settings);
    }

    // All other routes: wrap with route guard
    final requiredMode = _requiredModeForRoute(settings.name);
    return _buildRoute(
      _RouteGuard(
        requiredMode: requiredMode,
        child: destinationWidget,
      ),
      settings,
    );
  }

  /// Resolve the destination widget for a route name (original switch logic)
  static Widget _resolveWidget(RouteSettings settings) {
    switch (settings.name) {
      case languageSelection:
        return const LanguageSelectionScreen();

      case login:
      case signup:
      case phoneLogin:
        // All these routes go to SendOtpPage (Login screen)
        return const SendOtpPage();

      case emailLogin:
        return const EmailLoginPage();

      case forgotPassword:
        return const ForgotPasswordPage();

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return ResetPasswordPage(token: args?['token'] as String?);

      case register:
        return const RegisterPage();

      case otpVerification:
        // Extract phone number from arguments
        final args = settings.arguments;
        if (args is String) {
          return OtpVerificationPage(mobileNumber: args);
        }
        return const Scaffold(
          body: Center(child: Text('Phone number required for OTP verification')),
        );

      case home:
        // Get user from arguments if passed
        final args = settings.arguments;
        UserModel? user;
        if (args is Map<String, dynamic>) {
          user = args['user'] as UserModel?;
        }
        return MainShellPage(user: user);

      case '/settings':
        return const SettingsScreen();

      case profile:
        return const ProfilePage();

      case editProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return EditProfilePage(
          initialFullName: args?['fullName'],
          initialDisplayName: args?['displayName'],
          initialDob: args?['dob'],
          initialAddress: args?['address'],
          initialState: args?['state'],
          initialDistrict: args?['district'],
          initialVillage: args?['village'],
          initialPincode: args?['pincode'],
          initialLatitude: args?['latitude'],
          initialLongitude: args?['longitude'],
          initialAbout: args?['about'],
          initialProfileImageUrl: args?['profileImageUrl'],
        );

      case createFarm:
        return const CreateFarmPage();

      case animalDetail:
        final listingId = settings.arguments as int?;
        if (listingId != null) {
          return AnimalDetailPage(listingId: listingId);
        }
        return const Scaffold(
          body: Center(child: Text('Listing ID required for animal detail')),
        );

      case vetServices:
        return const VetServicesPage();

      case vetDetail:
        final vetId = settings.arguments as int?;
        if (vetId != null) {
          return VetDetailPage(vetId: vetId);
        }
        return const Scaffold(
          body: Center(child: Text('Vet ID required for vet detail')),
        );

      case vetOnboardingCarousel:
        return const VetOnboardingCarouselScreen();

      case vetDocumentUpload:
        return const VetDocumentUploadScreen();

      case vetVerificationStatus:
        return const VetVerificationStatusScreen();

      case vetDocumentReupload:
        final status = settings.arguments as VetVerificationStatusModel?;
        if (status != null) {
          return VetDocumentReuploadScreen(verificationStatus: status);
        }
        return const Scaffold(
          body: Center(child: Text('Verification status required')),
        );

      case vetProfile:
        return const VetProfileScreen();

      case vetAvailability:
        return const VetAvailabilityScreen();

      case vetPricing:
        return const VetPricingScreen();

      case bookAppointment:
        final vet = settings.arguments as VetModel?;
        if (vet != null) {
          return BookAppointmentScreen(vet: vet);
        }
        return const Scaffold(
          body: Center(child: Text('Vet info required for booking')),
        );

      case myAppointments:
        return const MyAppointmentsScreen();

      case appointmentDetail:
        final appointmentId = settings.arguments as int?;
        if (appointmentId != null) {
          return AppointmentDetailScreen(appointmentId: appointmentId);
        }
        return const Scaffold(
          body: Center(child: Text('Appointment ID required')),
        );

      case vetAppointments:
        return const VetAppointmentsScreen();

      case vetApproveAppointment:
        final args = settings.arguments as Map<String, dynamic>?;
        final appointment = args?['appointment'] as AppointmentModel?;
        final vetId = args?['vetId'] as int?;
        if (appointment != null && vetId != null) {
          return ApproveAppointmentScreen(appointment: appointment, vetId: vetId);
        }
        return const Scaffold(
          body: Center(child: Text('Appointment and vet ID required')),
        );

      case vetRejectAppointment:
        final appointment = settings.arguments as AppointmentModel?;
        if (appointment != null) {
          return RejectAppointmentScreen(appointment: appointment);
        }
        return const Scaffold(
          body: Center(child: Text('Appointment required for rejection')),
        );

      case vetCompleteAppointment:
        final appointment = settings.arguments as AppointmentModel?;
        if (appointment != null) {
          return CompleteAppointmentScreen(appointment: appointment);
        }
        return const Scaffold(
          body: Center(child: Text('Appointment required for completion')),
        );

      case appointmentChat:
        final appointment = settings.arguments as AppointmentModel?;
        if (appointment != null) {
          return AppointmentChatScreen(appointment: appointment);
        }
        return const Scaffold(
          body: Center(child: Text('Appointment required for chat')),
        );

      case vetHome:
        return const VetHomePage();

      case vetDashboardProfile:
        return const VetDashboardProfilePage();

      case recentlyViewed:
        return const RecentlyViewedPage();

      case editListingDetails:
        final listingId = settings.arguments is int
            ? settings.arguments as int
            : (settings.arguments as Map<String, dynamic>?)?['listingId'] as int?;
        if (listingId != null) {
          return EditListingPage(listingId: listingId);
        }
        return const Scaffold(
          body: Center(child: Text('Listing ID required for edit')),
        );

      case conversations:
        return const ConversationsPage();

      case directChat:
        final conversation = settings.arguments as Conversation?;
        if (conversation != null) {
          return DirectChatScreen(conversation: conversation);
        }
        return const Scaffold(
          body: Center(child: Text('Conversation required for chat')),
        );

      case myBids:
        return const MyBidsPage();

      case listingBids:
        final listingId = settings.arguments as int?;
        if (listingId != null) {
          return ListingBidsPage(listingId: listingId);
        }
        return const Scaffold(
          body: Center(child: Text('Listing ID required for bids')),
        );

      case notifications:
        return const NotificationScreen();

      case favouriteListings:
        return const FavouriteListingsPage();

      case chooseIdentity:
        final args = settings.arguments;
        return ChooseIdentityPage(user: args is UserModel ? args : null);

      // ============ Farmer Transport Routes ============
      case bookTransport:
        final args = settings.arguments as Map<String, dynamic>?;
        return BookTransportScreen(
          listingId: args?['listingId'] as int?,
          animalName: args?['animalName'] as String?,
          sellerLocation: args?['sellerLocation'] as String?,
          sellerLat: args?['sellerLat'] as double?,
          sellerLng: args?['sellerLng'] as double?,
          animalSpecies: args?['animalSpecies'] as String?,
        );

      case myTransportBookings:
        return const MyTransportBookingsScreen();

      case farmerTransportDetail:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return FarmerTransportDetailScreen(requestId: requestId);
        }
        return const Scaffold(
            body: Center(child: Text('Request ID required')));

      // ============ Transport Provider Routes ============
      case transportDashboard:
        return const TransportDashboardScreen();

      case transportNearbyRequests:
        return const NearbyRequestsScreen();

      case transportRequestDetail:
        final request = settings.arguments as TransportRequestModel?;
        if (request != null) {
          return RequestDetailScreen(request: request);
        }
        return const Scaffold(
          body: Center(child: Text('Request data required')),
        );

      case transportAcceptRequest:
        final request = settings.arguments as TransportRequestModel?;
        if (request != null) {
          return AcceptRequestScreen(request: request);
        }
        return const Scaffold(
          body: Center(child: Text('Request data required')),
        );

      case transportTripProgress:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return TripProgressScreen(requestId: requestId);
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      case transportVehicleList:
        return const VehicleListScreen();

      case transportRoleRequest:
        return const RoleRequestScreen();

      case transportOnboarding:
        return const OnboardingFormScreen();

      case transportPendingApproval:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return PendingApprovalScreen(requestId: requestId);
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      case transportLicenseUpload:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return LicenseUploadScreen(requestId: requestId);
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      case transportProfile:
        return const TransportProfileScreen();

      case transportVehicleForm:
        final args = settings.arguments as Map<String, dynamic>?;
        final vehicleId = args?['vehicleId'] as int?;
        return VehicleFormScreen(vehicleId: vehicleId);

      case transportTripCompletion:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return TripCompletionScreen(requestId: requestId);
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      case transportChat:
        final args = settings.arguments;
        if (args is int) {
          return TransportChatScreen(requestId: args);
        } else if (args is Map<String, dynamic>) {
          return TransportChatScreen(
            requestId: args['requestId'] as int,
            otherUserName: args['otherUserName'] as String?,
          );
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      // ============ Transport Requester Routes ============
      case transportCreateRequest:
        return const CreateRequestScreen();

      case transportMyRequests:
        return const MyRequestsScreen();

      case transportRequesterRequestDetail:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return RequesterRequestDetailScreen(requestId: requestId);
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      case transportDeliveryConfirmation:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return DeliveryConfirmationScreen(requestId: requestId);
        }
        return const Scaffold(
          body: Center(child: Text('Request ID required')),
        );

      default:
        return Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        );
    }
  }

  /// Build a MaterialPageRoute with given widget
  static MaterialPageRoute _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }

  // ============ Navigation Helpers ============

  /// Navigate to a route and remove all previous routes
  static void navigateAndRemoveAll(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to a route and replace current route
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  /// Navigate to a route
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Go back to previous route
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Go back to previous route with result
  static void goBackWithResult<T>(BuildContext context, T result) {
    Navigator.pop(context, result);
  }
}

// ============ Route Guard Widget ============

/// Async route guard that checks authentication and app mode before
/// rendering the child widget. Redirects to login if not authenticated,
/// or shows an access denied screen if the user's app mode doesn't match.
///
/// [requiredMode] - The app mode required to access this route ('vet',
///   'transport'). If null, any authenticated user can access the route.
class _RouteGuard extends StatelessWidget {
  final String? requiredMode;
  final Widget child;

  const _RouteGuard({
    required this.requiredMode,
    required this.child,
  });

  Future<_GuardResult> _checkAccess() async {
    final commonHelper = CommonHelper();

    // Check authentication
    final user = await commonHelper.getLoggedInUser();
    if (user == null) {
      return _GuardResult.notAuthenticated;
    }

    // Check role/mode if required
    if (requiredMode != null) {
      final currentMode = await commonHelper.getAppMode();
      if (currentMode != requiredMode) {
        return _GuardResult.accessDenied;
      }
    }

    return _GuardResult.allowed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_GuardResult>(
      future: _checkAccess(),
      builder: (context, snapshot) {
        // While checking auth, show a loading indicator
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        switch (snapshot.data!) {
          case _GuardResult.notAuthenticated:
            // Redirect to login after the current frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case _GuardResult.accessDenied:
            // Show inline access denied screen
            final modeLabel = requiredMode == 'vet'
                ? 'Veterinarian'
                : requiredMode == 'transport'
                    ? 'Transport Provider'
                    : requiredMode ?? 'Unknown';
            return Scaffold(
              appBar: AppBar(
                title: const Text('Access Denied'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Access Denied',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You need the $modeLabel role to access this page.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            );

          case _GuardResult.allowed:
            return child;
        }
      },
    );
  }
}

/// Result of a route guard check
enum _GuardResult {
  allowed,
  notAuthenticated,
  accessDenied,
}
