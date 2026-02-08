import 'package:flutter/material.dart';

/// Vet info embedded in an appointment response
class AppointmentVetInfo {
  final int vetId;
  final String name;
  final String clinicName;
  final String? phone;

  const AppointmentVetInfo({
    required this.vetId,
    required this.name,
    required this.clinicName,
    this.phone,
  });

  factory AppointmentVetInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentVetInfo(
      vetId: json['vet_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      clinicName: json['clinic_name'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }
}

/// Listing info embedded in an appointment response
class AppointmentListingInfo {
  final int listingId;
  final String title;

  const AppointmentListingInfo({
    required this.listingId,
    required this.title,
  });

  factory AppointmentListingInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentListingInfo(
      listingId: json['listing_id'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}

/// Appointment model mapping the API response
///
/// Maps GET /api/appointments/ list items and
/// GET /api/appointments/{id}/ detail response.
class AppointmentModel {
  final int appointmentId;
  final AppointmentVetInfo vet;
  final AppointmentListingInfo? listing;
  final String mode;
  final String status;
  final String? notes;
  final String? scheduledDate;
  final String? scheduledStartTime;
  final String? scheduledEndTime;
  final String? rejectionReason;
  final String? prescription;
  final String? completionNotes;
  final String? completedAt;
  final String? fee;
  final String createdAt;
  final String updatedAt;

  const AppointmentModel({
    required this.appointmentId,
    required this.vet,
    this.listing,
    required this.mode,
    required this.status,
    this.notes,
    this.scheduledDate,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.rejectionReason,
    this.prescription,
    this.completionNotes,
    this.completedAt,
    this.fee,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── Computed Helpers ───

  bool get isPhoneVisible =>
      status == 'CONFIRMED' || status == 'COMPLETED';

  bool get canCancel =>
      status == 'REQUESTED' || status == 'CONFIRMED';

  bool get canChat => status == 'CONFIRMED';

  String get displayStatus {
    switch (status) {
      case 'REQUESTED':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'REJECTED':
        return 'Rejected';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'REQUESTED':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'REQUESTED':
        return Icons.hourglass_top_rounded;
      case 'CONFIRMED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'COMPLETED':
        return Icons.task_alt_rounded;
      case 'CANCELLED':
        return Icons.block_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String get modeDisplay {
    switch (mode) {
      case 'in_person':
        return 'In-Person';
      case 'video':
        return 'Video Call';
      case 'phone':
        return 'Phone Call';
      case 'chat':
        return 'Chat';
      default:
        return mode;
    }
  }

  IconData get modeIcon {
    switch (mode) {
      case 'in_person':
        return Icons.person;
      case 'video':
        return Icons.videocam;
      case 'phone':
        return Icons.phone;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.medical_services;
    }
  }

  String get formattedFee {
    if (fee == null) return '';
    final parsed = double.tryParse(fee!);
    if (parsed == null) return '\u20B9$fee';
    return '\u20B9${parsed.toInt()}';
  }

  String? get formattedSchedule {
    if (scheduledDate == null) return null;
    final parts = <String>[];
    parts.add(_formatDateString(scheduledDate!));
    if (scheduledStartTime != null) {
      parts.add(_formatTimeString(scheduledStartTime!));
      if (scheduledEndTime != null) {
        parts.add('- ${_formatTimeString(scheduledEndTime!)}');
      }
    }
    return parts.join(' | ');
  }

  String get formattedCreatedAt => _formatDateString(createdAt);

  // ─── Date/Time Formatting ───

  static String _formatDateString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String _formatTimeString(String timeStr) {
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

  // ─── fromJson ───

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    AppointmentListingInfo? listingInfo;
    if (json['listing'] is Map<String, dynamic>) {
      listingInfo = AppointmentListingInfo.fromJson(
        json['listing'] as Map<String, dynamic>,
      );
    }

    return AppointmentModel(
      appointmentId: json['appointment_id'] as int? ?? 0,
      vet: AppointmentVetInfo.fromJson(
        json['vet'] as Map<String, dynamic>? ?? {},
      ),
      listing: listingInfo,
      mode: json['mode'] as String? ?? 'in_person',
      status: json['status'] as String? ?? 'REQUESTED',
      notes: json['notes'] as String?,
      scheduledDate: json['scheduled_date'] as String?,
      scheduledStartTime: json['scheduled_start_time'] as String?,
      scheduledEndTime: json['scheduled_end_time'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      prescription: json['prescription'] as String?,
      completionNotes: json['completion_notes'] as String?,
      completedAt: json['completed_at'] as String?,
      fee: json['fee']?.toString(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}
