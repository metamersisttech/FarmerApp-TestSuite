/// Requester Request Detail Controller
///
/// Manages the requester's view of a transport request with actions.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/requester_transport_service.dart';

class RequesterRequestDetailController extends BaseController {
  final RequesterTransportService _transportService;

  TransportRequestModel? _request;
  bool _isCancelling = false;
  bool _isApprovingFare = false;

  TransportRequestModel? get request => _request;
  bool get isCancelling => _isCancelling;
  bool get isApprovingFare => _isApprovingFare;

  /// Check if request can be cancelled
  bool get canCancel =>
      _request != null &&
      (_request!.statusEnum == TransportRequestStatus.pending ||
          _request!.statusEnum == TransportRequestStatus.accepted);

  /// Check if fare approval is needed
  bool get needsFareApproval =>
      _request != null &&
      _request!.statusEnum == TransportRequestStatus.accepted &&
      _request!.proposedFare != null &&
      !_request!.fareApprovedByRequestor;

  /// Check if request has provider
  bool get hasProvider => _request?.transportProvider != null;

  /// Check if chat is available
  bool get canChat =>
      _request != null &&
      hasProvider &&
      (_request!.statusEnum == TransportRequestStatus.accepted ||
          _request!.statusEnum == TransportRequestStatus.inProgress ||
          _request!.statusEnum == TransportRequestStatus.inTransit);

  RequesterRequestDetailController({
    RequesterTransportService? transportService,
  }) : _transportService = transportService ?? RequesterTransportService();

  /// Load request by ID
  Future<void> loadRequest(int requestId) async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _transportService.getRequestById(requestId);

      if (isDisposed) return;

      if (result.success && result.request != null) {
        _request = result.request;
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

  /// Refresh request
  Future<void> refreshRequest() async {
    if (_request == null || isDisposed) return;

    try {
      final result = await _transportService.getRequestById(_request!.requestId);

      if (isDisposed) return;

      if (result.success && result.request != null) {
        _request = result.request;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail on refresh
    }
  }

  /// Cancel the request
  Future<bool> cancelRequest({String? reason}) async {
    if (_request == null || !canCancel || isDisposed) return false;

    _isCancelling = true;
    clearError();
    notifyListeners();

    try {
      final result = await _transportService.cancelRequest(
        _request!.requestId,
        reason: reason,
      );

      if (isDisposed) return false;

      if (result.success) {
        if (result.request != null) {
          _request = result.request;
        } else {
          // Update status locally
          _request = _request!.copyWith(
            status: TransportRequestStatus.cancelled.value,
            cancellationReason: reason,
          );
        }
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to cancel request');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to cancel request: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        _isCancelling = false;
        notifyListeners();
      }
    }
  }

  /// Approve provider's proposed fare
  Future<bool> approveFare() async {
    if (_request == null || !needsFareApproval || isDisposed) return false;

    _isApprovingFare = true;
    clearError();
    notifyListeners();

    try {
      final result = await _transportService.approveFare(_request!.requestId);

      if (isDisposed) return false;

      if (result.success && result.request != null) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to approve fare');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to approve fare: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        _isApprovingFare = false;
        notifyListeners();
      }
    }
  }

  /// Set request directly (e.g., when passed from list)
  void setRequest(TransportRequestModel request) {
    _request = request;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _request = null;
    _isCancelling = false;
    _isApprovingFare = false;
    clearError();
    notifyListeners();
  }
}
