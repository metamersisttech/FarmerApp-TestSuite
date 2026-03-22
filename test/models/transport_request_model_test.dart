import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';

void main() {
  group('TransportRequestStatus', () {
    test('should parse PENDING from string', () {
      expect(
        TransportRequestStatus.fromString('PENDING'),
        TransportRequestStatus.pending,
      );
    });

    test('should parse ACCEPTED from lowercase string', () {
      expect(
        TransportRequestStatus.fromString('accepted'),
        TransportRequestStatus.accepted,
      );
    });

    test('should parse IN_PROGRESS', () {
      expect(
        TransportRequestStatus.fromString('IN_PROGRESS'),
        TransportRequestStatus.inProgress,
      );
    });

    test('should parse IN_TRANSIT', () {
      expect(
        TransportRequestStatus.fromString('IN_TRANSIT'),
        TransportRequestStatus.inTransit,
      );
    });

    test('should parse COMPLETED', () {
      expect(
        TransportRequestStatus.fromString('COMPLETED'),
        TransportRequestStatus.completed,
      );
    });

    test('should parse CANCELLED', () {
      expect(
        TransportRequestStatus.fromString('CANCELLED'),
        TransportRequestStatus.cancelled,
      );
    });

    test('should parse EXPIRED', () {
      expect(
        TransportRequestStatus.fromString('EXPIRED'),
        TransportRequestStatus.expired,
      );
    });

    test('should fallback to pending for unknown status', () {
      expect(
        TransportRequestStatus.fromString('UNKNOWN_STATUS'),
        TransportRequestStatus.pending,
      );
    });

    test('should return orange color for pending status', () {
      expect(TransportRequestStatus.pending.color, Colors.orange);
    });

    test('should return blue color for accepted status', () {
      expect(TransportRequestStatus.accepted.color, Colors.blue);
    });

    test('should return green color for completed status', () {
      expect(TransportRequestStatus.completed.color, Colors.green);
    });

    test('should return red color for cancelled status', () {
      expect(TransportRequestStatus.cancelled.color, Colors.red);
    });

    test('should return grey color for expired status', () {
      expect(TransportRequestStatus.expired.color, Colors.grey);
    });

    test('each status has correct displayName', () {
      expect(TransportRequestStatus.pending.displayName, 'Pending');
      expect(TransportRequestStatus.accepted.displayName, 'Accepted');
      expect(TransportRequestStatus.inProgress.displayName, 'In Progress');
      expect(TransportRequestStatus.inTransit.displayName, 'In Transit');
      expect(TransportRequestStatus.completed.displayName, 'Completed');
      expect(TransportRequestStatus.cancelled.displayName, 'Cancelled');
      expect(TransportRequestStatus.expired.displayName, 'Expired');
    });
  });

  group('TransportRequestModel.fromJson', () {
    Map<String, dynamic> _baseJson() => {
          'request_id': 42,
          'source_address': 'Village A, Bihar',
          'source_latitude': '25.5941',
          'source_longitude': '85.1376',
          'destination_address': 'City B, Bihar',
          'destination_latitude': 25.5000,
          'destination_longitude': 85.0000,
          'distance_km': '120.5',
          'estimated_weight_kg': 450.0,
          'pickup_date': '2026-04-01',
          'pickup_time': '09:30',
          'estimated_fare_min': 1500.0,
          'estimated_fare_max': 2500.0,
          'status': 'PENDING',
          'fare_approved_by_requestor': false,
          'fare_approved_by_provider': false,
          'created_at': '2026-03-15T10:00:00.000Z',
        };

    test('should parse request_id correctly', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.requestId, 42);
    });

    test('should fallback to id field when request_id is absent', () {
      final json = _baseJson();
      json.remove('request_id');
      json['id'] = 99;
      final model = TransportRequestModel.fromJson(json);
      expect(model.requestId, 99);
    });

    test('should parse source address', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.sourceAddress, 'Village A, Bihar');
    });

    test('should parse latitude and longitude as double from string', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.sourceLatitude, 25.5941);
      expect(model.sourceLongitude, 85.1376);
    });

    test('should parse latitude and longitude as double from num', () {
      final json = _baseJson();
      json['destination_latitude'] = 25.5;
      json['destination_longitude'] = 85.0;
      final model = TransportRequestModel.fromJson(json);
      expect(model.destinationLatitude, 25.5);
      expect(model.destinationLongitude, 85.0);
    });

    test('should parse distance_km from string', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.distanceKm, 120.5);
    });

    test('should parse pickup_date', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.pickupDate.year, 2026);
      expect(model.pickupDate.month, 4);
      expect(model.pickupDate.day, 1);
    });

    test('should parse pickup_time HH:MM format', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.pickupTime?.hour, 9);
      expect(model.pickupTime?.minute, 30);
    });

    test('should parse pickup_time HH:MM:SS format', () {
      final json = _baseJson();
      json['pickup_time'] = '14:45:00';
      final model = TransportRequestModel.fromJson(json);
      expect(model.pickupTime?.hour, 14);
      expect(model.pickupTime?.minute, 45);
    });

    test('should leave pickupTime null when absent', () {
      final json = _baseJson();
      json.remove('pickup_time');
      final model = TransportRequestModel.fromJson(json);
      expect(model.pickupTime, isNull);
    });

    test('should parse fare range', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.estimatedFareMin, 1500.0);
      expect(model.estimatedFareMax, 2500.0);
    });

    test('should parse status', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.status, 'PENDING');
    });

    test('should parse cargo_animals list', () {
      final json = _baseJson();
      json['cargo_animals'] = [
        {'count': 2, 'species': 'Cattle', 'breed': 'Gir'},
        {'count': 1, 'species': 'Buffalo'},
      ];
      final model = TransportRequestModel.fromJson(json);
      expect(model.cargoAnimals.length, 2);
      expect(model.cargoAnimals[0].count, 2);
      expect(model.cargoAnimals[0].species, 'Cattle');
      expect(model.cargoAnimals[1].species, 'Buffalo');
    });

    test('should also parse cargo field as alias', () {
      final json = _baseJson();
      json['cargo'] = [
        {'count': 3, 'species': 'Goat'},
      ];
      final model = TransportRequestModel.fromJson(json);
      expect(model.cargoAnimals.length, 1);
      expect(model.cargoAnimals[0].count, 3);
    });

    test('should parse optional proposedFare', () {
      final json = _baseJson();
      json['proposed_fare'] = '2000';
      final model = TransportRequestModel.fromJson(json);
      expect(model.proposedFare, 2000.0);
    });

    test('should leave proposedFare null when absent', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.proposedFare, isNull);
    });

    test('should parse fare_approved_by_requestor', () {
      final json = _baseJson();
      json['fare_approved_by_requestor'] = true;
      final model = TransportRequestModel.fromJson(json);
      expect(model.fareApprovedByRequestor, isTrue);
    });

    test('should parse optional final fare', () {
      final json = _baseJson();
      json['final_fare'] = 1800.0;
      final model = TransportRequestModel.fromJson(json);
      expect(model.finalFare, 1800.0);
    });

    test('should parse optional cancellation reason', () {
      final json = _baseJson();
      json['cancellation_reason'] = 'Changed plans';
      final model = TransportRequestModel.fromJson(json);
      expect(model.cancellationReason, 'Changed plans');
    });

    test('should parse expiresAt when provided', () {
      final json = _baseJson();
      json['expires_at'] = '2026-04-02T00:00:00.000Z';
      final model = TransportRequestModel.fromJson(json);
      expect(model.expiresAt, isNotNull);
      expect(model.expiresAt!.year, 2026);
      expect(model.expiresAt!.month, 4);
    });

    test('should parse createdAt', () {
      final model = TransportRequestModel.fromJson(_baseJson());
      expect(model.createdAt.year, 2026);
      expect(model.createdAt.month, 3);
    });
  });

  group('TransportRequestModel.toJson', () {
    TransportRequestModel _buildModel({
      String status = 'PENDING',
      List<CargoAnimalModel> cargoAnimals = const [],
      TimeOfDay? pickupTime,
      String? notes,
      double? proposedFare,
    }) {
      return TransportRequestModel(
        requestId: 10,
        sourceAddress: 'Source',
        sourceLatitude: 20.0,
        sourceLongitude: 80.0,
        destinationAddress: 'Destination',
        destinationLatitude: 21.0,
        destinationLongitude: 81.0,
        distanceKm: 50.0,
        cargoAnimals: cargoAnimals,
        pickupDate: DateTime(2026, 5, 10),
        pickupTime: pickupTime,
        estimatedFareMin: 500.0,
        estimatedFareMax: 1000.0,
        notes: notes,
        status: status,
        proposedFare: proposedFare,
        fareApprovedByRequestor: false,
        fareApprovedByProvider: false,
        createdAt: DateTime(2026, 3, 1),
      );
    }

    test('should include request_id in toJson', () {
      final json = _buildModel().toJson();
      expect(json['request_id'], 10);
    });

    test('should include source and destination addresses', () {
      final json = _buildModel().toJson();
      expect(json['source_address'], 'Source');
      expect(json['destination_address'], 'Destination');
    });

    test('should format pickup_date as YYYY-MM-DD', () {
      final json = _buildModel().toJson();
      expect(json['pickup_date'], '2026-05-10');
    });

    test('should omit pickup_time when null', () {
      final json = _buildModel().toJson();
      expect(json.containsKey('pickup_time'), isFalse);
    });

    test('should include formatted pickup_time when present', () {
      final json = _buildModel(
        pickupTime: const TimeOfDay(hour: 9, minute: 5),
      ).toJson();
      expect(json['pickup_time'], '09:05');
    });

    test('should include zero-padded hour in pickup_time', () {
      final json = _buildModel(
        pickupTime: const TimeOfDay(hour: 14, minute: 30),
      ).toJson();
      expect(json['pickup_time'], '14:30');
    });

    test('should omit notes when null', () {
      final json = _buildModel().toJson();
      expect(json.containsKey('notes'), isFalse);
    });

    test('should include notes when present', () {
      final json = _buildModel(notes: 'Handle with care').toJson();
      expect(json['notes'], 'Handle with care');
    });

    test('should include cargo_animals list', () {
      final cargo = [CargoAnimalModel(count: 2, species: 'Cattle')];
      final json = _buildModel(cargoAnimals: cargo).toJson();
      expect((json['cargo_animals'] as List).length, 1);
    });

    test('should omit proposedFare when null', () {
      final json = _buildModel().toJson();
      expect(json.containsKey('proposed_fare'), isFalse);
    });

    test('should include proposedFare when present', () {
      final json = _buildModel(proposedFare: 750.0).toJson();
      expect(json['proposed_fare'], 750.0);
    });

    test('should round-trip through fromJson/toJson preserving key fields', () {
      final original = _buildModel(
        status: 'ACCEPTED',
        notes: 'Fragile',
        pickupTime: const TimeOfDay(hour: 10, minute: 15),
      );
      final json = original.toJson();
      // Re-add dates needed by fromJson
      json['created_at'] = '2026-03-01T00:00:00.000Z';
      json['pickup_date'] = '2026-05-10';
      final restored = TransportRequestModel.fromJson(json);
      expect(restored.requestId, original.requestId);
      expect(restored.sourceAddress, original.sourceAddress);
      expect(restored.status, original.status);
      expect(restored.notes, original.notes);
      expect(restored.pickupTime?.hour, original.pickupTime?.hour);
      expect(restored.pickupTime?.minute, original.pickupTime?.minute);
    });
  });

  group('TransportRequestModel computed properties', () {
    TransportRequestModel _make({
      String status = 'PENDING',
      double? finalFare,
      double? proposedFare,
      double estimatedFareMin = 1000.0,
      double estimatedFareMax = 2000.0,
      double? distanceFromProvider,
      List<CargoAnimalModel> cargoAnimals = const [],
      DateTime? expiresAt,
      bool fareApprovedByRequestor = false,
      bool fareApprovedByProvider = false,
    }) {
      return TransportRequestModel(
        requestId: 1,
        sourceAddress: 'A',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'B',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 75.25,
        cargoAnimals: cargoAnimals,
        estimatedWeightKg: 300.0,
        pickupDate: DateTime(2026, 6, 15),
        estimatedFareMin: estimatedFareMin,
        estimatedFareMax: estimatedFareMax,
        distanceFromProvider: distanceFromProvider,
        expiresAt: expiresAt,
        status: status,
        finalFare: finalFare,
        proposedFare: proposedFare,
        fareApprovedByRequestor: fareApprovedByRequestor,
        fareApprovedByProvider: fareApprovedByProvider,
        createdAt: DateTime(2026, 3, 1),
      );
    }

    test('statusEnum returns correct enum for PENDING', () {
      expect(_make(status: 'PENDING').statusEnum, TransportRequestStatus.pending);
    });

    test('statusDisplay returns display name', () {
      expect(_make(status: 'COMPLETED').statusDisplay, 'Completed');
    });

    test('formattedPickupDate formats as d/m/yyyy', () {
      final model = _make();
      expect(model.formattedPickupDate, '15/6/2026');
    });

    test('formattedPickupTime returns null when no pickupTime', () {
      expect(_make().formattedPickupTime, isNull);
    });

    test('formattedPickupTime formats morning time as AM', () {
      final model = TransportRequestModel(
        requestId: 1,
        sourceAddress: 'A',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'B',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 0,
        pickupDate: DateTime.now(),
        pickupTime: const TimeOfDay(hour: 9, minute: 30),
        createdAt: DateTime.now(),
      );
      expect(model.formattedPickupTime, '09:30 AM');
    });

    test('formattedPickupTime formats afternoon time as PM', () {
      final model = TransportRequestModel(
        requestId: 1,
        sourceAddress: 'A',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'B',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 0,
        pickupDate: DateTime.now(),
        pickupTime: const TimeOfDay(hour: 14, minute: 5),
        createdAt: DateTime.now(),
      );
      expect(model.formattedPickupTime, '02:05 PM');
    });

    test('formattedPickupTime formats midnight hour 0 as 12 AM', () {
      final model = TransportRequestModel(
        requestId: 1,
        sourceAddress: 'A',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'B',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 0,
        pickupDate: DateTime.now(),
        pickupTime: const TimeOfDay(hour: 0, minute: 0),
        createdAt: DateTime.now(),
      );
      expect(model.formattedPickupTime, '12:00 AM');
    });

    test('formattedDistance returns one decimal km string', () {
      expect(_make().formattedDistance, '75.3 km');
    });

    test('formattedDistanceFromProvider returns null when not set', () {
      expect(_make().formattedDistanceFromProvider, isNull);
    });

    test('formattedDistanceFromProvider returns X km away', () {
      expect(_make(distanceFromProvider: 12.3).formattedDistanceFromProvider, '12.3 km away');
    });

    test('formattedFareRange uses rupee symbol and no decimal', () {
      final model = _make(estimatedFareMin: 1500.0, estimatedFareMax: 2500.0);
      expect(model.formattedFareRange, '₹1500 - ₹2500');
    });

    test('formattedFare returns finalFare when present', () {
      expect(_make(finalFare: 1800.0).formattedFare, '₹1800');
    });

    test('formattedFare returns proposedFare when no finalFare', () {
      expect(_make(proposedFare: 2100.0).formattedFare, '₹2100');
    });

    test('formattedFare returns fare range when neither final nor proposed', () {
      expect(
        _make(estimatedFareMin: 1000.0, estimatedFareMax: 2000.0).formattedFare,
        '₹1000 - ₹2000',
      );
    });

    test('formattedProposedFare returns null when not set', () {
      expect(_make().formattedProposedFare, isNull);
    });

    test('formattedProposedFare returns formatted value when set', () {
      expect(_make(proposedFare: 999.0).formattedProposedFare, '₹999');
    });

    test('formattedFinalFare returns null when not set', () {
      expect(_make().formattedFinalFare, isNull);
    });

    test('formattedWeight returns weight in kg with no decimal', () {
      final model = TransportRequestModel(
        requestId: 1,
        sourceAddress: 'A',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'B',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 0,
        estimatedWeightKg: 450.0,
        pickupDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      expect(model.formattedWeight, '450 kg');
    });

    test('cargoSummary returns "No cargo specified" when list is empty', () {
      expect(_make(cargoAnimals: []).cargoSummary, 'No cargo specified');
    });

    test('cargoSummary returns joined cargo summaries', () {
      final cargo = [
        const CargoAnimalModel(count: 2, species: 'Cattle'),
        const CargoAnimalModel(count: 1, species: 'Buffalo'),
      ];
      expect(_make(cargoAnimals: cargo).cargoSummary, '2 Cattles, 1 Buffalo');
    });

    test('totalAnimalCount sums cargo counts', () {
      final cargo = [
        const CargoAnimalModel(count: 3, species: 'Goat'),
        const CargoAnimalModel(count: 2, species: 'Sheep'),
      ];
      expect(_make(cargoAnimals: cargo).totalAnimalCount, 5);
    });

    test('totalAnimalCount is 0 when no cargo', () {
      expect(_make().totalAnimalCount, 0);
    });

    test('isExpired returns false when expiresAt is null', () {
      expect(_make().isExpired, isFalse);
    });

    test('isExpired returns false when expiresAt is in the future', () {
      final future = DateTime.now().add(const Duration(days: 7));
      expect(_make(expiresAt: future).isExpired, isFalse);
    });

    test('isExpired returns true when expiresAt is in the past', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(_make(expiresAt: past).isExpired, isTrue);
    });

    test('timeUntilExpiry is null when expiresAt is null', () {
      expect(_make().timeUntilExpiry, isNull);
    });

    test('timeUntilExpiry is zero when already expired', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(_make(expiresAt: past).timeUntilExpiry, Duration.zero);
    });

    test('timeUntilExpiry is positive when not yet expired', () {
      final future = DateTime.now().add(const Duration(hours: 2));
      expect(_make(expiresAt: future).timeUntilExpiry!.inMinutes, greaterThan(0));
    });

    test('isFareAgreed is false when neither party approved', () {
      expect(_make().isFareAgreed, isFalse);
    });

    test('isFareAgreed is false when only requestor approved', () {
      expect(
        _make(fareApprovedByRequestor: true, fareApprovedByProvider: false).isFareAgreed,
        isFalse,
      );
    });

    test('isFareAgreed is true when both parties approved', () {
      expect(
        _make(fareApprovedByRequestor: true, fareApprovedByProvider: true).isFareAgreed,
        isTrue,
      );
    });

    test('canAccept is true for pending non-expired request', () {
      final future = DateTime.now().add(const Duration(hours: 48));
      expect(_make(status: 'PENDING', expiresAt: future).canAccept, isTrue);
    });

    test('canAccept is false for accepted request', () {
      expect(_make(status: 'ACCEPTED').canAccept, isFalse);
    });

    test('canAccept is false for expired pending request', () {
      final past = DateTime.now().subtract(const Duration(minutes: 1));
      expect(_make(status: 'PENDING', expiresAt: past).canAccept, isFalse);
    });

    test('canProposeFare is true for accepted status', () {
      expect(_make(status: 'ACCEPTED').canProposeFare, isTrue);
    });

    test('canProposeFare is false for pending status', () {
      expect(_make(status: 'PENDING').canProposeFare, isFalse);
    });

    test('canConfirmPickup is true when in progress and fare agreed', () {
      expect(
        _make(
          status: 'IN_PROGRESS',
          fareApprovedByRequestor: true,
          fareApprovedByProvider: true,
        ).canConfirmPickup,
        isTrue,
      );
    });

    test('canConfirmPickup is false when in progress but fare not agreed', () {
      expect(_make(status: 'IN_PROGRESS').canConfirmPickup, isFalse);
    });

    test('canCancel is true for pending', () {
      expect(_make(status: 'PENDING').canCancel, isTrue);
    });

    test('canCancel is true for accepted', () {
      expect(_make(status: 'ACCEPTED').canCancel, isTrue);
    });

    test('canCancel is true for in progress', () {
      expect(_make(status: 'IN_PROGRESS').canCancel, isTrue);
    });

    test('canCancel is false for completed', () {
      expect(_make(status: 'COMPLETED').canCancel, isFalse);
    });

    test('canCancel is false for cancelled', () {
      expect(_make(status: 'CANCELLED').canCancel, isFalse);
    });

    test('routeDisplay returns arrow-separated route', () {
      expect(_make().routeDisplay, 'A → B');
    });
  });

  group('TransportRequestModel.copyWith', () {
    test('should update status via copyWith', () {
      final original = TransportRequestModel(
        requestId: 1,
        sourceAddress: 'From',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'To',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 10.0,
        pickupDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      final updated = original.copyWith(status: 'COMPLETED');
      expect(updated.status, 'COMPLETED');
      expect(updated.requestId, original.requestId);
      expect(updated.sourceAddress, original.sourceAddress);
    });

    test('should preserve original values when no copyWith args given', () {
      final original = TransportRequestModel(
        requestId: 5,
        sourceAddress: 'X',
        sourceLatitude: 1.1,
        sourceLongitude: 2.2,
        destinationAddress: 'Y',
        destinationLatitude: 3.3,
        destinationLongitude: 4.4,
        distanceKm: 30.0,
        pickupDate: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 3, 1),
      );
      final copy = original.copyWith();
      expect(copy.requestId, 5);
      expect(copy.sourceAddress, 'X');
      expect(copy.distanceKm, 30.0);
    });
  });

  group('TransportRequestModel.toString', () {
    test('should include requestId, status, and route', () {
      final model = TransportRequestModel(
        requestId: 7,
        sourceAddress: 'Alpha',
        sourceLatitude: 0,
        sourceLongitude: 0,
        destinationAddress: 'Beta',
        destinationLatitude: 0,
        destinationLongitude: 0,
        distanceKm: 0,
        pickupDate: DateTime.now(),
        status: 'ACCEPTED',
        createdAt: DateTime.now(),
      );
      final str = model.toString();
      expect(str, contains('7'));
      expect(str, contains('ACCEPTED'));
      expect(str, contains('Alpha'));
      expect(str, contains('Beta'));
    });
  });
}
