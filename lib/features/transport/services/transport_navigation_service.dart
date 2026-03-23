/// Transport Navigation Service
///
/// Provides navigation helpers for transport feature screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/routes/app_routes.dart';

class TransportNavigationService {
  /// Navigate to transport dashboard (clear all previous routes)
  static void navigateToDashboard(BuildContext context) {
    AppRoutes.navigateAndRemoveAll(context, AppRoutes.transportDashboard);
  }

  /// Navigate to role request screen
  static void navigateToRoleRequest(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportRoleRequest);
  }

  /// Navigate to onboarding form
  static void navigateToOnboardingForm(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportOnboarding);
  }

  /// Navigate to pending approval screen
  static void navigateToPendingApproval(BuildContext context, int requestId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportPendingApproval,
      arguments: requestId,
    );
  }

  /// Navigate to license upload screen
  static void navigateToLicenseUpload(BuildContext context, int requestId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportLicenseUpload,
      arguments: requestId,
    );
  }


  /// Navigate to transport profile
  static void navigateToProfile(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportProfile);
  }

  /// Navigate to vehicle list
  static void navigateToVehicleList(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportVehicleList);
  }

  /// Navigate to vehicle form (add new)
  static void navigateToAddVehicle(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportVehicleForm);
  }

  /// Navigate to vehicle form (edit existing)
  static void navigateToEditVehicle(BuildContext context, int vehicleId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportVehicleForm,
      arguments: {'vehicleId': vehicleId, 'isEdit': true},
    );
  }

  /// Navigate to nearby requests
  static void navigateToNearbyRequests(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportNearbyRequests);
  }

  /// Navigate to request detail
  static void navigateToRequestDetail(
    BuildContext context,
    TransportRequestModel request,
  ) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportRequestDetail,
      arguments: request,
    );
  }

  /// Navigate to accept request screen
  static void navigateToAcceptRequest(
    BuildContext context,
    TransportRequestModel request,
  ) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportAcceptRequest,
      arguments: request,
    );
  }

  /// Navigate to trip progress screen
  static void navigateToTripProgress(BuildContext context, int requestId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportTripProgress,
      arguments: requestId,
    );
  }

  /// Navigate to trip completion screen
  static void navigateToTripCompletion(
    BuildContext context,
    TransportRequestModel request,
  ) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportTripCompletion,
      arguments: request,
    );
  }

  /// Navigate to transport chat
  static void navigateToChat(BuildContext context, int requestId) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportChat,
      arguments: requestId,
    );
  }

  /// Navigate back
  static void goBack(BuildContext context) {
    AppRoutes.goBack(context);
  }

  /// Navigate back with result
  static void goBackWithResult<T>(BuildContext context, T result) {
    AppRoutes.goBackWithResult(context, result);
  }

  /// Navigate and replace current screen
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    AppRoutes.navigateAndReplace(context, routeName, arguments: arguments);
  }

  // ============ Requester Navigation ============

  /// Navigate to create transport request wizard
  static void navigateToCreateRequest(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportCreateRequest);
  }

  /// Navigate to my requests (requester's requests list)
  static void navigateToMyRequests(BuildContext context) {
    AppRoutes.navigateTo(context, AppRoutes.transportMyRequests);
  }

  /// Navigate to my requests and clear stack
  static void navigateToMyRequestsAndClear(BuildContext context) {
    AppRoutes.navigateAndRemoveAll(context, AppRoutes.transportMyRequests);
  }

  /// Navigate to requester request detail
  static void navigateToRequesterRequestDetail(
    BuildContext context,
    int requestId,
  ) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportRequesterRequestDetail,
      arguments: requestId,
    );
  }

  /// Navigate to delivery confirmation screen
  static void navigateToDeliveryConfirmation(
    BuildContext context,
    int requestId,
  ) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.transportDeliveryConfirmation,
      arguments: requestId,
    );
  }
}
