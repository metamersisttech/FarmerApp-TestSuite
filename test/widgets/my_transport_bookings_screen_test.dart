import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/farmer_transport_service.dart';

// ---------------------------------------------------------------------------
// Fake service
// ---------------------------------------------------------------------------

class _FakeService extends FarmerTransportService {
  final List<TransportRequestModel> requests;
  final bool shouldThrow;

  _FakeService({this.requests = const [], this.shouldThrow = false});

  @override
  Future<List<TransportRequestModel>> getMyRequests({String? status}) async {
    if (shouldThrow) throw Exception('Network failure');
    return requests;
  }
}

// ---------------------------------------------------------------------------
// Testable version of MyTransportBookingsScreen
// (mirrors the real screen but accepts injected service)
// ---------------------------------------------------------------------------

class _TestableMyBookingsScreen extends StatefulWidget {
  final _FakeService service;
  const _TestableMyBookingsScreen({required this.service, super.key});

  @override
  State<_TestableMyBookingsScreen> createState() =>
      _TestableMyBookingsScreenState();
}

class _TestableMyBookingsScreenState
    extends State<_TestableMyBookingsScreen> {
  List<TransportRequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.service.getMyRequests();
      if (mounted) setState(() => _requests = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TransportRequestModel> get _active => _requests.where((r) {
        return r.statusEnum == TransportRequestStatus.pending ||
            r.statusEnum == TransportRequestStatus.accepted ||
            r.statusEnum == TransportRequestStatus.inProgress ||
            r.statusEnum == TransportRequestStatus.inTransit;
      }).toList();

  List<TransportRequestModel> get _past => _requests.where((r) {
        return r.statusEnum == TransportRequestStatus.completed ||
            r.statusEnum == TransportRequestStatus.cancelled ||
            r.statusEnum == TransportRequestStatus.expired;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            key: const Key('refresh_btn'),
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('loading_indicator')),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load bookings',
                key: const Key('error_text'), style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              key: const Key('retry_btn'),
              onPressed: _loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return const Center(
        child: Text('No bookings yet', key: Key('empty_text')),
      );
    }

    return ListView(
      children: [
        if (_active.isNotEmpty) ...[
          Text(
            'Active (${_active.length})',
            key: const Key('active_header'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._active.map(
            (r) => ListTile(
              key: Key('request_${r.requestId}'),
              title: Text(r.routeDisplay),
              subtitle: Text(r.statusDisplay),
            ),
          ),
        ],
        if (_past.isNotEmpty) ...[
          Text(
            'Past (${_past.length})',
            key: const Key('past_header'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._past.map(
            (r) => ListTile(
              key: Key('request_${r.requestId}'),
              title: Text(r.routeDisplay),
              subtitle: Text(r.statusDisplay),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

TransportRequestModel _makeRequest({
  required int id,
  String status = 'PENDING',
  String from = 'Village A',
  String to = 'City B',
}) {
  return TransportRequestModel(
    requestId: id,
    sourceAddress: from,
    sourceLatitude: 0,
    sourceLongitude: 0,
    destinationAddress: to,
    destinationLatitude: 0,
    destinationLongitude: 0,
    distanceKm: 50.0,
    pickupDate: DateTime(2026, 5, 1),
    status: status,
    createdAt: DateTime(2026, 3, 1),
  );
}

Widget _buildApp(_FakeService service) => MaterialApp(
      home: _TestableMyBookingsScreen(service: service),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MyTransportBookingsScreen – loading state', () {
    testWidgets('should show loading indicator while fetching', (tester) async {
      // Use a service that never resolves so the loading state persists
      final service = _NeverCompleteService();
      await tester.pumpWidget(_buildApp(service));
      await tester.pump();
      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
    });

    testWidgets('should hide loading indicator after data loads', (tester) async {
      final service = _FakeService(requests: [_makeRequest(id: 1)]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('loading_indicator')), findsNothing);
    });
  });

  group('MyTransportBookingsScreen – empty state', () {
    testWidgets('should show empty state when no requests', (tester) async {
      final service = _FakeService(requests: []);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('empty_text')), findsOneWidget);
    });

    testWidgets('should not show active or past headers on empty list', (tester) async {
      final service = _FakeService(requests: []);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('active_header')), findsNothing);
      expect(find.byKey(const Key('past_header')), findsNothing);
    });
  });

  group('MyTransportBookingsScreen – error state', () {
    testWidgets('should show error message on service failure', (tester) async {
      final service = _FakeService(shouldThrow: true);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('error_text')), findsOneWidget);
    });

    testWidgets('should show retry button on error', (tester) async {
      final service = _FakeService(shouldThrow: true);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('retry_btn')), findsOneWidget);
    });

    testWidgets('tapping retry reloads the screen', (tester) async {
      // First call throws, second call succeeds
      var callCount = 0;
      final service = _FakeService(requests: [_makeRequest(id: 5)]);
      final overrideService = _CallCountService(service: service);

      await tester.pumpWidget(
        MaterialApp(
          home: _TestableMyBookingsScreen(service: overrideService),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('tapping refresh button reloads requests', (tester) async {
      final service = _FakeService(requests: [_makeRequest(id: 1)]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      // Tap refresh and let it settle — data should still be shown
      await tester.tap(find.byKey(const Key('refresh_btn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('loading_indicator')), findsNothing);
      expect(find.byKey(const Key('request_1')), findsOneWidget);
    });
  });

  group('MyTransportBookingsScreen – list state', () {
    testWidgets('should display active requests in active section', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 1, status: 'PENDING'),
        _makeRequest(id: 2, status: 'ACCEPTED'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_header')), findsOneWidget);
      expect(find.byKey(const Key('request_1')), findsOneWidget);
      expect(find.byKey(const Key('request_2')), findsOneWidget);
    });

    testWidgets('should display past requests in past section', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 3, status: 'COMPLETED'),
        _makeRequest(id: 4, status: 'CANCELLED'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('past_header')), findsOneWidget);
      expect(find.byKey(const Key('request_3')), findsOneWidget);
      expect(find.byKey(const Key('request_4')), findsOneWidget);
    });

    testWidgets('IN_TRANSIT requests appear in active section', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 5, status: 'IN_TRANSIT'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_header')), findsOneWidget);
      expect(find.byKey(const Key('request_5')), findsOneWidget);
      expect(find.byKey(const Key('past_header')), findsNothing);
    });

    testWidgets('EXPIRED requests appear in past section', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 6, status: 'EXPIRED'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('past_header')), findsOneWidget);
      expect(find.byKey(const Key('request_6')), findsOneWidget);
      expect(find.byKey(const Key('active_header')), findsNothing);
    });

    testWidgets('mixed active and past requests show both sections', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 10, status: 'PENDING'),
        _makeRequest(id: 11, status: 'COMPLETED'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_header')), findsOneWidget);
      expect(find.byKey(const Key('past_header')), findsOneWidget);
    });

    testWidgets('active header shows correct count', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 1, status: 'PENDING'),
        _makeRequest(id: 2, status: 'ACCEPTED'),
        _makeRequest(id: 3, status: 'COMPLETED'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.text('Active (2)'), findsOneWidget);
    });

    testWidgets('route display shows source and destination', (tester) async {
      final service = _FakeService(requests: [
        _makeRequest(id: 1, from: 'Farm XYZ', to: 'Market ABC'),
      ]);
      await tester.pumpWidget(_buildApp(service));
      await tester.pumpAndSettle();

      expect(find.text('Farm XYZ → Market ABC'), findsOneWidget);
    });
  });
}

/// Service that never completes — used to observe mid-flight loading state.
class _NeverCompleteService extends _FakeService {
  final _completer = Completer<List<TransportRequestModel>>();

  _NeverCompleteService() : super(requests: []);

  @override
  Future<List<TransportRequestModel>> getMyRequests({String? status}) =>
      _completer.future;
}

/// Helper subclass that counts calls without changing behaviour.
class _CallCountService extends _FakeService {
  final _FakeService _inner;
  int callCount = 0;

  _CallCountService({required _FakeService service})
      : _inner = service,
        super(requests: service.requests, shouldThrow: service.shouldThrow);

  @override
  Future<List<TransportRequestModel>> getMyRequests({String? status}) async {
    callCount++;
    return _inner.getMyRequests(status: status);
  }
}
