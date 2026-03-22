import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/mixins/onboarding_form_state_mixin.dart';

// ---------------------------------------------------------------------------
// Test harness widget — lets us exercise the mixin in isolation
// ---------------------------------------------------------------------------

class _TestWidget extends StatefulWidget {
  const _TestWidget({super.key});

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with OnboardingFormStateMixin {
  // Expose mixin for assertions
  _TestWidgetState get self => this;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: const SizedBox.shrink(),
      );

  @override
  void dispose() {
    disposeFormState();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Helper to pump the widget and get the state
// ---------------------------------------------------------------------------

Future<_TestWidgetState> _pumpWidget(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: _TestWidget())),
  );
  return tester.state<_TestWidgetState>(find.byType(_TestWidget));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OnboardingFormStateMixin – validateBusinessName', () {
    testWidgets('should return error when value is null', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateBusinessName(null), isNotNull);
    });

    testWidgets('should return error when value is empty', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateBusinessName(''), isNotNull);
    });

    testWidgets('should return error when value is whitespace only', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateBusinessName('   '), isNotNull);
    });

    testWidgets('should return error when name is fewer than 3 chars', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateBusinessName('AB'), isNotNull);
    });

    testWidgets('should return null when name has exactly 3 chars', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateBusinessName('ABC'), isNull);
    });

    testWidgets('should return null for valid business name', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateBusinessName('Green Transport Co'), isNull);
    });

    testWidgets('should trim before checking length', (tester) async {
      final state = await _pumpWidget(tester);
      // '  AB  ' trims to 'AB' which is < 3 chars
      expect(state.validateBusinessName('  AB  '), isNotNull);
    });
  });

  group('OnboardingFormStateMixin – validateLicenseNumber', () {
    testWidgets('should return error when value is null', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateLicenseNumber(null), isNotNull);
    });

    testWidgets('should return error when value is empty', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateLicenseNumber(''), isNotNull);
    });

    testWidgets('should return error for completely invalid format', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateLicenseNumber('INVALID'), isNotNull);
    });

    testWidgets('should return null for valid Indian DL format', (tester) async {
      final state = await _pumpWidget(tester);
      // Indian DL: 2 letters + 2 digits + 4 alphanumeric + 7 digits
      expect(state.validateLicenseNumber('BR0120190012345'), isNull);
    });

    testWidgets('should be case-insensitive for DL validation', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateLicenseNumber('br0120190012345'), isNull);
    });

    testWidgets('should strip spaces before validating', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.validateLicenseNumber('BR01 20190012345'), isNull);
    });
  });

  group('OnboardingFormStateMixin – validateExperience', () {
    testWidgets('should return error when selectedExperience is null', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedExperience = null;
      expect(state.validateExperience(), isNotNull);
    });

    testWidgets('should return null when selectedExperience is set', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedExperience = 5;
      expect(state.validateExperience(), isNull);
    });
  });

  group('OnboardingFormStateMixin – validateServiceRadius', () {
    testWidgets('should return error when selectedServiceRadius is null', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedServiceRadius = null;
      expect(state.validateServiceRadius(), isNotNull);
    });

    testWidgets('should return null when selectedServiceRadius is set', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedServiceRadius = 100;
      expect(state.validateServiceRadius(), isNull);
    });
  });

  group('OnboardingFormStateMixin – validateLicenseExpiry', () {
    testWidgets('should return error when selectedLicenseExpiry is null', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedLicenseExpiry = null;
      expect(state.validateLicenseExpiry(), isNotNull);
    });

    testWidgets('should return error when license is already expired', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedLicenseExpiry =
          DateTime.now().subtract(const Duration(days: 1));
      expect(state.validateLicenseExpiry(), isNotNull);
    });

    testWidgets('should return error when license expires in less than 3 months', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedLicenseExpiry =
          DateTime.now().add(const Duration(days: 30));
      expect(state.validateLicenseExpiry(), isNotNull);
    });

    testWidgets('should return null when license is valid for 3+ months', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedLicenseExpiry =
          DateTime.now().add(const Duration(days: 120));
      expect(state.validateLicenseExpiry(), isNull);
    });
  });

  group('OnboardingFormStateMixin – validateDrivingLicenseImage', () {
    testWidgets('should return error when imagePath is null', (tester) async {
      final state = await _pumpWidget(tester);
      state.drivingLicenseImagePath = null;
      expect(state.validateDrivingLicenseImage(), isNotNull);
    });

    testWidgets('should return null when imagePath is set', (tester) async {
      final state = await _pumpWidget(tester);
      state.drivingLicenseImagePath = '/path/to/dl.jpg';
      expect(state.validateDrivingLicenseImage(), isNull);
    });
  });

  group('OnboardingFormStateMixin – validateVehicleRcImage', () {
    testWidgets('should return error when rcImagePath is null', (tester) async {
      final state = await _pumpWidget(tester);
      state.vehicleRcImagePath = null;
      expect(state.validateVehicleRcImage(), isNotNull);
    });

    testWidgets('should return null when rcImagePath is set', (tester) async {
      final state = await _pumpWidget(tester);
      state.vehicleRcImagePath = '/path/to/rc.jpg';
      expect(state.validateVehicleRcImage(), isNull);
    });
  });

  group('OnboardingFormStateMixin – getFormData', () {
    testWidgets('should return map with all fields', (tester) async {
      final state = await _pumpWidget(tester);

      state.businessNameController.text = 'Green Transport';
      state.licenseNumberController.text = 'BR0120190012345';
      state.selectedExperience = 5;
      state.selectedServiceRadius = 100;
      state.selectedLicenseExpiry = DateTime(2027, 12, 31);
      state.drivingLicenseImagePath = '/dl.jpg';
      state.vehicleRcImagePath = '/rc.jpg';

      final data = state.getFormData();
      expect(data['businessName'], 'Green Transport');
      expect(data['yearsOfExperience'], 5);
      expect(data['serviceRadiusKm'], 100);
      expect(data['drivingLicenseNumber'], 'BR0120190012345');
      expect(data['drivingLicenseExpiry'], isNotNull);
      expect(data['drivingLicenseImagePath'], '/dl.jpg');
      expect(data['vehicleRcImagePath'], '/rc.jpg');
    });

    testWidgets('should uppercase licenseNumber in getFormData', (tester) async {
      final state = await _pumpWidget(tester);
      state.licenseNumberController.text = 'br0120190012345';
      final data = state.getFormData();
      expect(data['drivingLicenseNumber'], 'BR0120190012345');
    });

    testWidgets('should trim businessName in getFormData', (tester) async {
      final state = await _pumpWidget(tester);
      state.businessNameController.text = '  Transport Co  ';
      final data = state.getFormData();
      expect(data['businessName'], 'Transport Co');
    });
  });

  group('OnboardingFormStateMixin – alias getters', () {
    testWidgets('selectedRadius getter maps to selectedServiceRadius', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedServiceRadius = 75;
      expect(state.selectedRadius, 75);
    });

    testWidgets('selectedRadius setter maps to selectedServiceRadius', (tester) async {
      final state = await _pumpWidget(tester);
      state.selectedRadius = 50;
      expect(state.selectedServiceRadius, 50);
    });

    testWidgets('licenseImagePath getter maps to drivingLicenseImagePath', (tester) async {
      final state = await _pumpWidget(tester);
      state.drivingLicenseImagePath = '/test.jpg';
      expect(state.licenseImagePath, '/test.jpg');
    });

    testWidgets('rcImagePath getter maps to vehicleRcImagePath', (tester) async {
      final state = await _pumpWidget(tester);
      state.vehicleRcImagePath = '/rc.jpg';
      expect(state.rcImagePath, '/rc.jpg');
    });
  });

  group('OnboardingFormStateMixin – constants', () {
    testWidgets('experienceOptions includes expected values', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.experienceOptions, containsAll([1, 5, 10, 20]));
    });

    testWidgets('serviceRadiusOptions includes expected values', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.serviceRadiusOptions, containsAll([25, 50, 100, 200]));
    });
  });

  group('OnboardingFormStateMixin – isSubmitting', () {
    testWidgets('defaults to false', (tester) async {
      final state = await _pumpWidget(tester);
      expect(state.isSubmitting, isFalse);
    });
  });
}
