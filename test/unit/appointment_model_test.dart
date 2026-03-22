// test/unit/appointment_model_test.dart
//
// Unit tests for lib/features/appointment/models/appointment_model.dart
// Run: flutter test test/unit/appointment_model_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';

Map<String, dynamic> _baseJson({String status = 'REQUESTED', String mode = 'in_person'}) {
  return {
    'appointment_id': 101,
    'vet': {
      'vet_id': 10,
      'name': 'Dr. Sharma',
      'clinic_name': 'Sharma Clinic',
      'phone': '9876543210',
    },
    'mode': mode,
    'status': status,
    'created_at': '2024-03-01T09:00:00Z',
    'updated_at': '2024-03-01T09:00:00Z',
  };
}

void main() {
  // ── fromJson ──────────────────────────────────────────────────────────────
  group('AppointmentModel.fromJson', () {
    test('parses required fields', () {
      final model = AppointmentModel.fromJson(_baseJson());
      expect(model.appointmentId, 101);
      expect(model.vet.name, 'Dr. Sharma');
      expect(model.status, 'REQUESTED');
      expect(model.mode, 'in_person');
    });

    test('parses optional fee as string', () {
      final json = _baseJson()..['fee'] = 500;
      final model = AppointmentModel.fromJson(json);
      expect(model.fee, '500');
    });

    test('parses nested listing info', () {
      final json = _baseJson()..['listing'] = {
        'listing_id': 55,
        'title': 'Gir Cow for Sale',
      };
      final model = AppointmentModel.fromJson(json);
      expect(model.listing?.listingId, 55);
      expect(model.listing?.title, 'Gir Cow for Sale');
    });

    test('parses requestor on vet-side response', () {
      final json = _baseJson()..['requestor'] = {
        'id': 20,
        'name': 'Farmer Ramesh',
        'phone': '1234567890',
      };
      final model = AppointmentModel.fromJson(json);
      expect(model.requestor, isNotNull);
      expect(model.isVetSide, isTrue);
    });

    test('uses defaults for missing optional fields', () {
      final model = AppointmentModel.fromJson({
        'appointment_id': 1,
        'vet': {},
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
      });
      expect(model.mode, 'in_person');
      expect(model.status, 'REQUESTED');
      expect(model.notes, isNull);
    });
  });

  // ── Status computed helpers ───────────────────────────────────────────────
  group('Status helpers', () {
    test('canApprove only for REQUESTED', () {
      expect(AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).canApprove, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).canApprove, isFalse);
      expect(AppointmentModel.fromJson(_baseJson(status: 'COMPLETED')).canApprove, isFalse);
    });

    test('canReject only for REQUESTED', () {
      expect(AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).canReject, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).canReject, isFalse);
    });

    test('canComplete only for CONFIRMED', () {
      expect(AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).canComplete, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).canComplete, isFalse);
      expect(AppointmentModel.fromJson(_baseJson(status: 'COMPLETED')).canComplete, isFalse);
    });

    test('canCancel for REQUESTED or CONFIRMED', () {
      expect(AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).canCancel, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).canCancel, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'COMPLETED')).canCancel, isFalse);
    });

    test('canChat only for CONFIRMED', () {
      expect(AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).canChat, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).canChat, isFalse);
    });

    test('isPhoneVisible for CONFIRMED and COMPLETED', () {
      expect(AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).isPhoneVisible, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'COMPLETED')).isPhoneVisible, isTrue);
      expect(AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).isPhoneVisible, isFalse);
    });
  });

  // ── displayStatus ─────────────────────────────────────────────────────────
  group('AppointmentModel.displayStatus', () {
    final statuses = {
      'REQUESTED': 'Pending',
      'CONFIRMED': 'Confirmed',
      'REJECTED': 'Rejected',
      'COMPLETED': 'Completed',
      'CANCELLED': 'Cancelled',
    };

    statuses.forEach((status, expected) {
      test('$status → "$expected"', () {
        expect(
          AppointmentModel.fromJson(_baseJson(status: status)).displayStatus,
          expected,
        );
      });
    });

    test('unknown status returns raw value', () {
      final model = AppointmentModel.fromJson(_baseJson(status: 'CUSTOM_STATUS'));
      expect(model.displayStatus, 'CUSTOM_STATUS');
    });
  });

  // ── statusColor ───────────────────────────────────────────────────────────
  group('AppointmentModel.statusColor', () {
    test('REQUESTED → orange', () {
      expect(
        AppointmentModel.fromJson(_baseJson(status: 'REQUESTED')).statusColor,
        Colors.orange,
      );
    });

    test('CONFIRMED → green', () {
      expect(
        AppointmentModel.fromJson(_baseJson(status: 'CONFIRMED')).statusColor,
        Colors.green,
      );
    });

    test('REJECTED → red', () {
      expect(
        AppointmentModel.fromJson(_baseJson(status: 'REJECTED')).statusColor,
        Colors.red,
      );
    });
  });

  // ── modeDisplay ───────────────────────────────────────────────────────────
  group('AppointmentModel.modeDisplay', () {
    final modes = {
      'in_person': 'In-Person',
      'video': 'Video Call',
      'phone': 'Phone Call',
      'chat': 'Chat',
    };

    modes.forEach((mode, expected) {
      test('$mode → "$expected"', () {
        expect(
          AppointmentModel.fromJson(_baseJson(mode: mode)).modeDisplay,
          expected,
        );
      });
    });
  });

  // ── formattedFee ──────────────────────────────────────────────────────────
  group('AppointmentModel.formattedFee', () {
    test('returns ₹ prefix + integer amount', () {
      final json = _baseJson()..['fee'] = '500.00';
      expect(AppointmentModel.fromJson(json).formattedFee, '₹500');
    });

    test('returns empty string for null fee', () {
      expect(AppointmentModel.fromJson(_baseJson()).formattedFee, '');
    });
  });

  // ── formattedSchedule ─────────────────────────────────────────────────────
  group('AppointmentModel.formattedSchedule', () {
    test('returns null when no scheduled_date', () {
      expect(AppointmentModel.fromJson(_baseJson()).formattedSchedule, isNull);
    });

    test('includes date and time', () {
      final json = _baseJson()
        ..['scheduled_date'] = '2024-06-15'
        ..['scheduled_start_time'] = '10:30:00'
        ..['scheduled_end_time'] = '11:00:00';
      final schedule = AppointmentModel.fromJson(json).formattedSchedule;
      expect(schedule, isNotNull);
      expect(schedule, contains('Jun'));
      expect(schedule, contains('10:30'));
    });
  });
}
