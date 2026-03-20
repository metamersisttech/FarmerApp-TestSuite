/// Transport Result Models
///
/// Result objects for Transport services following the Result pattern.
/// These provide explicit success/error handling without exceptions at UI layer.
library;

import 'package:flutter_app/features/transport/models/onboarding_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_message_model.dart';
import 'package:flutter_app/features/transport/models/transport_provider_model.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_verification_status_model.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

/// Base result class
abstract class TransportResult {
  final bool success;
  final String? errorMessage;

  const TransportResult({
    required this.success,
    this.errorMessage,
  });
}

/// Result for onboarding operations
class OnboardingResult extends TransportResult {
  final int? requestId;
  final OnboardingRequestModel? request;

  const OnboardingResult({
    required super.success,
    super.errorMessage,
    this.requestId,
    this.request,
  });

  factory OnboardingResult.successful({
    int? requestId,
    OnboardingRequestModel? request,
  }) {
    return OnboardingResult(
      success: true,
      requestId: requestId ?? request?.requestId,
      request: request,
    );
  }

  factory OnboardingResult.failed(String errorMessage) {
    return OnboardingResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for verification status check
class VerificationStatusResult extends TransportResult {
  final TransportVerificationStatusModel? verificationStatus;

  const VerificationStatusResult({
    required super.success,
    super.errorMessage,
    this.verificationStatus,
  });

  factory VerificationStatusResult.successful(TransportVerificationStatusModel status) {
    return VerificationStatusResult(
      success: true,
      verificationStatus: status,
    );
  }

  factory VerificationStatusResult.failed(String errorMessage) {
    return VerificationStatusResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for status check operations
class StatusCheckResult extends TransportResult {
  final OnboardingRequestModel? request;
  final String? status;

  const StatusCheckResult({
    required super.success,
    super.errorMessage,
    this.request,
    this.status,
  });

  factory StatusCheckResult.successful(OnboardingRequestModel request) {
    return StatusCheckResult(
      success: true,
      request: request,
      status: request.status,
    );
  }

  factory StatusCheckResult.failed(String errorMessage) {
    return StatusCheckResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for resubmit document operations
class ResubmitResult extends TransportResult {
  final OnboardingRequestModel? request;

  const ResubmitResult({
    required super.success,
    super.errorMessage,
    this.request,
  });

  factory ResubmitResult.successful(OnboardingRequestModel request) {
    return ResubmitResult(
      success: true,
      request: request,
    );
  }

  factory ResubmitResult.failed(String errorMessage) {
    return ResubmitResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for transport profile operations
class TransportProfileResult extends TransportResult {
  final TransportProviderModel? profile;

  const TransportProfileResult({
    required super.success,
    super.errorMessage,
    this.profile,
  });

  factory TransportProfileResult.successful(TransportProviderModel profile) {
    return TransportProfileResult(
      success: true,
      profile: profile,
    );
  }

  factory TransportProfileResult.failed(String errorMessage) {
    return TransportProfileResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for vehicle list operations
class VehicleListResult extends TransportResult {
  final List<VehicleModel>? vehicles;

  const VehicleListResult({
    required super.success,
    super.errorMessage,
    this.vehicles,
  });

  factory VehicleListResult.successful(List<VehicleModel> vehicles) {
    return VehicleListResult(
      success: true,
      vehicles: vehicles,
    );
  }

  factory VehicleListResult.failed(String errorMessage) {
    return VehicleListResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for single vehicle operations
class VehicleResult extends TransportResult {
  final VehicleModel? vehicle;

  const VehicleResult({
    required super.success,
    super.errorMessage,
    this.vehicle,
  });

  factory VehicleResult.successful(VehicleModel vehicle) {
    return VehicleResult(
      success: true,
      vehicle: vehicle,
    );
  }

  factory VehicleResult.failed(String errorMessage) {
    return VehicleResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for delete operations
class DeleteResult extends TransportResult {
  const DeleteResult({
    required super.success,
    super.errorMessage,
  });

  factory DeleteResult.successful() {
    return const DeleteResult(success: true);
  }

  factory DeleteResult.failed(String errorMessage) {
    return DeleteResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for availability toggle
class AvailabilityResult extends TransportResult {
  final bool? isAvailable;

  const AvailabilityResult({
    required super.success,
    super.errorMessage,
    this.isAvailable,
  });

  factory AvailabilityResult.successful(bool isAvailable) {
    return AvailabilityResult(
      success: true,
      isAvailable: isAvailable,
    );
  }

  factory AvailabilityResult.failed(String errorMessage) {
    return AvailabilityResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for location update
class LocationResult extends TransportResult {
  final double? latitude;
  final double? longitude;

  const LocationResult({
    required super.success,
    super.errorMessage,
    this.latitude,
    this.longitude,
  });

  factory LocationResult.successful(double latitude, double longitude) {
    return LocationResult(
      success: true,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory LocationResult.failed(String errorMessage) {
    return LocationResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for transport request list
class RequestListResult extends TransportResult {
  final List<TransportRequestModel>? requests;
  final int? totalCount;
  final String? nextPageUrl;

  const RequestListResult({
    required super.success,
    super.errorMessage,
    this.requests,
    this.totalCount,
    this.nextPageUrl,
  });

  factory RequestListResult.successful(
    List<TransportRequestModel> requests, {
    int? totalCount,
    String? nextPageUrl,
  }) {
    return RequestListResult(
      success: true,
      requests: requests,
      totalCount: totalCount ?? requests.length,
      nextPageUrl: nextPageUrl,
    );
  }

  factory RequestListResult.failed(String errorMessage) {
    return RequestListResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for single request operations
class RequestResult extends TransportResult {
  final TransportRequestModel? request;

  const RequestResult({
    required super.success,
    super.errorMessage,
    this.request,
  });

  factory RequestResult.successful(TransportRequestModel request) {
    return RequestResult(
      success: true,
      request: request,
    );
  }

  factory RequestResult.failed(String errorMessage) {
    return RequestResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for accept request operation
class AcceptResult extends TransportResult {
  final TransportRequestModel? request;

  const AcceptResult({
    required super.success,
    super.errorMessage,
    this.request,
  });

  factory AcceptResult.successful(TransportRequestModel request) {
    return AcceptResult(
      success: true,
      request: request,
    );
  }

  factory AcceptResult.failed(String errorMessage) {
    return AcceptResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for fare operations
class FareResult extends TransportResult {
  final TransportRequestModel? request;
  final double? proposedFare;

  const FareResult({
    required super.success,
    super.errorMessage,
    this.request,
    this.proposedFare,
  });

  factory FareResult.successful(TransportRequestModel request) {
    return FareResult(
      success: true,
      request: request,
      proposedFare: request.proposedFare,
    );
  }

  factory FareResult.failed(String errorMessage) {
    return FareResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for pickup confirmation
class PickupResult extends TransportResult {
  final TransportRequestModel? request;

  const PickupResult({
    required super.success,
    super.errorMessage,
    this.request,
  });

  factory PickupResult.successful(TransportRequestModel request) {
    return PickupResult(
      success: true,
      request: request,
    );
  }

  factory PickupResult.failed(String errorMessage) {
    return PickupResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for cancel operations
class CancelResult extends TransportResult {
  final TransportRequestModel? request;

  const CancelResult({
    required super.success,
    super.errorMessage,
    this.request,
  });

  factory CancelResult.successful({TransportRequestModel? request}) {
    return CancelResult(
      success: true,
      request: request,
    );
  }

  factory CancelResult.failed(String errorMessage) {
    return CancelResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for message list
class MessageListResult extends TransportResult {
  final List<TransportMessageModel>? messages;
  final int? unreadCount;

  const MessageListResult({
    required super.success,
    super.errorMessage,
    this.messages,
    this.unreadCount,
  });

  factory MessageListResult.successful(
    List<TransportMessageModel> messages, {
    int? unreadCount,
  }) {
    return MessageListResult(
      success: true,
      messages: messages,
      unreadCount: unreadCount,
    );
  }

  factory MessageListResult.failed(String errorMessage) {
    return MessageListResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for send message
class SendMessageResult extends TransportResult {
  final TransportMessageModel? message;

  const SendMessageResult({
    required super.success,
    super.errorMessage,
    this.message,
  });

  factory SendMessageResult.successful(TransportMessageModel message) {
    return SendMessageResult(
      success: true,
      message: message,
    );
  }

  factory SendMessageResult.failed(String errorMessage) {
    return SendMessageResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for mark as read
class MarkReadResult extends TransportResult {
  final int? markedCount;

  const MarkReadResult({
    required super.success,
    super.errorMessage,
    this.markedCount,
  });

  factory MarkReadResult.successful({int? markedCount}) {
    return MarkReadResult(
      success: true,
      markedCount: markedCount,
    );
  }

  factory MarkReadResult.failed(String errorMessage) {
    return MarkReadResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for unread count
class UnreadCountResult extends TransportResult {
  final int? count;

  const UnreadCountResult({
    required super.success,
    super.errorMessage,
    this.count,
  });

  factory UnreadCountResult.successful(int count) {
    return UnreadCountResult(
      success: true,
      count: count,
    );
  }

  factory UnreadCountResult.failed(String errorMessage) {
    return UnreadCountResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for job list (active jobs)
class JobListResult extends TransportResult {
  final List<TransportRequestModel>? jobs;
  final int? activeCount;
  final int? completedCount;

  const JobListResult({
    required super.success,
    super.errorMessage,
    this.jobs,
    this.activeCount,
    this.completedCount,
  });

  factory JobListResult.successful(
    List<TransportRequestModel> jobs, {
    int? activeCount,
    int? completedCount,
  }) {
    return JobListResult(
      success: true,
      jobs: jobs,
      activeCount: activeCount,
      completedCount: completedCount,
    );
  }

  factory JobListResult.failed(String errorMessage) {
    return JobListResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result for dashboard stats
class DashboardStatsResult extends TransportResult {
  final int? activeJobsCount;
  final int? pendingRequestsCount;
  final int? completedTripsToday;
  final double? totalEarningsToday;

  const DashboardStatsResult({
    required super.success,
    super.errorMessage,
    this.activeJobsCount,
    this.pendingRequestsCount,
    this.completedTripsToday,
    this.totalEarningsToday,
  });

  factory DashboardStatsResult.successful({
    int? activeJobsCount,
    int? pendingRequestsCount,
    int? completedTripsToday,
    double? totalEarningsToday,
  }) {
    return DashboardStatsResult(
      success: true,
      activeJobsCount: activeJobsCount,
      pendingRequestsCount: pendingRequestsCount,
      completedTripsToday: completedTripsToday,
      totalEarningsToday: totalEarningsToday,
    );
  }

  factory DashboardStatsResult.failed(String errorMessage) {
    return DashboardStatsResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
