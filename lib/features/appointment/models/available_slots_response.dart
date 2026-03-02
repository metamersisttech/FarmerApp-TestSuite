import 'package:flutter_app/features/appointment/models/available_slot_model.dart';

/// Full response from the available-slots endpoint.
///
/// GET /api/appointments/vet/{vetId}/available-slots/?date=YYYY-MM-DD
class AvailableSlotsResponse {
  final int vetId;
  final String date;
  final int dayOfWeek;
  final String dayName;
  final List<AvailableSlot> slots;

  const AvailableSlotsResponse({
    required this.vetId,
    required this.date,
    required this.dayOfWeek,
    required this.dayName,
    required this.slots,
  });

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    final slotsJson = json['slots'] as List<dynamic>? ?? [];
    return AvailableSlotsResponse(
      vetId: json['vet_id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      dayName: json['day_name'] as String? ?? '',
      slots: slotsJson
          .map((e) => AvailableSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Whether any slots are available
  bool get hasAvailableSlots => slots.any((s) => s.available);

  /// Only available slots
  List<AvailableSlot> get availableSlots =>
      slots.where((s) => s.available).toList();
}
