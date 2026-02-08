import 'package:flutter_app/core/base/base_controller.dart';
import 'package:flutter_app/features/vet/models/vet_profile_model.dart';
import 'package:flutter_app/features/vet/models/vet_availability_slot_model.dart';
import 'package:flutter_app/features/vet/models/vet_pricing_model.dart';
import 'package:flutter_app/features/vet/services/vet_profile_service.dart';

/// Controller for vet profile, availability, and pricing management
class VetProfileController extends BaseController {
  final VetProfileService _service;

  VetProfileModel? _profile;
  List<VetAvailabilitySlotModel> _availabilitySlots = [];
  VetPricingModel? _pricing;

  VetProfileController({VetProfileService? service})
      : _service = service ?? VetProfileService();

  VetProfileModel? get profile => _profile;
  List<VetAvailabilitySlotModel> get availabilitySlots => _availabilitySlots;
  VetPricingModel? get pricing => _pricing;

  // ─── Profile ───

  /// Load vet profile
  Future<VetProfileResult> loadProfile() async {
    setLoading(true);
    clearError();

    try {
      final result = await _service.getVetProfile();

      if (result.success && result.profile != null) {
        _profile = result.profile;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to load profile.');
      setLoading(false);
      return VetProfileResult.error('Failed to load profile.');
    }
  }

  /// Update vet profile with partial data
  Future<VetProfileResult> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    clearError();

    try {
      final result = await _service.updateVetProfile(updates);

      if (result.success && result.profile != null) {
        _profile = result.profile;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      return result;
    } catch (e) {
      setError('Failed to update profile.');
      return VetProfileResult.error('Failed to update profile.');
    }
  }

  /// Toggle availability status
  Future<VetProfileResult> toggleAvailability(bool available) async {
    // Optimistic update
    if (_profile != null) {
      _profile = _profile!.copyWith(available: available);
      notifyListeners();
    }

    final result = await _service.updateVetProfile({
      'available': available,
    });

    if (!result.success) {
      // Revert on failure
      if (_profile != null) {
        _profile = _profile!.copyWith(available: !available);
        notifyListeners();
      }
    } else if (result.profile != null) {
      _profile = result.profile;
      notifyListeners();
    }

    return result;
  }

  // ─── Availability ───

  /// Load availability slots
  Future<VetProfileResult> loadAvailability() async {
    setLoading(true);
    clearError();

    try {
      final result = await _service.getAvailability();

      if (result.success && result.availabilitySlots != null) {
        _availabilitySlots = result.availabilitySlots!;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to load availability.');
      setLoading(false);
      return VetProfileResult.error('Failed to load availability.');
    }
  }

  /// Get slots for a specific day of the week
  List<VetAvailabilitySlotModel> getSlotsForDay(int dayOfWeek) {
    return _availabilitySlots
        .where((slot) => slot.dayOfWeek == dayOfWeek)
        .toList();
  }

  /// Add a new availability slot
  Future<VetProfileResult> addSlot(VetAvailabilitySlotModel slot) async {
    clearError();

    try {
      final result = await _service.addAvailabilitySlot(slot);

      if (result.success && result.slot != null) {
        _availabilitySlots.add(result.slot!);
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      return result;
    } catch (e) {
      setError('Failed to add slot.');
      return VetProfileResult.error('Failed to add slot.');
    }
  }

  /// Update an existing availability slot
  Future<VetProfileResult> updateSlot(
    int slotId,
    VetAvailabilitySlotModel slot,
  ) async {
    clearError();

    try {
      final result = await _service.updateAvailabilitySlot(slotId, slot);

      if (result.success && result.slot != null) {
        final index = _availabilitySlots
            .indexWhere((s) => s.availabilityId == slotId);
        if (index != -1) {
          _availabilitySlots[index] = result.slot!;
          notifyListeners();
        }
      } else if (result.message != null) {
        setError(result.message);
      }

      return result;
    } catch (e) {
      setError('Failed to update slot.');
      return VetProfileResult.error('Failed to update slot.');
    }
  }

  /// Delete an availability slot
  Future<VetProfileResult> deleteSlot(int slotId) async {
    clearError();

    try {
      final result = await _service.deleteAvailabilitySlot(slotId);

      if (result.success) {
        _availabilitySlots.removeWhere((s) => s.availabilityId == slotId);
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      return result;
    } catch (e) {
      setError('Failed to delete slot.');
      return VetProfileResult.error('Failed to delete slot.');
    }
  }

  // ─── Pricing ───

  /// Load pricing
  Future<VetProfileResult> loadPricing() async {
    setLoading(true);
    clearError();

    try {
      final result = await _service.getPricing();

      if (result.success && result.pricing != null) {
        _pricing = result.pricing;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      setLoading(false);
      return result;
    } catch (e) {
      setError('Failed to load pricing.');
      setLoading(false);
      return VetProfileResult.error('Failed to load pricing.');
    }
  }

  /// Save pricing
  Future<VetProfileResult> savePricing(VetPricingModel pricing) async {
    clearError();

    try {
      final result = await _service.updatePricing(pricing);

      if (result.success && result.pricing != null) {
        _pricing = result.pricing;
        notifyListeners();
      } else if (result.message != null) {
        setError(result.message);
      }

      return result;
    } catch (e) {
      setError('Failed to save pricing.');
      return VetProfileResult.error('Failed to save pricing.');
    }
  }
}
