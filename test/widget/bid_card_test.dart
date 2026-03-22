// test/widget/bid_card_test.dart
//
// Widget tests for lib/features/bidding/widgets/bid_card.dart
// Run: flutter test test/widget/bid_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/bidding/models/bid_model.dart';
import 'package:flutter_app/features/bidding/widgets/bid_card.dart';

BidModel _makeBid({
  String status = 'PENDING',
  String? message,
  bool withListingInfo = false,
  bool withBidderInfo = false,
}) {
  return BidModel.fromJson({
    'bid_id': 1,
    'listing_id': 10,
    'actual_price': 50000,
    'bid_price': 45000,
    'status': status,
    'message': message,
    'created_at': '2024-03-01T09:00:00Z',
    'updated_at': '2024-03-01T09:00:00Z',
    if (withListingInfo)
      'listing_info': {
        'listing_id': 10,
        'title': 'HF Cow',
        'price': '50000',
        'listing_status': 'ACTIVE',
        'seller_name': 'Ramesh Farm',
      },
    if (withBidderInfo)
      'bidder_info': {
        'id': 20,
        'username': 'buyer_user',
        'full_name': 'Suresh Kumar',
        'is_verified': true,
      },
  });
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BidCard', () {
    testWidgets('renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(bid: _makeBid())));
      expect(find.byType(BidCard), findsOneWidget);
    });

    testWidgets('shows bid price with ₹', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(bid: _makeBid())));
      expect(find.text('₹45000'), findsOneWidget);
    });

    testWidgets('shows actual price reference', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(bid: _makeBid())));
      expect(find.textContaining('₹50000'), findsOneWidget);
    });

    testWidgets('shows status badge text', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(bid: _makeBid(status: 'PENDING'))));
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows APPROVED status', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(bid: _makeBid(status: 'APPROVED'))));
      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(message: 'Can you reduce price a bit?'),
      )));
      expect(find.text('Can you reduce price a bit?'), findsOneWidget);
    });

    testWidgets('does not show message section when null', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(bid: _makeBid(message: null))));
      expect(find.textContaining('Can you'), findsNothing);
    });

    testWidgets('shows listing info when showListingInfo=true', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(withListingInfo: true),
        showListingInfo: true,
      )));
      expect(find.text('HF Cow'), findsOneWidget);
      expect(find.text('Ramesh Farm'), findsOneWidget);
    });

    testWidgets('hides listing info when showListingInfo=false', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(withListingInfo: true),
        showListingInfo: false,
      )));
      expect(find.text('HF Cow'), findsNothing);
    });

    testWidgets('shows buyer info when showBuyerInfo=true', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(withBidderInfo: true),
        showBuyerInfo: true,
      )));
      expect(find.text('Suresh Kumar'), findsOneWidget);
    });

    testWidgets('shows Approve and Reject buttons when callbacks provided', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(),
        onApproveTap: () {},
        onRejectTap: () {},
      )));
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('triggers onApproveTap callback', (tester) async {
      bool approved = false;
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(),
        onApproveTap: () => approved = true,
      )));
      await tester.tap(find.text('Approve'));
      expect(approved, isTrue);
    });

    testWidgets('triggers onRejectTap callback', (tester) async {
      bool rejected = false;
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(),
        onRejectTap: () => rejected = true,
      )));
      await tester.tap(find.text('Reject'));
      expect(rejected, isTrue);
    });

    testWidgets('triggers onCancelTap for Cancel Bid', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(),
        onCancelTap: () => cancelled = true,
      )));
      await tester.tap(find.text('Cancel Bid'));
      expect(cancelled, isTrue);
    });

    testWidgets('triggers onTap when card body tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(),
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('₹45000'));
      expect(tapped, isTrue);
    });

    testWidgets('no ErrorWidget rendered', (tester) async {
      await tester.pumpWidget(_wrap(BidCard(
        bid: _makeBid(status: 'APPROVED', withListingInfo: true),
        showListingInfo: true,
      )));
      expect(find.byType(ErrorWidget), findsNothing);
    });
  });
}
