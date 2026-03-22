// test/widget/appointment_card_test.dart
//
// Widget tests for lib/features/appointment/widgets/appointment_card.dart
// Run: flutter test test/widget/appointment_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/appointment/models/appointment_model.dart';
import 'package:flutter_app/features/appointment/widgets/appointment_card.dart';

AppointmentModel _makeAppointment({
  String status = 'REQUESTED',
  String mode = 'in_person',
  String? notes,
  bool withListing = false,
}) {
  return AppointmentModel.fromJson({
    'appointment_id': 1,
    'vet': {
      'vet_id': 10,
      'name': 'Dr. Rajesh Sharma',
      'clinic_name': 'Sharma Animal Clinic',
      'phone': '9876543210',
    },
    'mode': mode,
    'status': status,
    'notes': notes,
    'fee': '300',
    'created_at': '2024-03-01T09:00:00Z',
    'updated_at': '2024-03-01T09:00:00Z',
    if (withListing) 'listing': {'listing_id': 5, 'title': 'Gir Cow for Sale'},
  });
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppointmentCard', () {
    testWidgets('renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(),
      )));
      expect(find.byType(AppointmentCard), findsOneWidget);
    });

    testWidgets('shows vet name', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(),
      )));
      expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    });

    testWidgets('shows clinic name', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(),
      )));
      expect(find.text('Sharma Animal Clinic'), findsOneWidget);
    });

    testWidgets('shows displayStatus text', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(status: 'CONFIRMED'),
      )));
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows Pending for REQUESTED status', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(status: 'REQUESTED'),
      )));
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows fee with ₹ prefix', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(),
      )));
      expect(find.text('₹300'), findsOneWidget);
    });

    testWidgets('shows notes when present', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(notes: 'Cow limping badly'),
      )));
      expect(find.text('Cow limping badly'), findsOneWidget);
    });

    testWidgets('does not show notes section when null', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(notes: null),
      )));
      expect(find.text('Cow limping badly'), findsNothing);
    });

    testWidgets('shows listing title when present', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(withListing: true),
      )));
      expect(find.text('Gir Cow for Sale'), findsOneWidget);
    });

    testWidgets('shows Cancel button for cancellable appointment', (tester) async {
      bool cancelTapped = false;
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(status: 'REQUESTED'),
        onCancelTap: () => cancelTapped = true,
      )));
      await tester.tap(find.text('Cancel'));
      expect(cancelTapped, isTrue);
    });

    testWidgets('shows Chat button for CONFIRMED appointment', (tester) async {
      bool chatTapped = false;
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(status: 'CONFIRMED'),
        onChatTap: () => chatTapped = true,
      )));
      await tester.tap(find.text('Chat'));
      expect(chatTapped, isTrue);
    });

    testWidgets('triggers onTap when card tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(),
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(AppointmentCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows In-Person mode chip', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(mode: 'in_person'),
      )));
      expect(find.text('In-Person'), findsOneWidget);
    });

    testWidgets('shows Video Call mode chip', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(mode: 'video'),
      )));
      expect(find.text('Video Call'), findsOneWidget);
    });

    testWidgets('no ErrorWidget on render', (tester) async {
      await tester.pumpWidget(_wrap(AppointmentCard(
        appointment: _makeAppointment(status: 'COMPLETED'),
      )));
      expect(find.byType(ErrorWidget), findsNothing);
    });
  });
}
