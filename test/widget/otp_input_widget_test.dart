// test/widget/otp_input_widget_test.dart
//
// Widget tests for lib/features/auth/widgets/otp_input_widget.dart
// Run: flutter test test/widget/otp_input_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/auth/widgets/otp_input_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('OtpInputWidget', () {
    testWidgets('renders 6 text fields by default', (tester) async {
      await tester.pumpWidget(_wrap(OtpInputWidget(
        onCompleted: (_) {},
        onChanged: (_) {},
      )));
      // Each OTP box is a TextFormField inside SizedBox(width:45)
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('renders custom length fields', (tester) async {
      await tester.pumpWidget(_wrap(OtpInputWidget(
        length: 4,
        onCompleted: (_) {},
        onChanged: (_) {},
      )));
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('no ErrorWidget on render', (tester) async {
      await tester.pumpWidget(_wrap(OtpInputWidget(
        onCompleted: (_) {},
        onChanged: (_) {},
      )));
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('disabled fields when enabled=false', (tester) async {
      await tester.pumpWidget(_wrap(OtpInputWidget(
        enabled: false,
        onCompleted: (_) {},
        onChanged: (_) {},
      )));
      // All TextFormField widgets should be disabled
      final fields = tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
      for (final field in fields) {
        expect(field.enabled, isFalse);
      }
    });

    testWidgets('entering digit in first field calls onChanged', (tester) async {
      String changedValue = '';
      await tester.pumpWidget(_wrap(OtpInputWidget(
        onCompleted: (_) {},
        onChanged: (v) => changedValue = v,
      )));

      final firstField = find.byType(TextFormField).first;
      await tester.tap(firstField);
      await tester.enterText(firstField, '1');
      await tester.pump();

      expect(changedValue, isNotEmpty);
    });

    testWidgets('onCompleted fires when all fields filled', (tester) async {
      String completedOtp = '';
      await tester.pumpWidget(_wrap(OtpInputWidget(
        length: 4,
        onCompleted: (v) => completedOtp = v,
        onChanged: (_) {},
      )));

      final fields = find.byType(TextFormField);
      final digits = ['1', '2', '3', '4'];

      for (int i = 0; i < 4; i++) {
        await tester.tap(fields.at(i));
        await tester.enterText(fields.at(i), digits[i]);
        await tester.pump();
      }

      expect(completedOtp, '1234');
    });

    testWidgets('renders in a Row layout', (tester) async {
      await tester.pumpWidget(_wrap(OtpInputWidget(
        onCompleted: (_) {},
        onChanged: (_) {},
      )));
      expect(find.byType(Row), findsWidgets);
    });
  });
}
