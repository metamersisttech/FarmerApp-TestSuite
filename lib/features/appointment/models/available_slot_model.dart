/// A single time slot in a vet's day schedule.
///
/// Returned by GET /api/appointments/vet/{vetId}/available-slots/?date=...
class AvailableSlot {
  final String startTime;
  final String endTime;
  final bool available;
  final String? reason;

  const AvailableSlot({
    required this.startTime,
    required this.endTime,
    required this.available,
    this.reason,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      available: json['available'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }

  /// Format start time for display (e.g. "9:00 AM")
  String get displayStartTime => _formatTime(startTime);

  /// Format end time for display
  String get displayEndTime => _formatTime(endTime);

  /// Format time range for display
  String get displayRange => '$displayStartTime - $displayEndTime';

  static String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }
}
