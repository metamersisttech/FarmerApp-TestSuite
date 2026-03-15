/// Transport Dashboard Service
///
/// Handles dashboard operations: availability, location, stats.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class TransportDashboardService {
  final BackendHelper _backendHelper;

  TransportDashboardService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Toggle availability
  Future<AvailabilityResult> toggleAvailability(bool available) async {
    try {
      final response = await _backendHelper.patchTransportAvailability(available);
      final isAvailable = response['available'] as bool? ?? available;
      return AvailabilityResult.successful(isAvailable);
    } on BackendException catch (e) {
      return AvailabilityResult.failed(e.message);
    } catch (e) {
      return AvailabilityResult.failed('Failed to update availability: $e');
    }
  }

  /// Update location
  Future<LocationResult> updateLocation(double latitude, double longitude) async {
    try {
      await _backendHelper.patchTransportLocation(latitude, longitude);
      return LocationResult.successful(latitude, longitude);
    } on BackendException catch (e) {
      return LocationResult.failed(e.message);
    } catch (e) {
      return LocationResult.failed('Failed to update location: $e');
    }
  }

  /// Get active jobs
  Future<JobListResult> getMyActiveJobs() async {
    try {
      final response = await _backendHelper.getTransportMyJobs(status: 'ACCEPTED');

      List<dynamic> jobsList = [];
      if (response is List) {
        jobsList = response;
      } else if (response is Map && response['results'] != null) {
        jobsList = response['results'] as List<dynamic>;
      }

      final jobs = jobsList
          .whereType<Map<String, dynamic>>()
          .map((j) => TransportRequestModel.fromJson(j))
          .toList();

      // Count active vs completed
      final activeCount = jobs.where((j) =>
        j.status != 'COMPLETED' && j.status != 'CANCELLED'
      ).length;
      final completedCount = jobs.where((j) => j.status == 'COMPLETED').length;

      return JobListResult.successful(
        jobs,
        activeCount: activeCount,
        completedCount: completedCount,
      );
    } on BackendException catch (e) {
      return JobListResult.failed(e.message);
    } catch (e) {
      return JobListResult.failed('Failed to load active jobs: $e');
    }
  }

  /// Get all jobs with optional status filter
  Future<JobListResult> getMyJobs({String? status}) async {
    try {
      final response = await _backendHelper.getTransportMyJobs(status: status);

      List<dynamic> jobsList = [];
      if (response is List) {
        jobsList = response;
      } else if (response is Map && response['results'] != null) {
        jobsList = response['results'] as List<dynamic>;
      }

      final jobs = jobsList
          .whereType<Map<String, dynamic>>()
          .map((j) => TransportRequestModel.fromJson(j))
          .toList();

      return JobListResult.successful(jobs);
    } on BackendException catch (e) {
      return JobListResult.failed(e.message);
    } catch (e) {
      return JobListResult.failed('Failed to load jobs: $e');
    }
  }

  /// Get dashboard stats
  Future<DashboardStatsResult> getDashboardStats() async {
    try {
      final response = await _backendHelper.getTransportDashboardStats();
      return DashboardStatsResult.successful(
        activeJobsCount: response['active_jobs_count'] as int?,
        pendingRequestsCount: response['pending_requests_count'] as int?,
        completedTripsToday: response['completed_trips_today'] as int?,
        totalEarningsToday: (response['total_earnings_today'] as num?)?.toDouble(),
      );
    } on BackendException catch (e) {
      return DashboardStatsResult.failed(e.message);
    } catch (e) {
      return DashboardStatsResult.failed('Failed to load stats: $e');
    }
  }
}
