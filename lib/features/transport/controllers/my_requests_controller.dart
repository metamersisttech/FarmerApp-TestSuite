/// My Requests Controller
///
/// Manages the requester's transport requests list and filtering.
library;

import 'dart:async';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/requester_transport_service.dart';

enum MyRequestsFilter {
  all('All'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const MyRequestsFilter(this.label);
}

class MyRequestsController extends BaseController {
  final RequesterTransportService _transportService;

  List<TransportRequestModel> _allRequests = [];
  List<TransportRequestModel> _filteredRequests = [];
  MyRequestsFilter _filter = MyRequestsFilter.all;

  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 60);

  List<TransportRequestModel> get requests => _filteredRequests;
  List<TransportRequestModel> get allRequests => _allRequests;
  MyRequestsFilter get filter => _filter;

  /// Check if has requests
  bool get hasRequests => _filteredRequests.isNotEmpty;

  /// Get request count
  int get requestCount => _filteredRequests.length;

  /// Get counts by status
  int get activeCount => _transportService.getActiveRequests(_allRequests).length;
  int get completedCount => _transportService.getCompletedRequests(_allRequests).length;
  int get cancelledCount =>
      _transportService.filterByStatus(_allRequests, TransportRequestStatus.cancelled).length;

  MyRequestsController({
    RequesterTransportService? transportService,
  }) : _transportService = transportService ?? RequesterTransportService();

  /// Load requests
  Future<void> loadRequests() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _transportService.getMyRequests();

      if (isDisposed) return;

      if (result.success) {
        _allRequests = _transportService.sortByCreatedAt(
          result.requests ?? [],
          ascending: false,
        );
        _applyFilter();
        notifyListeners();
      } else {
        setError(result.errorMessage ?? 'Failed to load requests');
      }
    } catch (e) {
      if (!isDisposed) {
        setError('Failed to load requests: $e');
      }
    } finally {
      if (!isDisposed) {
        setLoading(false);
      }
    }
  }

  /// Start auto-refresh
  void startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => refreshRequests(),
    );
  }

  /// Stop auto-refresh
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Refresh requests without loading indicator
  Future<void> refreshRequests() async {
    if (isDisposed) return;

    try {
      final result = await _transportService.getMyRequests();

      if (isDisposed) return;

      if (result.success) {
        _allRequests = _transportService.sortByCreatedAt(
          result.requests ?? [],
          ascending: false,
        );
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      // Silently fail on refresh
    }
  }

  /// Set filter
  void setFilter(MyRequestsFilter filter) {
    if (_filter == filter) return;

    _filter = filter;
    _applyFilter();
    notifyListeners();
  }

  /// Apply current filter
  void _applyFilter() {
    switch (_filter) {
      case MyRequestsFilter.all:
        _filteredRequests = List.from(_allRequests);
        break;
      case MyRequestsFilter.active:
        _filteredRequests = _transportService.getActiveRequests(_allRequests);
        break;
      case MyRequestsFilter.completed:
        _filteredRequests = _transportService.getCompletedRequests(_allRequests);
        break;
      case MyRequestsFilter.cancelled:
        _filteredRequests = _transportService.filterByStatus(
          _allRequests,
          TransportRequestStatus.cancelled,
        );
        break;
    }
  }

  /// Get request by ID
  TransportRequestModel? getRequestById(int requestId) {
    try {
      return _allRequests.firstWhere((r) => r.requestId == requestId);
    } catch (e) {
      return null;
    }
  }

  /// Update a request in the list
  void updateRequest(TransportRequestModel updatedRequest) {
    final index = _allRequests.indexWhere(
      (r) => r.requestId == updatedRequest.requestId,
    );
    if (index >= 0) {
      _allRequests[index] = updatedRequest;
      _applyFilter();
      notifyListeners();
    }
  }

  /// Remove a request from the list
  void removeRequest(int requestId) {
    _allRequests.removeWhere((r) => r.requestId == requestId);
    _applyFilter();
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _stopAutoRefresh();
    _allRequests = [];
    _filteredRequests = [];
    _filter = MyRequestsFilter.all;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}
