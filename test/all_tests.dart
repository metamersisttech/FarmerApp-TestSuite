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

// PR #43 Audit Fix tests
import 'unit/audit_fixes/api_config_test.dart' as api_config;
import 'unit/audit_fixes/theme_notifier_test.dart' as theme_notifier;
import 'unit/audit_fixes/route_guard_test.dart' as route_guard;
import 'unit/audit_fixes/api_error_handling_test.dart' as api_error_handling;
import 'unit/audit_fixes/image_compress_helper_test.dart' as image_compress;
import 'unit/audit_fixes/localization_test.dart' as localization;
import 'widget/audit_fixes/route_guard_widget_test.dart' as route_guard_widget;
import 'widget/audit_fixes/my_app_widget_test.dart' as my_app_widget;

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

  // PR #43 Audit Fix tests
  api_config.main();
  theme_notifier.main();
  route_guard.main();
  api_error_handling.main();
  image_compress.main();
  localization.main();
  route_guard_widget.main();
  my_app_widget.main();
}
