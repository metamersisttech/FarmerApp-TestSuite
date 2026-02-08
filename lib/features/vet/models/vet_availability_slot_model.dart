import 'package:flutter/material.dart';

/// Vet availability slot model
///
/// Maps items from GET /api/vets/me/availability/
class VetAvailabilitySlotModel {
  final int? availabilityId;
  final int dayOfWeek; // 0=Monday, 6=Sunday
  final String dayName;
  final String startTime; // "09:00:00"
  final String endTime; // "17:00:00"
  final bool isActive;
  final int? slotDurationMinutes;

  const VetAvailabilitySlotModel({
    this.availabilityId,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    this.slotDurationMinutes,
  });

  static const List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Parse "HH:mm:ss" or "HH:mm" to TimeOfDay
  TimeOfDay get startTimeOfDay => parseTime(startTime);
  TimeOfDay get endTimeOfDay => parseTime(endTime);

  /// Format time range for display (e.g., "09:00 AM - 05:00 PM")
  String get formattedTimeRange {
    return '${formatTimeOfDay(startTimeOfDay)} - ${formatTimeOfDay(endTimeOfDay)}';
  }

  static TimeOfDay parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Convert TimeOfDay to API string format "HH:mm"
  static String timeOfDayToApiString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  factory VetAvailabilitySlotModel.fromJson(Map<String, dynamic> json) {
    return VetAvailabilitySlotModel(
      availabilityId: json['availability_id'] as int?,
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      dayName: json['day_name'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '09:00:00',
      endTime: json['end_time'] as String? ?? '17:00:00',
      isActive: json['is_active'] as bool? ?? true,
      slotDurationMinutes: json['slot_duration_minutes'] as int?,
    );
  }

  /// toJson for POST/PATCH (excludes id and dayName)
  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
