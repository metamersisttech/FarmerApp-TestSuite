/// Trip Progress Service
///
/// Handles trip lifecycle operations: fare, pickup, cancel.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class TripProgressService {
  final BackendHelper _backendHelper;

  TripProgressService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Propose fare for a request
  Future<FareResult> proposeFare(int requestId, double fare) async {
    try {
      final response = await _backendHelper.postTransportProposeFare(
        requestId,
        fare,
      );
      final request = TransportRequestModel.fromJson(response);
      return FareResult.successful(request);
    } on BackendException catch (e) {
      return FareResult.failed(e.message);
    } catch (e) {
      return FareResult.failed('Failed to propose fare: $e');
    }
  }

  /// Confirm pickup
  Future<PickupResult> confirmPickup(int requestId) async {
    try {
      final response = await _backendHelper.postTransportConfirmPickup(requestId);
      final request = TransportRequestModel.fromJson(response);
      return PickupResult.successful(request);
    } on BackendException catch (e) {
      if (e.statusCode == 400) {
        return PickupResult.failed('Cannot confirm pickup. Please ensure fare is agreed upon by both parties.');
      }
      return PickupResult.failed(e.message);
    } catch (e) {
      return PickupResult.failed('Failed to confirm pickup: $e');
    }
  }

  /// Cancel job
  Future<CancelResult> cancelJob(int requestId, String reason) async {
    try {
      final response = await _backendHelper.postTransportCancelJob(
        requestId,
        reason,
      );
      final request = TransportRequestModel.fromJson(response);
      return CancelResult.successful(request: request);
    } on BackendException catch (e) {
      if (e.statusCode == 400) {
        return CancelResult.failed('Cannot cancel this job. It may already be in transit.');
      }
      return CancelResult.failed(e.message);
    } catch (e) {
      return CancelResult.failed('Failed to cancel job: $e');
    }
  }

  /// Get current request status (for polling)
  Future<RequestResult> getRequestStatus(int requestId) async {
    try {
      final response = await _backendHelper.getTransportRequestById(requestId);
      final request = TransportRequestModel.fromJson(response);
      return RequestResult.successful(request);
    } on BackendException catch (e) {
      return RequestResult.failed(e.message);
    } catch (e) {
      return RequestResult.failed('Failed to get request status: $e');
    }
  }

  /// Validate fare against estimated range
  bool validateFare(double proposedFare, double minFare, double maxFare) {
    // Allow some flexibility (10% outside range)
    final lowerBound = minFare * 0.9;
    final upperBound = maxFare * 1.1;
    return proposedFare >= lowerBound && proposedFare <= upperBound;
  }

  /// Get suggested fare (midpoint of range)
  double getSuggestedFare(double minFare, double maxFare) {
    return (minFare + maxFare) / 2;
  }
}
