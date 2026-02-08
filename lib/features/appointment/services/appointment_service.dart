import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/models/appointment_listing_item.dart';

/// Result of appointment operations
class AppointmentResult {
  final bool success;
  final String? message;
  final AppointmentModel? appointment;
  final List<AppointmentModel>? appointments;
  final List<AppointmentListingItem>? userListings;
  final int? totalCount;

  const AppointmentResult({
    required this.success,
    this.message,
    this.appointment,
    this.appointments,
    this.userListings,
    this.totalCount,
  });

  factory AppointmentResult.success({
    AppointmentModel? appointment,
    List<AppointmentModel>? appointments,
    List<AppointmentListingItem>? userListings,
    int? totalCount,
    String? message,
  }) {
    return AppointmentResult(
      success: true,
      message: message,
      appointment: appointment,
      appointments: appointments,
      userListings: userListings,
      totalCount: totalCount,
    );
  }

  factory AppointmentResult.error(String message) {
    return AppointmentResult(success: false, message: message);
  }
}

/// Service for appointment CRUD operations
class AppointmentService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  AppointmentService({
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// Initialize API client with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _commonHelper.getAccessToken();
    if (accessToken != null) {
      APIClient().setAuthorization(accessToken);
    }
  }

  /// Create appointment
  /// POST /api/appointments/
  Future<AppointmentResult> createAppointment({
    required int vetId,
    int? listingId,
    required String mode,
    String? notes,
  }) async {
    try {
      await _initializeAuth();

      final data = <String, dynamic>{
        'vet': vetId,
        'mode': mode,
      };
      if (listingId != null) data['listing'] = listingId;
      if (notes != null && notes.isNotEmpty) data['notes'] = notes;

      final json = await _backendHelper.postCreateAppointment(data);
      final appointment = AppointmentModel.fromJson(json);
      return AppointmentResult.success(appointment: appointment);
    } on BackendException catch (e) {
      return AppointmentResult.error(e.message);
    } catch (e) {
      debugPrint('Error creating appointment: $e');
      return AppointmentResult.error('Failed to create appointment.');
    }
  }

  /// Get user's appointments (with optional status filter)
  /// GET /api/appointments/?status=...
  Future<AppointmentResult> getAppointments({String? status}) async {
    try {
      await _initializeAuth();

      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }

      final json = await _backendHelper.getAppointments(params: params);

      // Handle paginated response
      final results = json['results'] as List<dynamic>? ?? [];

      final appointments = results
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return AppointmentResult.success(
        appointments: appointments,
        totalCount: json['count'] as int? ?? appointments.length,
      );
    } on BackendException catch (e) {
      return AppointmentResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting appointments: $e');
      return AppointmentResult.error('Failed to load appointments.');
    }
  }

  /// Get appointment by ID
  /// GET /api/appointments/{id}/
  Future<AppointmentResult> getAppointmentById(int id) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getAppointmentById(id);
      final appointment = AppointmentModel.fromJson(json);
      return AppointmentResult.success(appointment: appointment);
    } on BackendException catch (e) {
      return AppointmentResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting appointment: $e');
      return AppointmentResult.error('Failed to load appointment details.');
    }
  }

  /// Cancel appointment
  /// POST /api/appointments/{id}/cancel/
  Future<AppointmentResult> cancelAppointment(int id) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postCancelAppointment(id);
      final appointment = AppointmentModel.fromJson(json);
      return AppointmentResult.success(
        appointment: appointment,
        message: json['message'] as String? ?? 'Appointment cancelled.',
      );
    } on BackendException catch (e) {
      return AppointmentResult.error(e.message);
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      return AppointmentResult.error('Failed to cancel appointment.');
    }
  }

  /// Get user's listings for animal selection dropdown
  /// GET /api/listings/my/
  Future<AppointmentResult> getUserListings() async {
    try {
      await _initializeAuth();
      final data = await _backendHelper.getMyListings();

      List<dynamic> results;
      if (data is List) {
        results = data;
      } else if (data is Map) {
        results = data['results'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ??
            [];
      } else {
        results = [];
      }

      final listings = results
          .map((e) =>
              AppointmentListingItem.fromJson(e as Map<String, dynamic>))
          .toList();

      return AppointmentResult.success(userListings: listings);
    } on BackendException catch (e) {
      return AppointmentResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting user listings: $e');
      return AppointmentResult.error('Failed to load your listings.');
    }
  }
}
