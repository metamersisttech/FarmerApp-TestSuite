/// Trip Completion Controller
///
/// Manages completed trip display (read-only for provider).
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/trip_progress_service.dart';

class TripCompletionController extends BaseController {
  final TripProgressService _tripService;

  TransportRequestModel? _request;

  TransportRequestModel? get request => _request;

  /// Check if has request
  bool get hasRequest => _request != null;

  /// Get formatted final fare
  String? get formattedFinalFare => _request?.formattedFinalFare;

  /// Get formatted proposed fare (if final not set)
  String? get formattedFare =>
      _request?.formattedFinalFare ?? _request?.formattedProposedFare;

  /// Get rating from requestor
  double? get rating => _request?.providerRating;

  /// Get review from requestor
  String? get review => _request?.providerReview;

  /// Check if has rating
  bool get hasRating => _request?.providerRating != null;

  /// Check if has review
  bool get hasReview =>
      _request?.providerReview != null && _request!.providerReview!.isNotEmpty;

  /// Get review comment (alias for review)
  String? get reviewComment => review;

  /// Get platform fee (default 0 for now)
  double get platformFee => 0;

  /// Get formatted platform fee
  String get formattedPlatformFee => '\u20B9${platformFee.toStringAsFixed(0)}';

  /// Get net earnings
  double get netEarnings {
    final fare = _request?.finalFare ?? _request?.proposedFare ?? 0;
    return fare - platformFee;
  }

  /// Get formatted net earnings
  String get formattedNetEarnings => '\u20B9${netEarnings.toStringAsFixed(0)}';

  /// Get trip duration
  Duration? get tripDuration {
    if (_request?.startedAt == null || _request?.completedAt == null) {
      return null;
    }
    return _request!.completedAt!.difference(_request!.startedAt!);
  }

  /// Get formatted trip duration
  String? get formattedDuration {
    final duration = tripDuration;
    if (duration == null) return null;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  TripCompletionController({
    TripProgressService? tripService,
  }) : _tripService = tripService ?? TripProgressService();

  /// Initialize with request
  void initializeWithRequest(TransportRequestModel request) {
    _request = request;
    notifyListeners();
  }

  /// Load trip details (alias for initializeWithRequestId)
  Future<void> loadTripDetails(int requestId) => initializeWithRequestId(requestId);

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
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load trip details');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load trip details: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Refresh trip details
  Future<void> refreshTripDetails() async {
    if (isDisposed || _request == null) return;

    try {
      final result = await _tripService.getRequestStatus(_request!.requestId);

      if (isDisposed) return;

      if (result.success) {
        _request = result.request;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail refresh
    }
  }

  /// Reset state
  void reset() {
    _request = null;
    clearError();
    notifyListeners();
  }
}
