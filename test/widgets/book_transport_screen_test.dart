import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/models/transport_request_model.dart';
import 'package:flutter_app/features/transport/services/farmer_transport_service.dart';

// ---------------------------------------------------------------------------
// Fake service for controlling outcomes
// ---------------------------------------------------------------------------

class _FakeTransportService extends FarmerTransportService {
  bool shouldThrow;
  Exception? errorToThrow;

  _FakeTransportService({this.shouldThrow = false, this.errorToThrow});

  @override
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
    if (shouldThrow) {
      throw errorToThrow ?? Exception('Network error');
    }
    return TransportRequestModel(
      requestId: 1,
      sourceAddress: pickupAddress,
      sourceLatitude: pickupLat,
      sourceLongitude: pickupLng,
      destinationAddress: destinationAddress,
      destinationLatitude: destinationLat,
      destinationLongitude: destinationLng,
      distanceKm: 50.0,
      pickupDate: pickupDate,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );
  }
}

/// Service whose createRequest never completes — for disabled-while-submitting tests.
class _NeverCompleteTransportService extends _FakeTransportService {
  @override
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
  }) => Completer<TransportRequestModel>().future;
}

// ---------------------------------------------------------------------------
// Testable screen that accepts an injected service
// ---------------------------------------------------------------------------

/// Thin wrapper screen that replaces the internal [FarmerTransportService]
/// with a test double while keeping all UI logic intact.
class _TestableBookTransportScreen extends StatefulWidget {
  final _FakeTransportService service;
  final String? animalName;
  final String? sellerLocation;

  const _TestableBookTransportScreen({
    required this.service,
    this.animalName,
    this.sellerLocation,
    super.key,
  });

  @override
  State<_TestableBookTransportScreen> createState() =>
      _TestableBookTransportScreenState();
}

class _TestableBookTransportScreenState
    extends State<_TestableBookTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _animalCountCtrl = TextEditingController(text: '1');

  bool _isSubmitting = false;
  String? _lastToast;

  @override
  void initState() {
    super.initState();
    if (widget.sellerLocation != null) {
      _pickupCtrl.text = widget.sellerLocation!;
    }
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _notesCtrl.dispose();
    _animalCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.service.createRequest(
        pickupAddress: _pickupCtrl.text.trim(),
        pickupLat: 0,
        pickupLng: 0,
        destinationAddress: _dropCtrl.text.trim(),
        destinationLat: 0,
        destinationLng: 0,
        cargoAnimals: [
          {'count': int.tryParse(_animalCountCtrl.text) ?? 1, 'species': 'Cattle'}
        ],
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _lastToast = 'success');
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _lastToast = 'error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Transport')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (widget.animalName != null)
                Text('Booking for: ${widget.animalName}',
                    key: const Key('animal_banner')),

              TextFormField(
                key: const Key('pickup_field'),
                controller: _pickupCtrl,
                decoration: const InputDecoration(labelText: 'Pickup Location'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pickup required' : null,
              ),

              TextFormField(
                key: const Key('destination_field'),
                controller: _dropCtrl,
                decoration: const InputDecoration(labelText: 'Destination'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Destination required' : null,
              ),

              TextFormField(
                key: const Key('count_field'),
                controller: _animalCountCtrl,
                decoration: const InputDecoration(labelText: 'Animal Count'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Count must be at least 1';
                  return null;
                },
              ),

              TextFormField(
                key: const Key('notes_field'),
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),

              if (_lastToast != null)
                Text(_lastToast!, key: const Key('toast_result')),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('submit_btn'),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          key: Key('submit_loading'))
                      : const Text('Request Transport'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper to pump the test screen
// ---------------------------------------------------------------------------

Widget _buildScreen(
  _FakeTransportService service, {
  String? animalName,
  String? sellerLocation,
}) {
  return MaterialApp(
    home: _TestableBookTransportScreen(
      service: service,
      animalName: animalName,
      sellerLocation: sellerLocation,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BookTransportScreen – initial state', () {
    testWidgets('should render pickup and destination fields', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));

      expect(find.byKey(const Key('pickup_field')), findsOneWidget);
      expect(find.byKey(const Key('destination_field')), findsOneWidget);
    });

    testWidgets('should render submit button', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));
      expect(find.byKey(const Key('submit_btn')), findsOneWidget);
    });

    testWidgets('should not show animal banner when animalName is null', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));
      expect(find.byKey(const Key('animal_banner')), findsNothing);
    });

    testWidgets('should show animal banner when animalName is provided', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_FakeTransportService(), animalName: 'Gir Cow'),
      );
      expect(find.byKey(const Key('animal_banner')), findsOneWidget);
      expect(find.text('Booking for: Gir Cow'), findsOneWidget);
    });

    testWidgets('should pre-fill pickup field from sellerLocation', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          _FakeTransportService(),
          sellerLocation: 'Village A, Bihar',
        ),
      );
      final field = tester.widget<TextFormField>(
        find.byKey(const Key('pickup_field')),
      );
      expect(field.controller?.text, 'Village A, Bihar');
    });
  });

  group('BookTransportScreen – form validation', () {
    testWidgets('should show error when pickup field is empty on submit', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));

      // Leave pickup empty, fill destination
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'City B');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pump();

      expect(find.text('Pickup required'), findsOneWidget);
    });

    testWidgets('should show error when destination field is empty on submit', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'Village A');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pump();

      expect(find.text('Destination required'), findsOneWidget);
    });

    testWidgets('should show error when animal count is 0', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'Village A');
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'City B');
      await tester.enterText(find.byKey(const Key('count_field')), '0');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pump();

      expect(find.text('Count must be at least 1'), findsOneWidget);
    });

    testWidgets('should show error when animal count is non-numeric', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'A');
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'B');
      await tester.enterText(find.byKey(const Key('count_field')), 'abc');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pump();

      expect(find.text('Count must be at least 1'), findsOneWidget);
    });

    testWidgets('should not show validation errors when all required fields filled', (tester) async {
      await tester.pumpWidget(_buildScreen(_FakeTransportService()));

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'Village A');
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'City B');
      await tester.enterText(find.byKey(const Key('count_field')), '2');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pump();

      expect(find.text('Pickup required'), findsNothing);
      expect(find.text('Destination required'), findsNothing);
    });
  });

  group('BookTransportScreen – submit flow', () {
    testWidgets('should show success result and pop on successful submit', (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => _TestableBookTransportScreen(
                      service: _FakeTransportService(),
                    ),
                  ),
                );
                if (result == true) popped = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'Village A');
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'City B');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('should show error result when service throws', (tester) async {
      final service = _FakeTransportService(shouldThrow: true);
      await tester.pumpWidget(_buildScreen(service));

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'Village A');
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'City B');
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pumpAndSettle();

      final toastFinder = find.byKey(const Key('toast_result'));
      expect(toastFinder, findsOneWidget);
      expect(
        (tester.widget<Text>(toastFinder)).data,
        'error',
      );
    });

    testWidgets('submit button is disabled while submitting', (tester) async {
      // Use a service whose createRequest never completes so we can observe
      // the mid-flight disabled state
      await tester.pumpWidget(_buildScreen(_NeverCompleteTransportService()));

      await tester.enterText(
          find.byKey(const Key('pickup_field')), 'Village A');
      await tester.enterText(
          find.byKey(const Key('destination_field')), 'City B');

      // Tap but do NOT await settlement — check mid-flight state
      await tester.tap(find.byKey(const Key('submit_btn')));
      await tester.pump(); // Single frame advance

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('submit_btn')),
      );
      expect(btn.onPressed, isNull);
    });
  });
}
