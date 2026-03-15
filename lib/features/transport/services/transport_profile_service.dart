/// Transport Profile Service
///
/// Handles transport provider profile operations.
library;

import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/features/transport/models/transport_provider_model.dart';
import 'package:flutter_app/features/transport/models/transport_result_models.dart';

class TransportProfileService {
  final BackendHelper _backendHelper;

  TransportProfileService({BackendHelper? backendHelper})
      : _backendHelper = backendHelper ?? BackendHelper();

  /// Get current provider profile
  Future<TransportProfileResult> getMyProfile() async {
    try {
      final response = await _backendHelper.getTransportProfile();
      final profile = TransportProviderModel.fromJson(response);
      return TransportProfileResult.successful(profile);
    } on BackendException catch (e) {
      return TransportProfileResult.failed(e.message);
    } catch (e) {
      return TransportProfileResult.failed('Failed to load profile: $e');
    }
  }

  /// Update provider profile
  Future<TransportProfileResult> updateProfile({
    String? businessName,
    String? bio,
    int? serviceRadiusKm,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (businessName != null) data['business_name'] = businessName;
      if (bio != null) data['bio'] = bio;
      if (serviceRadiusKm != null) data['service_radius_km'] = serviceRadiusKm;

      final response = await _backendHelper.patchTransportProfile(data);
      final profile = TransportProviderModel.fromJson(response);
      return TransportProfileResult.successful(profile);
    } on BackendException catch (e) {
      return TransportProfileResult.failed(e.message);
    } catch (e) {
      return TransportProfileResult.failed('Failed to update profile: $e');
    }
  }
}
