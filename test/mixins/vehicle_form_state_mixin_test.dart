import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/mixins/vehicle_form_state_mixin.dart';
import 'package:flutter_app/features/transport/models/vehicle_model.dart';

// ---------------------------------------------------------------------------
// Test harness
// ---------------------------------------------------------------------------

class _TestWidget extends StatefulWidget {
  const _TestWidget({super.key});

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> with VehicleFormStateMixin {
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

Future<_TestWidgetState> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: _TestWidget())),
  );
  return tester.state<_TestWidgetState>(find.byType(_TestWidget));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VehicleFormStateMixin – validateRegistration', () {
    testWidgets('should return error when value is null', (tester) async {
      final s = await _pump(tester);
      expect(s.validateRegistration(null), isNotNull);
    });

    testWidgets('should return error when value is empty', (tester) async {
      final s = await _pump(tester);
      expect(s.validateRegistration(''), isNotNull);
    });

    testWidgets('should return error for invalid format', (tester) async {
      final s = await _pump(tester);
      expect(s.validateRegistration('INVALID'), isNotNull);
    });

    testWidgets('should return null for valid registration MH12AB1234', (tester) async {
      final s = await _pump(tester);
      expect(s.validateRegistration('MH12AB1234'), isNull);
    });

    testWidgets('should be case-insensitive', (tester) async {
      final s = await _pump(tester);
      expect(s.validateRegistration('mh12ab1234'), isNull);
    });

    testWidgets('should strip spaces before validating', (tester) async {
      final s = await _pump(tester);
      expect(s.validateRegistration('MH 12 AB 1234'), isNull);
    });

    testWidgets('should return null for registration with single-letter zone suffix', (tester) async {
      final s = await _pump(tester);
      // e.g. BR01A1234
      expect(s.validateRegistration('BR01A1234'), isNull);
    });
  });

  group('VehicleFormStateMixin – validateMake', () {
    testWidgets('should return error when null', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMake(null), isNotNull);
    });

    testWidgets('should return error when empty', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMake(''), isNotNull);
    });

    testWidgets('should return error when single character', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMake('T'), isNotNull);
    });

    testWidgets('should return null for make with 2+ characters', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMake('Tata'), isNull);
    });

    testWidgets('should return null for exactly 2 characters', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMake('MG'), isNull);
    });
  });

  group('VehicleFormStateMixin – validateModel', () {
    testWidgets('should return error when null', (tester) async {
      final s = await _pump(tester);
      expect(s.validateModel(null), isNotNull);
    });

    testWidgets('should return error when empty', (tester) async {
      final s = await _pump(tester);
      expect(s.validateModel(''), isNotNull);
    });

    testWidgets('should return null for non-empty model', (tester) async {
      final s = await _pump(tester);
      expect(s.validateModel('Ace HT'), isNull);
    });
  });

  group('VehicleFormStateMixin – validateMaxWeight', () {
    testWidgets('should return error when null', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight(null), isNotNull);
    });

    testWidgets('should return error when empty', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight(''), isNotNull);
    });

    testWidgets('should return error for non-numeric string', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('abc'), isNotNull);
    });

    testWidgets('should return error for zero weight', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('0'), isNotNull);
    });

    testWidgets('should return error for negative weight', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('-100'), isNotNull);
    });

    testWidgets('should return error when weight less than 100 kg', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('50'), isNotNull);
    });

    testWidgets('should return null for exactly 100 kg', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('100'), isNull);
    });

    testWidgets('should return null for valid weight 1000 kg', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('1000'), isNull);
    });

    testWidgets('should return error for weight exceeding 50000 kg', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('60000'), isNotNull);
    });

    testWidgets('should return null for weight at upper boundary 50000 kg', (tester) async {
      final s = await _pump(tester);
      expect(s.validateMaxWeight('50000'), isNull);
    });
  });

  group('VehicleFormStateMixin – validateDimension', () {
    testWidgets('should return null when value is null (optional field)', (tester) async {
      final s = await _pump(tester);
      expect(s.validateDimension(null), isNull);
    });

    testWidgets('should return null when value is empty (optional field)', (tester) async {
      final s = await _pump(tester);
      expect(s.validateDimension(''), isNull);
    });

    testWidgets('should return error for non-numeric dimension', (tester) async {
      final s = await _pump(tester);
      expect(s.validateDimension('abc'), isNotNull);
    });

    testWidgets('should return error for zero dimension', (tester) async {
      final s = await _pump(tester);
      expect(s.validateDimension('0'), isNotNull);
    });

    testWidgets('should return null for valid dimension', (tester) async {
      final s = await _pump(tester);
      expect(s.validateDimension('200'), isNull);
    });
  });

  group('VehicleFormStateMixin – validateVehicleType', () {
    testWidgets('should return error when vehicleType is null', (tester) async {
      final s = await _pump(tester);
      s.selectedVehicleType = null;
      expect(s.validateVehicleType(), isNotNull);
    });

    testWidgets('should return null when vehicleType is set', (tester) async {
      final s = await _pump(tester);
      s.selectedVehicleType = VehicleType.truck;
      expect(s.validateVehicleType(), isNull);
    });
  });

  group('VehicleFormStateMixin – validateRcDocument', () {
    testWidgets('should require RC document for new vehicles', (tester) async {
      final s = await _pump(tester);
      s.isEdit = false;
      s.rcDocumentPath = null;
      expect(s.validateRcDocument(), isNotNull);
    });

    testWidgets('should not require RC document for edit mode', (tester) async {
      final s = await _pump(tester);
      s.isEdit = true;
      s.rcDocumentPath = null;
      expect(s.validateRcDocument(), isNull);
    });

    testWidgets('should return null when RC path is set for new vehicle', (tester) async {
      final s = await _pump(tester);
      s.isEdit = false;
      s.rcDocumentPath = '/documents/rc.pdf';
      expect(s.validateRcDocument(), isNull);
    });
  });

  group('VehicleFormStateMixin – validateInsuranceDocument', () {
    testWidgets('should require insurance for new vehicles', (tester) async {
      final s = await _pump(tester);
      s.isEdit = false;
      s.insuranceDocumentPath = null;
      expect(s.validateInsuranceDocument(), isNotNull);
    });

    testWidgets('should not require insurance for edit mode', (tester) async {
      final s = await _pump(tester);
      s.isEdit = true;
      s.insuranceDocumentPath = null;
      expect(s.validateInsuranceDocument(), isNull);
    });
  });

  group('VehicleFormStateMixin – image management', () {
    testWidgets('addVehicleImage should add a path to the list', (tester) async {
      final s = await _pump(tester);
      s.addVehicleImage('/img1.jpg');
      expect(s.vehicleImagePaths, contains('/img1.jpg'));
    });

    testWidgets('addVehicleImage should not exceed 5 images', (tester) async {
      final s = await _pump(tester);
      for (var i = 0; i < 6; i++) {
        s.addVehicleImage('/img$i.jpg');
      }
      expect(s.vehicleImagePaths.length, 5);
    });

    testWidgets('removeVehicleImage should remove by index', (tester) async {
      final s = await _pump(tester);
      s.addVehicleImage('/img1.jpg');
      s.addVehicleImage('/img2.jpg');
      s.removeVehicleImage(0);
      expect(s.vehicleImagePaths, ['/img2.jpg']);
    });

    testWidgets('removeVehicleImage does nothing for out-of-range index', (tester) async {
      final s = await _pump(tester);
      s.addVehicleImage('/img1.jpg');
      s.removeVehicleImage(99); // Should not throw
      expect(s.vehicleImagePaths.length, 1);
    });

    testWidgets('clearVehicleImages empties the list', (tester) async {
      final s = await _pump(tester);
      s.addVehicleImage('/img1.jpg');
      s.addVehicleImage('/img2.jpg');
      s.clearVehicleImages();
      expect(s.vehicleImagePaths, isEmpty);
    });
  });

  group('VehicleFormStateMixin – getFormData', () {
    testWidgets('should return map with all filled fields', (tester) async {
      final s = await _pump(tester);
      s.registrationController.text = 'MH12AB1234';
      s.makeController.text = 'Tata';
      s.modelController.text = 'Ace HT';
      s.maxWeightController.text = '800';
      s.selectedVehicleType = VehicleType.miniTruck;
      s.selectedYear = 2022;
      s.rcDocumentPath = '/rc.pdf';
      s.insuranceDocumentPath = '/ins.pdf';

      final data = s.getFormData();
      expect(data['registrationNumber'], 'MH12AB1234');
      expect(data['make'], 'Tata');
      expect(data['model'], 'Ace HT');
      expect(data['maxWeightKg'], 800.0);
      expect(data['vehicleType'], VehicleType.miniTruck.value);
      expect(data['year'], 2022);
      expect(data['rcDocumentPath'], '/rc.pdf');
      expect(data['insuranceDocumentPath'], '/ins.pdf');
    });

    testWidgets('should uppercase registration number in getFormData', (tester) async {
      final s = await _pump(tester);
      s.registrationController.text = 'mh12ab1234';
      final data = s.getFormData();
      expect(data['registrationNumber'], 'MH12AB1234');
    });

    testWidgets('should return null for maxWeightKg when field empty', (tester) async {
      final s = await _pump(tester);
      s.maxWeightController.text = '';
      final data = s.getFormData();
      expect(data['maxWeightKg'], isNull);
    });
  });

  group('VehicleFormStateMixin – yearOptions', () {
    testWidgets('should contain current year', (tester) async {
      final s = await _pump(tester);
      expect(s.yearOptions, contains(DateTime.now().year));
    });

    testWidgets('should contain 25 year options', (tester) async {
      final s = await _pump(tester);
      expect(s.yearOptions.length, 25);
    });

    testWidgets('first option should be current year', (tester) async {
      final s = await _pump(tester);
      expect(s.yearOptions.first, DateTime.now().year);
    });
  });

  group('VehicleFormStateMixin – vehicleTypeOptions', () {
    testWidgets('should return all VehicleType values', (tester) async {
      final s = await _pump(tester);
      expect(s.vehicleTypeOptions, containsAll(VehicleType.values));
    });
  });

  group('VehicleFormStateMixin – alias controllers', () {
    testWidgets('lengthController maps to maxLengthController', (tester) async {
      final s = await _pump(tester);
      s.maxLengthController.text = '500';
      expect(s.lengthController.text, '500');
    });

    testWidgets('widthController maps to maxWidthController', (tester) async {
      final s = await _pump(tester);
      s.maxWidthController.text = '200';
      expect(s.widthController.text, '200');
    });

    testWidgets('heightController maps to maxHeightController', (tester) async {
      final s = await _pump(tester);
      s.maxHeightController.text = '180';
      expect(s.heightController.text, '180');
    });
  });

  group('VehicleFormStateMixin – initForEdit', () {
    testWidgets('should populate controllers from vehicle model', (tester) async {
      final s = await _pump(tester);
      final vehicle = VehicleModel(
        vehicleId: 7,
        vehicleType: 'TRUCK',
        registrationNumber: 'MH12AB1234',
        make: 'Tata',
        model: 'Prima',
        year: 2020,
        maxWeightKg: 5000.0,
        maxLengthCm: 600.0,
        maxWidthCm: 250.0,
        maxHeightCm: 300.0,
        createdAt: DateTime.now(),
      );

      s.initForEdit(vehicle);
      await tester.pump();

      expect(s.isEdit, isTrue);
      expect(s.editingVehicleId, 7);
      expect(s.registrationController.text, 'MH12AB1234');
      expect(s.makeController.text, 'Tata');
      expect(s.modelController.text, 'Prima');
      expect(s.selectedYear, 2020);
      expect(s.selectedVehicleType, VehicleType.truck);
      expect(s.maxWeightController.text, '5000');
      expect(s.maxLengthController.text, '600');
      expect(s.maxWidthController.text, '250');
      expect(s.maxHeightController.text, '300');
    });

    testWidgets('should not set dimension controllers when dimensions are null', (tester) async {
      final s = await _pump(tester);
      final vehicle = VehicleModel(
        vehicleId: 1,
        vehicleType: 'PICKUP',
        registrationNumber: 'DL01AB1234',
        make: 'Maruti',
        model: 'Super Carry',
        maxWeightKg: 500.0,
        createdAt: DateTime.now(),
      );

      s.initForEdit(vehicle);
      await tester.pump();

      expect(s.maxLengthController.text, '');
      expect(s.maxWidthController.text, '');
      expect(s.maxHeightController.text, '');
    });
  });
}
