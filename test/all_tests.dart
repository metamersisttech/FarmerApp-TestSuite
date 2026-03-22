// test/all_tests.dart
//
// Aggregated test runner — imports all unit and widget test files.
// Run: flutter test test/all_tests.dart
//
// Individual suites can still be run independently:
//   flutter test test/unit/validators_test.dart
//   flutter test test/widget/bid_card_test.dart

// Unit tests
import 'unit/validators_test.dart' as validators;
import 'unit/user_model_test.dart' as user_model;
import 'unit/animal_model_test.dart' as animal_model;
import 'unit/appointment_model_test.dart' as appointment_model;
import 'unit/bid_model_test.dart' as bid_model;
import 'unit/base_controller_test.dart' as base_controller;

// Widget tests
import 'widget/appointment_card_test.dart' as appointment_card;
import 'widget/bid_card_test.dart' as bid_card;
import 'widget/otp_input_widget_test.dart' as otp_input;

void main() {
  validators.main();
  user_model.main();
  animal_model.main();
  appointment_model.main();
  bid_model.main();
  base_controller.main();
  appointment_card.main();
  bid_card.main();
  otp_input.main();
}
