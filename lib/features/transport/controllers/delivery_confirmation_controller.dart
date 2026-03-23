/// Delivery Confirmation Controller
///
/// Manages delivery confirmation and provider rating.
library;

import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/requester_transport_service.dart';

class DeliveryConfirmationController extends BaseController {
  final RequesterTransportService _transportService;

  TransportRequestModel? _request;
  int _rating = 0;
  String _review = '';
  bool _isSubmitting = false;

  TransportRequestModel? get request => _request;
  int get rating => _rating;
  String get review => _review;
  bool get isSubmitting => _isSubmitting;

  /// Check if rating is valid (1-5)
  bool get isRatingValid => _rating >= 1 && _rating <= 5;

  /// Check if can submit
  bool get canSubmit => isRatingValid && !_isSubmitting;

  DeliveryConfirmationController({
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

        // Pre-fill existing rating if any
        if (_request!.providerRating != null) {
          _rating = _request!.providerRating!.round();
        }
        if (_request!.providerReview != null) {
          _review = _request!.providerReview!;
        }

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

  /// Set rating
  void setRating(int rating) {
    if (rating < 1 || rating > 5) return;
    _rating = rating;
    notifyListeners();
  }

  /// Set review
  void setReview(String review) {
    _review = review;
    notifyListeners();
  }

  /// Submit delivery confirmation
  Future<bool> confirmDelivery() async {
    if (_request == null || !canSubmit || isDisposed) return false;

    _isSubmitting = true;
    clearError();
    notifyListeners();

    try {
      final result = await _transportService.confirmDelivery(
        _request!.requestId,
        rating: _rating,
        review: _review.isNotEmpty ? _review : null,
      );

      if (isDisposed) return false;

      if (result.success && result.request != null) {
        _request = result.request;
        notifyListeners();
        return true;
      } else {
        setError(result.errorMessage ?? 'Failed to confirm delivery');
        return false;
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to confirm delivery: $e');
      }
      return false;
    } finally {
      if (!isDisposed) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  /// Reset state
  void reset() {
    _request = null;
    _rating = 0;
    _review = '';
    _isSubmitting = false;
    clearError();
    notifyListeners();
  }
}
