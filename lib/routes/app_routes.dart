import 'package:flutter/material.dart';
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

  // ============ Route Generator ============
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case languageSelection:
        return _buildRoute(const LanguageSelectionScreen(), settings);

      case login:
      case signup:
      case phoneLogin:
        // All these routes go to SendOtpPage (Login screen)
        return _buildRoute(const SendOtpPage(), settings);

      case emailLogin:
        return _buildRoute(const EmailLoginPage(), settings);

      case forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ResetPasswordPage(token: args?['token'] as String?),
          settings,
        );

      case register:
        return _buildRoute(const RegisterPage(), settings);

      case otpVerification:
        // Extract phone number from arguments
        final args = settings.arguments;
        if (args is String) {
          return _buildRoute(
            OtpVerificationPage(mobileNumber: args),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Phone number required for OTP verification')),
          ),
          settings,
        );

      case home:
        // Get user from arguments if passed
        final args = settings.arguments;
        UserModel? user;
        if (args is Map<String, dynamic>) {
          user = args['user'] as UserModel?;
        }
        return _buildRoute(MainShellPage(user: user), settings);

      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);

      case profile:
        return _buildRoute(const ProfilePage(), settings);

      case editProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          EditProfilePage(
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
          ),
          settings,
        );

      case createFarm:
        return _buildRoute(const CreateFarmPage(), settings);

      case animalDetail:
        final listingId = settings.arguments as int?;
        if (listingId != null) {
          return _buildRoute(
            AnimalDetailPage(listingId: listingId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Listing ID required for animal detail')),
          ),
          settings,
        );

      case vetServices:
        return _buildRoute(const VetServicesPage(), settings);

      case vetDetail:
        final vetId = settings.arguments as int?;
        if (vetId != null) {
          return _buildRoute(
            VetDetailPage(vetId: vetId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Vet ID required for vet detail')),
          ),
          settings,
        );

      case vetOnboardingCarousel:
        return _buildRoute(const VetOnboardingCarouselScreen(), settings);

      case vetDocumentUpload:
        return _buildRoute(const VetDocumentUploadScreen(), settings);

      case vetVerificationStatus:
        return _buildRoute(const VetVerificationStatusScreen(), settings);

      case vetDocumentReupload:
        final status = settings.arguments as VetVerificationStatusModel?;
        if (status != null) {
          return _buildRoute(
            VetDocumentReuploadScreen(verificationStatus: status),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Verification status required')),
          ),
          settings,
        );

      case vetProfile:
        return _buildRoute(const VetProfileScreen(), settings);

      case vetAvailability:
        return _buildRoute(const VetAvailabilityScreen(), settings);

      case vetPricing:
        return _buildRoute(const VetPricingScreen(), settings);

      case bookAppointment:
        final vet = settings.arguments as VetModel?;
        if (vet != null) {
          return _buildRoute(
            BookAppointmentScreen(vet: vet),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Vet info required for booking')),
          ),
          settings,
        );

      case myAppointments:
        return _buildRoute(const MyAppointmentsScreen(), settings);

      case appointmentDetail:
        final appointmentId = settings.arguments as int?;
        if (appointmentId != null) {
          return _buildRoute(
            AppointmentDetailScreen(appointmentId: appointmentId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Appointment ID required')),
          ),
          settings,
        );

      case vetAppointments:
        return _buildRoute(const VetAppointmentsScreen(), settings);

      case vetApproveAppointment:
        final args = settings.arguments as Map<String, dynamic>?;
        final appointment = args?['appointment'] as AppointmentModel?;
        final vetId = args?['vetId'] as int?;
        if (appointment != null && vetId != null) {
          return _buildRoute(
            ApproveAppointmentScreen(appointment: appointment, vetId: vetId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Appointment and vet ID required')),
          ),
          settings,
        );

      case vetRejectAppointment:
        final appointment = settings.arguments as AppointmentModel?;
        if (appointment != null) {
          return _buildRoute(
            RejectAppointmentScreen(appointment: appointment),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Appointment required for rejection')),
          ),
          settings,
        );

      case vetCompleteAppointment:
        final appointment = settings.arguments as AppointmentModel?;
        if (appointment != null) {
          return _buildRoute(
            CompleteAppointmentScreen(appointment: appointment),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Appointment required for completion')),
          ),
          settings,
        );

      case appointmentChat:
        final appointment = settings.arguments as AppointmentModel?;
        if (appointment != null) {
          return _buildRoute(
            AppointmentChatScreen(appointment: appointment),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Appointment required for chat')),
          ),
          settings,
        );

      case vetHome:
        return _buildRoute(const VetHomePage(), settings);

      case vetDashboardProfile:
        return _buildRoute(const VetDashboardProfilePage(), settings);

      case recentlyViewed:
        return _buildRoute(const RecentlyViewedPage(), settings);

      case editListingDetails:
        final listingId = settings.arguments is int
            ? settings.arguments as int
            : (settings.arguments as Map<String, dynamic>?)?['listingId'] as int?;
        if (listingId != null) {
          return _buildRoute(
            EditListingPage(listingId: listingId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Listing ID required for edit')),
          ),
          settings,
        );

      case conversations:
        return _buildRoute(const ConversationsPage(), settings);

      case directChat:
        final conversation = settings.arguments as Conversation?;
        if (conversation != null) {
          return _buildRoute(
            DirectChatScreen(conversation: conversation),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Conversation required for chat')),
          ),
          settings,
        );

      case myBids:
        return _buildRoute(const MyBidsPage(), settings);

      case listingBids:
        final listingId = settings.arguments as int?;
        if (listingId != null) {
          return _buildRoute(
            ListingBidsPage(listingId: listingId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Listing ID required for bids')),
          ),
          settings,
        );

      case notifications:
        return _buildRoute(const NotificationScreen(), settings);

      case favouriteListings:
        return _buildRoute(const FavouriteListingsPage(), settings);

      case chooseIdentity:
        final args = settings.arguments;
        return _buildRoute(
          ChooseIdentityPage(user: args is UserModel ? args : null),
          settings,
        );

      // ============ Farmer Transport Routes ============
      case bookTransport:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          BookTransportScreen(
            listingId: args?['listingId'] as int?,
            animalName: args?['animalName'] as String?,
            sellerLocation: args?['sellerLocation'] as String?,
            sellerLat: args?['sellerLat'] as double?,
            sellerLng: args?['sellerLng'] as double?,
            animalSpecies: args?['animalSpecies'] as String?,
          ),
          settings,
        );

      case myTransportBookings:
        return _buildRoute(const MyTransportBookingsScreen(), settings);

      case farmerTransportDetail:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            FarmerTransportDetailScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
              body: Center(child: Text('Request ID required'))),
          settings,
        );

      // ============ Transport Provider Routes ============
      case transportDashboard:
        return _buildRoute(const TransportDashboardScreen(), settings);

      case transportNearbyRequests:
        return _buildRoute(const NearbyRequestsScreen(), settings);

      case transportRequestDetail:
        final request = settings.arguments as TransportRequestModel?;
        if (request != null) {
          return _buildRoute(
            RequestDetailScreen(request: request),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request data required')),
          ),
          settings,
        );

      case transportAcceptRequest:
        final request = settings.arguments as TransportRequestModel?;
        if (request != null) {
          return _buildRoute(
            AcceptRequestScreen(request: request),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request data required')),
          ),
          settings,
        );

      case transportTripProgress:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            TripProgressScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      case transportVehicleList:
        return _buildRoute(const VehicleListScreen(), settings);

      case transportRoleRequest:
        return _buildRoute(const RoleRequestScreen(), settings);

      case transportOnboarding:
        return _buildRoute(const OnboardingFormScreen(), settings);

      case transportPendingApproval:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            PendingApprovalScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      case transportLicenseUpload:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            LicenseUploadScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      case transportProfile:
        return _buildRoute(const TransportProfileScreen(), settings);

      case transportVehicleForm:
        final args = settings.arguments as Map<String, dynamic>?;
        final vehicleId = args?['vehicleId'] as int?;
        return _buildRoute(
          VehicleFormScreen(vehicleId: vehicleId),
          settings,
        );

      case transportTripCompletion:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            TripCompletionScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      case transportChat:
        final args = settings.arguments;
        if (args is int) {
          return _buildRoute(
            TransportChatScreen(requestId: args),
            settings,
          );
        } else if (args is Map<String, dynamic>) {
          return _buildRoute(
            TransportChatScreen(
              requestId: args['requestId'] as int,
              otherUserName: args['otherUserName'] as String?,
            ),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      // ============ Transport Requester Routes ============
      case transportCreateRequest:
        return _buildRoute(const CreateRequestScreen(), settings);

      case transportMyRequests:
        return _buildRoute(const MyRequestsScreen(), settings);

      case transportRequesterRequestDetail:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            RequesterRequestDetailScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      case transportDeliveryConfirmation:
        final requestId = settings.arguments as int?;
        if (requestId != null) {
          return _buildRoute(
            DeliveryConfirmationScreen(requestId: requestId),
            settings,
          );
        }
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Request ID required')),
          ),
          settings,
        );

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
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
