/// Nearby Requests Controller
///
/// Manages nearby transport requests list and filtering.
library;

import 'dart:async';
import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/transport_request_service.dart';

enum RequestSortBy {
  distance,
  pickupDate,
  fare,
}

enum DistanceFilter {
  all(null, 'All'),
  within10km(10.0, 'Within 10 km'),
  within25km(25.0, 'Within 25 km'),
  within50km(50.0, 'Within 50 km');

  final double? maxDistance;
  final String label;
  const DistanceFilter(this.maxDistance, this.label);
}

class NearbyRequestsController extends BaseController {
  final TransportRequestService _requestService;

  List<TransportRequestModel> _allRequests = [];
  List<TransportRequestModel> _filteredRequests = [];
  DistanceFilter _distanceFilter = DistanceFilter.all;
  RequestSortBy _sortBy = RequestSortBy.distance;
  bool _sortAscending = true;

  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 60);

  List<TransportRequestModel> get requests => _filteredRequests;
  List<TransportRequestModel> get allRequests => _allRequests;
  DistanceFilter get distanceFilter => _distanceFilter;
  RequestSortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  /// Check if has requests
  bool get hasRequests => _filteredRequests.isNotEmpty;

  /// Get request count
  int get requestCount => _filteredRequests.length;

  NearbyRequestsController({
    TransportRequestService? requestService,
  }) : _requestService = requestService ?? TransportRequestService();

  /// Load nearby requests
  Future<void> loadRequests() async {
    if (isDisposed) return;

    setLoading(true);
    clearError();

    try {
      final result = await _requestService.getNearbyRequests();

      if (isDisposed) return;

      if (result.success) {
        _allRequests = result.requests ?? [];
        _applyFiltersAndSort();
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
    _stopAutoRefresh(); // Clear any existing timer

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

  /// Refresh requests (without loading indicator)
  Future<void> refreshRequests() async {
    if (isDisposed) return;

    try {
      final result = await _requestService.getNearbyRequests();

      if (isDisposed) return;

      if (result.success) {
        _allRequests = result.requests ?? [];
        _applyFiltersAndSort();
        notifyListeners();
      }
      // Don't show error on refresh - just keep old data
    } catch (e) {
      // Silently fail on refresh
    }
  }

  /// Set distance filter
  void setDistanceFilter(DistanceFilter filter) {
    if (_distanceFilter == filter) return;

    _distanceFilter = filter;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set sort option
  void setSortBy(RequestSortBy sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Toggle sort direction
  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Apply filters and sort to requests
  void _applyFiltersAndSort() {
    // Start with all requests
    var filtered = List<TransportRequestModel>.from(_allRequests);

    // Apply distance filter
    if (_distanceFilter.maxDistance != null) {
      filtered = _requestService.filterByDistance(
        filtered,
        _distanceFilter.maxDistance!,
      );
    }

    // Apply sort
    switch (_sortBy) {
      case RequestSortBy.distance:
        filtered = _requestService.sortByDistance(
          filtered,
          ascending: _sortAscending,
        );
        break;
      case RequestSortBy.pickupDate:
        filtered = _requestService.sortByPickupDate(
          filtered,
          ascending: _sortAscending,
        );
        break;
      case RequestSortBy.fare:
        filtered = _requestService.sortByFare(
          filtered,
          ascending: _sortAscending,
        );
        break;
    }

    _filteredRequests = filtered;
  }

  /// Remove a request from the list (e.g., after accepting)
  void removeRequest(int requestId) {
    _allRequests.removeWhere((r) => r.requestId == requestId);
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Reset filters
  void resetFilters() {
    _distanceFilter = DistanceFilter.all;
    _sortBy = RequestSortBy.distance;
    _sortAscending = true;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _stopAutoRefresh();
    _allRequests = [];
    _filteredRequests = [];
    _distanceFilter = DistanceFilter.all;
    _sortBy = RequestSortBy.distance;
    _sortAscending = true;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}
