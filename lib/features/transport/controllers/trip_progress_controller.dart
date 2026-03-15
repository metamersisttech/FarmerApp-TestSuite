/// Trip Progress Controller
///
/// Manages trip lifecycle: fare, pickup, status polling.
library;

import 'dart:async';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/trip_progress_service.dart';

class TripProgressController extends BaseController {
  final TripProgressService _tripService;

  TransportRequestModel? _request;
  bool _isProposingFare = false;
  bool _isConfirmingPickup = false;
  bool _isCancelling = false;
  double? _proposedFare;

  Timer? _statusPollTimer;
  static const Duration _pollInterval = Duration(seconds: 30);

  TransportRequestModel? get request => _request;
  bool get isProposingFare => _isProposingFare;
  bool get isConfirmingPickup => _isConfirmingPickup;
  bool get isCancelling => _isCancelling;
  double? get proposedFare => _proposedFare;

  /// Check if has request
  bool get hasRequest => _request != null;

  /// Get current status
  TransportRequestStatus? get status => _request?.statusEnum;

  /// Check if can propose fare
  bool get canProposeFare =>
      status == TransportRequestStatus.accepted && _request?.proposedFare == null;

  /// Check if waiting for fare approval
  bool get isWaitingForFareApproval =>
      status == TransportRequestStatus.accepted &&
      _request?.proposedFare != null &&
      !(_request?.isFareAgreed ?? false);

  /// Check if can confirm pickup
  bool get canConfirmPickup =>
      status == TransportRequestStatus.inProgress ||
      (status == TransportRequestStatus.accepted && (_request?.isFareAgreed ?? false));

  /// Check if trip is in transit
  bool get isInTransit => status == TransportRequestStatus.inTransit;

  /// Check if trip is completed
  bool get isCompleted => status == TransportRequestStatus.completed;

  /// Check if can cancel
  bool get canCancel => _request?.canCancel ?? false;

  /// Get suggested fare
  double get suggestedFare {
    if (_request == null) return 0;
    return _tripService.getSuggestedFare(
      _request!.estimatedFareMin,
      _request!.estimatedFareMax,
    );
  }

  TripProgressController({
    TripProgressService? tripService,
  }) : _tripService = tripService ?? TripProgressService();

  /// Initialize with request ID
  Future<void> initializeWithRequestId(int requestId) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _tripService.getRequestStatus(requestId);

      if (isDisposed) return;

      if (result.success) {
        _request = result.request;
        _proposedFare = result.request?.proposedFare;
        _startStatusPolling();
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load request');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load request: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Initialize with request object
  void initializeWithRequest(TransportRequestModel request) {
    _request = request;
    _proposedFare = request.proposedFare;
    _startStatusPolling();
    notifyListeners();
  }

  /// Start status polling
  void _startStatusPolling() {
    _stopStatusPolling();

    _statusPollTimer = Timer.periodic(
      _pollInterval,
      (_) => _pollStatus(),
    );
  }

  /// Stop status polling
  void _stopStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
  }

  /// Poll for status updates
  Future<void> _pollStatus() async {
    if (isDisposed || _request == null) return;

    // Stop polling if completed or cancelled
    if (isCompleted || status == TransportRequestStatus.cancelled) {
      _stopStatusPolling();
      return;
    }

    try {
      final result = await _tripService.getRequestStatus(_request!.requestId);

      if (isDisposed) return;

      if (result.success && result.request != null) {
        final oldStatus = status;
        _request = result.request;
        _proposedFare = result.request!.proposedFare;

        // Notify if status changed
        if (oldStatus != status) {
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail polling
    }
  }

  /// Propose fare
  Future<bool> proposeFare(double fare) async {
    if (isDisposed || _request == null) return false;

    // Validate fare
    if (!_tripService.validateFare(
      fare,
      _request!.estimatedFareMin,
      _request!.estimatedFareMax,
    )) {
      setError('Fare should be within the suggested range');
      return false;
    }

    _isProposingFare = true;
    clearError();
    notifyListeners();

    try {
      final result = await _tripService.proposeFare(_request!.requestId, fare);

      if (isDisposed) return false;

      _isProposingFare = false;

      if (result.success) {
        _request = result.request;
        _proposedFare = fare;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to propose fare');
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        _isProposingFare = false;
        setError('Failed to propose fare: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Confirm pickup
  Future<bool> confirmPickup() async {
    if (isDisposed || _request == null) return false;

    _isConfirmingPickup = true;
    clearError();
    notifyListeners();

    try {
      final result = await _tripService.confirmPickup(_request!.requestId);

      if (isDisposed) return false;

      _isConfirmingPickup = false;

      if (result.success) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to confirm pickup');
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        _isConfirmingPickup = false;
        setError('Failed to confirm pickup: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Cancel job
  Future<bool> cancelJob(String reason) async {
    if (isDisposed || _request == null) return false;

    _isCancelling = true;
    clearError();
    notifyListeners();

    try {
      final result = await _tripService.cancelJob(_request!.requestId, reason);

      if (isDisposed) return false;

      _isCancelling = false;
      _stopStatusPolling();

      if (result.success) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to cancel job');
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        _isCancelling = false;
        setError('Failed to cancel job: $e');
        notifyListeners();
      }
      return false;
    }
  }

  /// Refresh request status
  Future<void> refreshStatus() async {
    if (isDisposed || _request == null) return;

    try {
      final result = await _tripService.getRequestStatus(_request!.requestId);

      if (isDisposed) return;

      if (result.success) {
        _request = result.request;
        _proposedFare = result.request?.proposedFare;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail refresh
    }
  }

  /// Reset state
  void reset() {
    _stopStatusPolling();
    _request = null;
    _isProposingFare = false;
    _isConfirmingPickup = false;
    _isCancelling = false;
    _proposedFare = null;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopStatusPolling();
    super.dispose();
  }
}
