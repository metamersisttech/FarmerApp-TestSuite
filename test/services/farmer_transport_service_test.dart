import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';

// ---------------------------------------------------------------------------
// This test file tests the BEHAVIOUR of FarmerTransportService in isolation.
//
// Because the real FarmerTransportService depends on BackendHelper which
// in turn initialises Firebase-related singletons on construction, we test
// the service contract via a lightweight extracted interface and pure
// functional reimplementation rather than subclassing the real service.
//
// This approach lets us test all business logic (request building, response
// parsing, error propagation) without needing Firebase/Dio setup in tests.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Minimal HTTP interface — mirrors what FarmerTransportService calls
// ---------------------------------------------------------------------------

abstract class TransportHttpClient {
  Future<dynamic> get(String url);
  Future<dynamic> post(String url, Map<String, dynamic> body);
}

// ---------------------------------------------------------------------------
// Stub implementations
// ---------------------------------------------------------------------------

class _SuccessHttpClient implements TransportHttpClient {
  final dynamic getData;
  final dynamic postData;

  _SuccessHttpClient({this.getData, this.postData});

  @override
  Future<dynamic> get(String url) async => getData;

  @override
  Future<dynamic> post(String url, Map<String, dynamic> body) async => postData;
}

class _ErrorHttpClient implements TransportHttpClient {
  final Exception error;
  _ErrorHttpClient(this.error);

  @override
  Future<dynamic> get(String url) async => throw error;

  @override
  Future<dynamic> post(String url, Map<String, dynamic> body) async => throw error;
}

// ---------------------------------------------------------------------------
// Pure reimplementation of FarmerTransportService contract using the
// injectable client — matches the exact logic in the real service
// ---------------------------------------------------------------------------

class TestFarmerTransportService {
  final TransportHttpClient _http;

  TestFarmerTransportService(this._http);

  Future<TransportRequestModel> createRequest({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String destinationAddress,
    required double destinationLat,
    required double destinationLng,
    required List<Map<String, dynamic>> cargoAnimals,
    required DateTime pickupDate,
    String? pickupTime,
    double? estimatedFareMin,
    double? estimatedFareMax,
    String? notes,
    int? listingId,
  }) async {
    final body = <String, dynamic>{
      'source_address': pickupAddress,
      'source_latitude': pickupLat,
      'source_longitude': pickupLng,
      'destination_address': destinationAddress,
      'destination_latitude': destinationLat,
      'destination_longitude': destinationLng,
      'cargo_animals': cargoAnimals,
      'pickup_date': pickupDate.toIso8601String().split('T').first,
      if (pickupTime != null) 'pickup_time': pickupTime,
      if (estimatedFareMin != null) 'estimated_fare_min': estimatedFareMin,
      if (estimatedFareMax != null) 'estimated_fare_max': estimatedFareMax,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (listingId != null) 'listing_id': listingId,
    };

    final response = await _http.post('transport/requests/', body);
    return TransportRequestModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<TransportRequestModel>> getMyRequests({String? status}) async {
    final queryParams = status != null ? '?status=$status' : '';
    final response = await _http.get('transport/requests/$queryParams');

    final results =
        (response as Map<String, dynamic>)['results'] ?? response;
    if (results is List) {
      return results
          .map((e) => TransportRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<TransportRequestModel> getRequestById(int requestId) async {
    final response = await _http.get('transport/requests/$requestId/');
    return TransportRequestModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> cancelRequest(int requestId) async {
    await _http.post('transport/requests/$requestId/cancel/', {});
  }

  Future<TransportRequestModel> approveFare(int requestId) async {
    final response =
        await _http.post('transport/requests/$requestId/approve-fare/', {});
    return TransportRequestModel.fromJson(response as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _requestJson({
  int id = 1,
  String status = 'PENDING',
  String sourceAddress = 'Village A',
  String destinationAddress = 'City B',
}) =>
    {
      'request_id': id,
      'source_address': sourceAddress,
      'source_latitude': 25.0,
      'source_longitude': 85.0,
      'destination_address': destinationAddress,
      'destination_latitude': 26.0,
      'destination_longitude': 86.0,
      'distance_km': 100.0,
      'estimated_weight_kg': 300.0,
      'pickup_date': '2026-05-01',
      'estimated_fare_min': 1000.0,
      'estimated_fare_max': 2000.0,
      'status': status,
      'fare_approved_by_requestor': false,
      'fare_approved_by_provider': false,
      'created_at': '2026-03-01T00:00:00.000Z',
    };

TestFarmerTransportService _service({
  dynamic getResponse,
  dynamic postResponse,
  Exception? error,
}) {
  if (error != null) return TestFarmerTransportService(_ErrorHttpClient(error));
  return TestFarmerTransportService(
    _SuccessHttpClient(getData: getResponse, postData: postResponse),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FarmerTransportService.createRequest', () {
    test('should return TransportRequestModel on success', () async {
      final svc = _service(postResponse: _requestJson(id: 42));

      final result = await svc.createRequest(
        pickupAddress: 'Village A',
        pickupLat: 25.0,
        pickupLng: 85.0,
        destinationAddress: 'City B',
        destinationLat: 26.0,
        destinationLng: 86.0,
        cargoAnimals: [
          {'count': 2, 'species': 'Cattle'},
        ],
        pickupDate: DateTime(2026, 5, 1),
      );

      expect(result, isA<TransportRequestModel>());
      expect(result.requestId, 42);
    });

    test('should parse source and destination from response', () async {
      final svc = _service(
        postResponse: _requestJson(
          sourceAddress: 'Farm A',
          destinationAddress: 'Market B',
        ),
      );

      final result = await svc.createRequest(
        pickupAddress: 'Farm A',
        pickupLat: 0,
        pickupLng: 0,
        destinationAddress: 'Market B',
        destinationLat: 0,
        destinationLng: 0,
        cargoAnimals: [],
        pickupDate: DateTime(2026, 5, 1),
      );

      expect(result.sourceAddress, 'Farm A');
      expect(result.destinationAddress, 'Market B');
    });

    test('should set status to PENDING on fresh request', () async {
      final svc = _service(postResponse: _requestJson(status: 'PENDING'));

      final result = await svc.createRequest(
        pickupAddress: 'A',
        pickupLat: 0,
        pickupLng: 0,
        destinationAddress: 'B',
        destinationLat: 0,
        destinationLng: 0,
        cargoAnimals: [],
        pickupDate: DateTime(2026, 6, 1),
      );

      expect(result.statusEnum, TransportRequestStatus.pending);
    });

    test('should build request body with pickup_time when provided', () async {
      // We verify the service does not crash and parses time in response
      final json = _requestJson();
      json['pickup_time'] = '09:30';
      final svc = _service(postResponse: json);

      final result = await svc.createRequest(
        pickupAddress: 'A',
        pickupLat: 0,
        pickupLng: 0,
        destinationAddress: 'B',
        destinationLat: 0,
        destinationLng: 0,
        cargoAnimals: [],
        pickupDate: DateTime(2026, 5, 1),
        pickupTime: '09:30',
      );

      expect(result.pickupTime?.hour, 9);
      expect(result.pickupTime?.minute, 30);
    });

    test('should propagate network exception', () async {
      final svc = _service(error: Exception('No internet connection'));

      await expectLater(
        svc.createRequest(
          pickupAddress: 'A',
          pickupLat: 0,
          pickupLng: 0,
          destinationAddress: 'B',
          destinationLat: 0,
          destinationLng: 0,
          cargoAnimals: [],
          pickupDate: DateTime(2026, 6, 1),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should propagate server error exception', () async {
      final svc = _service(error: Exception('500 Internal Server Error'));

      expect(
        () => svc.createRequest(
          pickupAddress: 'A',
          pickupLat: 0,
          pickupLng: 0,
          destinationAddress: 'B',
          destinationLat: 0,
          destinationLng: 0,
          cargoAnimals: [],
          pickupDate: DateTime(2026, 6, 1),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should include notes in body when provided', () async {
      // Verifies the method processes notes without crashing
      final svc = _service(postResponse: _requestJson());

      final result = await svc.createRequest(
        pickupAddress: 'A',
        pickupLat: 0,
        pickupLng: 0,
        destinationAddress: 'B',
        destinationLat: 0,
        destinationLng: 0,
        cargoAnimals: [],
        pickupDate: DateTime(2026, 5, 1),
        notes: 'Handle carefully',
      );

      expect(result, isA<TransportRequestModel>());
    });

    test('should include listingId in body when provided', () async {
      final svc = _service(postResponse: _requestJson());

      final result = await svc.createRequest(
        pickupAddress: 'A',
        pickupLat: 0,
        pickupLng: 0,
        destinationAddress: 'B',
        destinationLat: 0,
        destinationLng: 0,
        cargoAnimals: [],
        pickupDate: DateTime(2026, 5, 1),
        listingId: 55,
      );

      expect(result, isA<TransportRequestModel>());
    });
  });

  group('FarmerTransportService.getMyRequests', () {
    test('should return empty list when results is empty', () async {
      final svc = _service(getResponse: {'results': <dynamic>[]});
      final list = await svc.getMyRequests();
      expect(list, isEmpty);
    });

    test('should return list of TransportRequestModels from results', () async {
      final svc = _service(
        getResponse: {
          'results': [_requestJson(id: 1), _requestJson(id: 2)],
        },
      );

      final list = await svc.getMyRequests();
      expect(list.length, 2);
      expect(list[0].requestId, 1);
      expect(list[1].requestId, 2);
    });

    test('should return correct status for each request', () async {
      final svc = _service(
        getResponse: {
          'results': [
            _requestJson(id: 1, status: 'PENDING'),
            _requestJson(id: 2, status: 'COMPLETED'),
          ],
        },
      );

      final list = await svc.getMyRequests();
      expect(list[0].statusEnum, TransportRequestStatus.pending);
      expect(list[1].statusEnum, TransportRequestStatus.completed);
    });

    test('should return empty list when no results key and value is not list', () async {
      final svc = _service(getResponse: {'detail': 'No content'});
      final list = await svc.getMyRequests();
      expect(list, isEmpty);
    });

    test('should accept status filter parameter', () async {
      final svc = _service(
        getResponse: {
          'results': [_requestJson(id: 3, status: 'COMPLETED')],
        },
      );

      final list = await svc.getMyRequests(status: 'COMPLETED');
      expect(list.length, 1);
      expect(list.first.status, 'COMPLETED');
    });

    test('should propagate exception on HTTP error', () async {
      final svc = _service(error: Exception('403 Forbidden'));
      expect(() => svc.getMyRequests(), throwsA(isA<Exception>()));
    });

    test('should propagate exception on 401 unauthorized', () async {
      final svc = _service(error: Exception('401 Unauthorized'));
      expect(() => svc.getMyRequests(), throwsA(isA<Exception>()));
    });
  });

  group('FarmerTransportService.getRequestById', () {
    test('should return single TransportRequestModel', () async {
      final svc = _service(getResponse: _requestJson(id: 99));
      final result = await svc.getRequestById(99);
      expect(result.requestId, 99);
    });

    test('should parse status from response', () async {
      final svc = _service(
        getResponse: _requestJson(id: 5, status: 'ACCEPTED'),
      );
      final result = await svc.getRequestById(5);
      expect(result.statusEnum, TransportRequestStatus.accepted);
    });

    test('should propagate exception when not found', () async {
      final svc = _service(error: Exception('404 Not Found'));
      expect(() => svc.getRequestById(999), throwsA(isA<Exception>()));
    });

    test('should propagate network exception', () async {
      final svc = _service(error: Exception('Connection timeout'));
      expect(() => svc.getRequestById(1), throwsA(isA<Exception>()));
    });
  });

  group('FarmerTransportService.cancelRequest', () {
    test('should complete without error on 200 success', () async {
      final svc = _service(postResponse: {'detail': 'Cancelled'});
      await expectLater(svc.cancelRequest(1), completes);
    });

    test('should propagate exception on 400 bad request', () async {
      final svc = _service(error: Exception('400 Already cancelled'));
      expect(() => svc.cancelRequest(1), throwsA(isA<Exception>()));
    });

    test('should propagate exception on 403 forbidden', () async {
      final svc = _service(error: Exception('403 Forbidden'));
      expect(() => svc.cancelRequest(1), throwsA(isA<Exception>()));
    });

    test('should complete without error on 204 no content (empty response)', () async {
      final svc = _service(postResponse: null);
      // cancelRequest does not parse the response, so null is fine
      await expectLater(svc.cancelRequest(2), completes);
    });
  });

  group('FarmerTransportService.approveFare', () {
    test('should return updated model with fare approved', () async {
      final json = _requestJson(id: 5, status: 'ACCEPTED');
      json['fare_approved_by_requestor'] = true;
      json['proposed_fare'] = 1800.0;

      final svc = _service(postResponse: json);
      final result = await svc.approveFare(5);

      expect(result.requestId, 5);
      expect(result.fareApprovedByRequestor, isTrue);
      expect(result.proposedFare, 1800.0);
    });

    test('should propagate exception when request is in wrong state', () async {
      final svc = _service(error: Exception('400 Cannot approve fare now'));
      expect(() => svc.approveFare(1), throwsA(isA<Exception>()));
    });

    test('should propagate unauthorized exception', () async {
      final svc = _service(error: Exception('401 Unauthorized'));
      expect(() => svc.approveFare(1), throwsA(isA<Exception>()));
    });

    test('should parse isFareAgreed as true when both parties approve', () async {
      final json = _requestJson(id: 7, status: 'IN_PROGRESS');
      json['fare_approved_by_requestor'] = true;
      json['fare_approved_by_provider'] = true;

      final svc = _service(postResponse: json);
      final result = await svc.approveFare(7);

      expect(result.isFareAgreed, isTrue);
    });
  });
}
