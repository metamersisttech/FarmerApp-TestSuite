/// Transport Request Service
///
/// Handles transport request operations for providers.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class TransportRequestService {
  final BackendHelper _backendHelper;

  TransportRequestService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get nearby transport requests
  Future<RequestListResult> getNearbyRequests({
    double? maxDistanceKm,
    int? limit,
    int? offset,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (maxDistanceKm != null) params['max_distance_km'] = maxDistanceKm;
      if (limit != null) params['limit'] = limit;
      if (offset != null) params['offset'] = offset;

      final response = await _backendHelper.getTransportNearbyRequests(
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
      return RequestListResult.failed('Failed to load nearby requests: $e');
    }
  }

  /// Get a single request by ID
  Future<RequestResult> getRequestById(int requestId) async {
    try {
      final response = await _backendHelper.getTransportRequestById(requestId);
      final request = TransportRequestModel.fromJson(response);
      return RequestResult.successful(request);
    } on BackendException catch (e) {
      return RequestResult.failed(e.message);
    } catch (e) {
      return RequestResult.failed('Failed to load request: $e');
    }
  }

  /// Accept a transport request
  Future<AcceptResult> acceptRequest(int requestId, int vehicleId) async {
    try {
      final response = await _backendHelper.postTransportRequestAccept(
        requestId,
        vehicleId,
      );
      final request = TransportRequestModel.fromJson(response);
      return AcceptResult.successful(request);
    } on BackendException catch (e) {
      // Handle specific error cases
      if (e.statusCode == 404) {
        return AcceptResult.failed('This request is no longer available. It may have been accepted by another provider.');
      }
      if (e.statusCode == 400) {
        return AcceptResult.failed(e.message);
      }
      return AcceptResult.failed(e.message);
    } catch (e) {
      return AcceptResult.failed('Failed to accept request: $e');
    }
  }

  /// Filter requests by distance
  List<TransportRequestModel> filterByDistance(
    List<TransportRequestModel> requests,
    double maxDistanceKm,
  ) {
    return requests.where((r) {
      final distance = r.distanceFromProvider;
      if (distance == null) return true; // Include if distance unknown
      return distance <= maxDistanceKm;
    }).toList();
  }

  /// Sort requests by distance
  List<TransportRequestModel> sortByDistance(
    List<TransportRequestModel> requests, {
    bool ascending = true,
  }) {
    final sorted = List<TransportRequestModel>.from(requests);
    sorted.sort((a, b) {
      final distA = a.distanceFromProvider ?? double.infinity;
      final distB = b.distanceFromProvider ?? double.infinity;
      return ascending ? distA.compareTo(distB) : distB.compareTo(distA);
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

  /// Sort requests by fare
  List<TransportRequestModel> sortByFare(
    List<TransportRequestModel> requests, {
    bool ascending = false, // Default high to low
  }) {
    final sorted = List<TransportRequestModel>.from(requests);
    sorted.sort((a, b) {
      final fareA = (a.estimatedFareMin + a.estimatedFareMax) / 2;
      final fareB = (b.estimatedFareMin + b.estimatedFareMax) / 2;
      return ascending ? fareA.compareTo(fareB) : fareB.compareTo(fareA);
    });
    return sorted;
  }
}
