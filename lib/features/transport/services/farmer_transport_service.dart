/// Farmer Transport Service
///
/// Handles transport requests from the farmer/requestor perspective:
/// - Create a new transport request after purchasing/viewing an animal
/// - List farmer's own requests
/// - View request details and status
/// - Cancel a pending request
/// - Approve the fare proposed by a transport provider
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';

class FarmerTransportService {
  final BackendHelper _backendHelper = BackendHelper();

  /// Create a new transport request.
  ///
  /// [pickupAddress] and [destinationAddress] are human-readable.
  /// [cargoAnimals] is a list of maps: [{animal_id, count, species, breed, estimated_weight_kg}]
  Future<TransportRequestModel> createRequest({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required List<Map<String, dynamic>> cargoAnimals,
    required DateTime pickupDate,
    String? pickupTime, // "HH:MM" format
    double? estimatedFareMin,
    double? estimatedFareMax,
    String? notes,
    int? listingId,
  }) async {
    final body = <String, dynamic>{
      'source_address': pickupAddress,
      'source_latitude': pickupLat,
      'source_longitude': pickupLng,
      'destination_address': destinationAddress,
      'destination_latitude': destinationLat,
      'destination_longitude': destinationLng,
      'cargo_animals': cargoAnimals,
      'pickup_date': pickupDate.toIso8601String().split('T').first,
      if (pickupTime != null) 'pickup_time': pickupTime,
      if (estimatedFareMin != null) 'estimated_fare_min': estimatedFareMin,
      if (estimatedFareMax != null) 'estimated_fare_max': estimatedFareMax,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (listingId != null) 'listing_id': listingId,
    };

    final response = await _backendHelper.postFarmerTransportRequest(body);
    return TransportRequestModel.fromJson(response);
  }

  /// Get all transport requests created by this farmer.
  Future<List<TransportRequestModel>> getMyRequests({String? status}) async {
    final response =
        await _backendHelper.getFarmerTransportRequests(status: status);

    final results =
        (response is Map<String, dynamic> ? response['results'] : null) ??
            response;
    if (results is List) {
      return results
          .map((e) => TransportRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get details of a specific transport request.
  Future<TransportRequestModel> getRequestById(int requestId) async {
    final response =
        await _backendHelper.getFarmerTransportRequestById(requestId);
    return TransportRequestModel.fromJson(response);
  }

  /// Cancel a pending transport request.
  Future<void> cancelRequest(int requestId) async {
    await _backendHelper.postCancelFarmerTransportRequest(requestId);
  }

  /// Approve the fare proposed by the transport provider.
  Future<TransportRequestModel> approveFare(int requestId) async {
    final response =
        await _backendHelper.postApproveFarmerTransportFare(requestId);
    return TransportRequestModel.fromJson(response);
  }
}
