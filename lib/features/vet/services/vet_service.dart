import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';

/// Result of vet browse/search operations
class VetServiceResult {
  final bool success;
  final String? message;
  final List<VetModel>? vets;
  final VetModel? vet;
  final List<VetAvailabilitySlotModel>? availability;
  final int? totalCount;
  final String? nextPageUrl;

  const VetServiceResult({
    required this.success,
    this.message,
    this.vets,
    this.vet,
    this.availability,
    this.totalCount,
    this.nextPageUrl,
  });

  factory VetServiceResult.success({
    List<VetModel>? vets,
    VetModel? vet,
    List<VetAvailabilitySlotModel>? availability,
    int? totalCount,
    String? nextPageUrl,
    String? message,
  }) {
    return VetServiceResult(
      success: true,
      message: message,
      vets: vets,
      vet: vet,
      availability: availability,
      totalCount: totalCount,
      nextPageUrl: nextPageUrl,
    );
  }

  factory VetServiceResult.error(String message) {
    return VetServiceResult(success: false, message: message);
  }
}

/// Service for public vet browsing operations
class VetService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  VetService({
    BackendHelper? backendHelper,
    CommonHelper? commonHelper,
  })  : _backendHelper = backendHelper ?? BackendHelper(),
        _commonHelper = commonHelper ?? CommonHelper();

  /// List of available breeds for filtering
  static const List<String> breeds = [
    'All',
    'Cow',
    'Buffalo',
    'Goat',
    'Sheep',
    'Horse',
    'Poultry',
  ];

  /// Initialize API client with stored token
  Future<void> _initializeAuth() async {
    final accessToken = await _commonHelper.getAccessToken();
    if (accessToken != null) {
      APIClient().setAuthorization(accessToken);
    }
  }

  /// Get paginated vet list
  /// GET /api/vets/
  Future<VetServiceResult> getVets({
    int page = 1,
    bool? available,
    String? specialization,
  }) async {
    try {
      await _initializeAuth();

      final params = <String, dynamic>{'page': page};
      if (available != null) params['available'] = available;
      if (specialization != null && specialization != 'All') {
        params['specialization'] = specialization;
      }

      final data = await _backendHelper.getVets(params: params);

      // Handle both plain List and paginated Map responses
      List<dynamic> results;
      int? totalCount;
      String? nextPageUrl;

      if (data is List) {
        results = data;
      } else if (data is Map<String, dynamic>) {
        results = data['results'] as List<dynamic>? ?? [];
        totalCount = data['count'] as int?;
        nextPageUrl = data['next'] as String?;
      } else {
        results = [];
      }

      final vets = results
          .map((e) => VetModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return VetServiceResult.success(
        vets: vets,
        totalCount: totalCount ?? vets.length,
        nextPageUrl: nextPageUrl,
      );
    } on BackendException catch (e) {
      return VetServiceResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting vets: $e');
      return VetServiceResult.error('Failed to load vets.');
    }
  }

  /// Get vet by ID
  /// GET /api/vets/{id}/
  Future<VetServiceResult> getVetById(int id) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getVetById(id);
      final vet = VetModel.fromJson(json);
      return VetServiceResult.success(vet: vet);
    } on BackendException catch (e) {
      return VetServiceResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting vet by ID: $e');
      return VetServiceResult.error('Failed to load vet details.');
    }
  }

  /// Get vet public availability
  /// GET /api/vets/{id}/availability/
  Future<VetServiceResult> getVetAvailability(int vetId) async {
    try {
      await _initializeAuth();
      final jsonList = await _backendHelper.getVetPublicAvailability(vetId);
      final slots = jsonList
          .map((e) =>
              VetAvailabilitySlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return VetServiceResult.success(availability: slots);
    } on BackendException catch (e) {
      return VetServiceResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting vet availability: $e');
      return VetServiceResult.error('Failed to load availability.');
    }
  }
}
