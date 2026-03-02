import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';
import 'package:flutter_app/features/vet/models/vet_pricing_model.dart';

/// Result of vet profile operations
class VetProfileResult {
  final bool success;
  final String? message;
  final VetProfileModel? profile;
  final List<VetAvailabilitySlotModel>? availabilitySlots;
  final VetAvailabilitySlotModel? slot;
  final VetPricingModel? pricing;

  const VetProfileResult({
    required this.success,
    this.message,
    this.profile,
    this.availabilitySlots,
    this.slot,
    this.pricing,
  });

  factory VetProfileResult.success({
    VetProfileModel? profile,
    List<VetAvailabilitySlotModel>? availabilitySlots,
    VetAvailabilitySlotModel? slot,
    VetPricingModel? pricing,
    String? message,
  }) {
    return VetProfileResult(
      success: true,
      message: message,
      profile: profile,
      availabilitySlots: availabilitySlots,
      slot: slot,
      pricing: pricing,
    );
  }

  factory VetProfileResult.error(String message) {
    return VetProfileResult(success: false, message: message);
  }
}

/// Service for vet profile, availability, and pricing operations
class VetProfileService {
  final BackendHelper _backendHelper;
  final CommonHelper _commonHelper;

  VetProfileService({
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

  // ─── Profile ───

  /// Get vet profile
  /// GET /api/vets/me/
  Future<VetProfileResult> getVetProfile() async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getVetProfile();
      final profile = VetProfileModel.fromJson(json);
      return VetProfileResult.success(profile: profile);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting vet profile: $e');
      return VetProfileResult.error('Failed to load vet profile.');
    }
  }

  /// Update vet profile
  /// PATCH /api/vets/me/
  Future<VetProfileResult> updateVetProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.patchVetProfile(updates);
      final profile = VetProfileModel.fromJson(json);
      return VetProfileResult.success(profile: profile);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error updating vet profile: $e');
      return VetProfileResult.error('Failed to update profile.');
    }
  }

  // ─── Availability ───

  /// Get availability slots
  /// GET /api/vets/me/availability/
  Future<VetProfileResult> getAvailability() async {
    try {
      await _initializeAuth();
      final jsonList = await _backendHelper.getVetAvailability();
      final slots = jsonList
          .map((e) =>
              VetAvailabilitySlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return VetProfileResult.success(availabilitySlots: slots);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting availability: $e');
      return VetProfileResult.error('Failed to load availability.');
    }
  }

  /// Add a new availability slot
  /// POST /api/vets/me/availability/
  Future<VetProfileResult> addAvailabilitySlot(
    VetAvailabilitySlotModel slot,
  ) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.postVetAvailability(slot.toJson());
      final newSlot = VetAvailabilitySlotModel.fromJson(json);
      return VetProfileResult.success(slot: newSlot);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error adding availability slot: $e');
      return VetProfileResult.error('Failed to add availability slot.');
    }
  }

  /// Update an existing availability slot
  /// PATCH /api/vets/me/availability/{id}/
  Future<VetProfileResult> updateAvailabilitySlot(
    int slotId,
    VetAvailabilitySlotModel slot,
  ) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.patchVetAvailability(
        slotId,
        slot.toJson(),
      );
      final updatedSlot = VetAvailabilitySlotModel.fromJson(json);
      return VetProfileResult.success(slot: updatedSlot);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error updating availability slot: $e');
      return VetProfileResult.error('Failed to update availability slot.');
    }
  }

  /// Delete an availability slot
  /// DELETE /api/vets/me/availability/{id}/
  Future<VetProfileResult> deleteAvailabilitySlot(int slotId) async {
    try {
      await _initializeAuth();
      await _backendHelper.deleteVetAvailability(slotId);
      return VetProfileResult.success(message: 'Slot deleted successfully.');
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error deleting availability slot: $e');
      return VetProfileResult.error('Failed to delete availability slot.');
    }
  }

  // ─── Pricing ───

  /// Get vet pricing
  /// GET /api/vets/me/pricing/
  Future<VetProfileResult> getPricing() async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.getVetPricing();
      final pricing = VetPricingModel.fromJson(json);
      return VetProfileResult.success(pricing: pricing);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error getting pricing: $e');
      return VetProfileResult.error('Failed to load pricing.');
    }
  }

  /// Update vet pricing
  /// PATCH /api/vets/me/pricing/
  Future<VetProfileResult> updatePricing(VetPricingModel pricing) async {
    try {
      await _initializeAuth();
      final json = await _backendHelper.patchVetPricing(pricing.toJson());
      final updated = VetPricingModel.fromJson(json);
      return VetProfileResult.success(pricing: updated);
    } on BackendException catch (e) {
      return VetProfileResult.error(e.message);
    } catch (e) {
      debugPrint('Error updating pricing: $e');
      return VetProfileResult.error('Failed to update pricing.');
    }
  }
}
