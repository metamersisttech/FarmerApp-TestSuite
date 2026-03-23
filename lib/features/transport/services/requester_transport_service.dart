/// Requester Transport Service
///
/// Handles transport request operations for requesters (farmers/users).
library;

import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';
import 'package:flutter_app/features/transport/models/fare_estimate_model.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class RequesterTransportService {
  final BackendHelper _backendHelper;

  RequesterTransportService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get fare estimate for a transport request
  Future<FareEstimateResult> estimateFare({
    required double sourceLatitude,
    required double sourceLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required List<CargoAnimalModel> cargoAnimals,
  }) async {
    try {
      final data = {
        'source_latitude': sourceLatitude,
        'source_longitude': sourceLongitude,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'cargo_animals': cargoAnimals.map((c) => c.toJson()).toList(),
      };

      final response = await _backendHelper.postTransportEstimate(data);
      final estimate = FareEstimateModel.fromJson(response);
      return FareEstimateResult.successful(estimate);
    } on BackendException catch (e) {
      return FareEstimateResult.failed(e.message);
    } catch (e) {
      return FareEstimateResult.failed('Failed to get fare estimate: $e');
    }
  }

  /// Create a new transport request
  Future<CreateRequestResult> createRequest({
    required String sourceAddress,
    required double sourceLatitude,
    required double sourceLongitude,
    required String destinationAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required List<CargoAnimalModel> cargoAnimals,
    required DateTime pickupDate,
    TimeOfDay? pickupTime,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'source_address': sourceAddress,
        'source_latitude': sourceLatitude,
        'source_longitude': sourceLongitude,
        'destination_address': destinationAddress,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'cargo_animals': cargoAnimals.map((c) => c.toJson()).toList(),
        'pickup_date': pickupDate.toIso8601String().split('T')[0],
      };

      if (pickupTime != null) {
        data['pickup_time'] =
            '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}';
      }

      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      final response = await _backendHelper.postTransportRequest(data);
      final request = TransportRequestModel.fromJson(response);
      return CreateRequestResult.successful(request);
    } on BackendException catch (e) {
      return CreateRequestResult.failed(e.message);
    } catch (e) {
      return CreateRequestResult.failed('Failed to create request: $e');
    }
  }

  /// Get requester's transport requests
  Future<RequestListResult> getMyRequests({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit;
      if (offset != null) params['offset'] = offset;

      final response = await _backendHelper.getMyTransportRequests(
        status: status,
        params: params.isNotEmpty ? params : null,
      );

      List<dynamic> requestsList = [];
      int? totalCount;
      String? nextPageUrl;

      if (response is List) {
        requestsList = response;
      } else if (response is Map) {
        requestsList = response['results'] as List<dynamic>? ?? [];
        totalCount = response['count'] as int?;
        nextPageUrl = response['next'] as String?;
      }

      final requests = requestsList
          .whereType<Map<String, dynamic>>()
          .map((r) => TransportRequestModel.fromJson(r))
          .toList();

      return RequestListResult.successful(
        requests,
        totalCount: totalCount,
        nextPageUrl: nextPageUrl,
      );
    } on BackendException catch (e) {
      return RequestListResult.failed(e.message);
    } catch (e) {
      return RequestListResult.failed('Failed to load requests: $e');
    }
  }

  /// Get a single request by ID
  Future<RequestResult> getRequestById(int requestId) async {
    try {
      final response =
          await _backendHelper.getTransportRequestByIdRequester(requestId);
      final request = TransportRequestModel.fromJson(response);
      return RequestResult.successful(request);
    } on BackendException catch (e) {
      return RequestResult.failed(e.message);
    } catch (e) {
      return RequestResult.failed('Failed to load request: $e');
    }
  }

  /// Cancel a transport request
  Future<CancelResult> cancelRequest(int requestId, {String? reason}) async {
    try {
      final response = await _backendHelper.postTransportRequestCancelRequester(
        requestId,
        reason,
      );
      final request = TransportRequestModel.fromJson(response);
      return CancelResult.successful(request: request);
    } on BackendException catch (e) {
      return CancelResult.failed(e.message);
    } catch (e) {
      return CancelResult.failed('Failed to cancel request: $e');
    }
  }

  /// Approve provider's proposed fare
  Future<ApproveFareResult> approveFare(int requestId) async {
    try {
      final response =
          await _backendHelper.postTransportApproveFare(requestId);
      final request = TransportRequestModel.fromJson(response);
      return ApproveFareResult.successful(request);
    } on BackendException catch (e) {
      return ApproveFareResult.failed(e.message);
    } catch (e) {
      return ApproveFareResult.failed('Failed to approve fare: $e');
    }
  }

  /// Confirm delivery and rate provider
  Future<ConfirmDeliveryResult> confirmDelivery(
    int requestId, {
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _backendHelper.postTransportConfirmDelivery(
        requestId,
        rating: rating,
        review: review,
      );
      final request = TransportRequestModel.fromJson(response);
      return ConfirmDeliveryResult.successful(request);
    } on BackendException catch (e) {
      return ConfirmDeliveryResult.failed(e.message);
    } catch (e) {
      return ConfirmDeliveryResult.failed('Failed to confirm delivery: $e');
    }
  }

  /// Filter requests by status
  List<TransportRequestModel> filterByStatus(
    List<TransportRequestModel> requests,
    TransportRequestStatus status,
  ) {
    return requests.where((r) => r.statusEnum == status).toList();
  }

  /// Get active requests (pending, accepted, in progress, in transit)
  List<TransportRequestModel> getActiveRequests(
    List<TransportRequestModel> requests,
  ) {
    final activeStatuses = {
      TransportRequestStatus.pending,
      TransportRequestStatus.accepted,
      TransportRequestStatus.inProgress,
      TransportRequestStatus.inTransit,
    };
    return requests.where((r) => activeStatuses.contains(r.statusEnum)).toList();
  }

  /// Get completed requests
  List<TransportRequestModel> getCompletedRequests(
    List<TransportRequestModel> requests,
  ) {
    return filterByStatus(requests, TransportRequestStatus.completed);
  }

  /// Sort requests by creation date
  List<TransportRequestModel> sortByCreatedAt(
    List<TransportRequestModel> requests, {
    bool ascending = false,
  }) {
    final sorted = List<TransportRequestModel>.from(requests);
    sorted.sort((a, b) {
      return ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  /// Sort requests by pickup date
  List<TransportRequestModel> sortByPickupDate(
    List<TransportRequestModel> requests, {
    bool ascending = true,
  }) {
    final sorted = List<TransportRequestModel>.from(requests);
    sorted.sort((a, b) {
      return ascending
          ? a.pickupDate.compareTo(b.pickupDate)
          : b.pickupDate.compareTo(a.pickupDate);
    });
    return sorted;
  }
}
