import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/user_model.dart';
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

/// App Routes
///
/// Centralized navigation configuration.
/// Usage:
///   Navigator.pushNamed(context, AppRoutes.login);
///   Navigator.pushNamed(context, AppRoutes.home);

class AppRoutes {
  // ============ Route Names ============
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

  // ============ Route Generator ============
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
