// test/unit/bid_model_test.dart
//
// Unit tests for lib/features/bidding/models/bid_model.dart
// Run: flutter test test/unit/bid_model_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/bidding/models/bid_model.dart';

Map<String, dynamic> _baseJson({String status = 'PENDING'}) => {
  'bid_id': 1,
  'listing_id': 10,
  'actual_price': 50000,
  'bid_price': 45000,
  'status': status,
  'created_at': '2024-03-01',
  'updated_at': '2024-03-01',
};

void main() {
  // ── fromJson ──────────────────────────────────────────────────────────────
  group('BidModel.fromJson', () {
    test('parses required fields', () {
      final model = BidModel.fromJson(_baseJson());
      expect(model.id, 1);
      expect(model.listingId, 10);
      expect(model.actualPrice, 50000.0);
      expect(model.bidPrice, 45000.0);
      expect(model.status, 'PENDING');
    });

    test('uses "id" key when "bid_id" absent', () {
      final json = {
        'id': 99,
        'listing_id': 5,
        'actual_price': 10000,
        'bid_price': 9000,
        'status': 'PENDING',
        'created_at': '',
        'updated_at': '',
      };
      expect(BidModel.fromJson(json).id, 99);
    });

    test('parses string price values', () {
      final json = _baseJson()
        ..['actual_price'] = '75000.50'
        ..['bid_price'] = '70000.00';
      final model = BidModel.fromJson(json);
      expect(model.actualPrice, closeTo(75000.50, 0.001));
      expect(model.bidPrice, 70000.0);
    });

    test('handles null price as 0.0', () {
      final json = _baseJson()
        ..remove('actual_price');
      final model = BidModel.fromJson(json);
      expect(model.actualPrice, 0.0);
    });

    test('parses flat bidder id', () {
      final json = _baseJson()..['bidder'] = 7;
      expect(BidModel.fromJson(json).bidderId, 7);
    });

    test('parses nested bidder object', () {
      final json = _baseJson()..['bidder'] = {'id': 15, 'username': 'buyer1'};
      final model = BidModel.fromJson(json);
      expect(model.bidderId, 15);
      expect(model.bidder?.username, 'buyer1');
    });

    test('parses listing_info', () {
      final json = _baseJson()..['listing_info'] = {
        'listing_id': 10,
        'title': 'Gir Cow',
        'price': '50000',
        'listing_status': 'ACTIVE',
      };
      final model = BidModel.fromJson(json);
      expect(model.listingInfo?.title, 'Gir Cow');
    });
  });

  // ── Status computed helpers ───────────────────────────────────────────────
  group('Status helpers', () {
    test('isPending', () {
      expect(BidModel.fromJson(_baseJson(status: 'PENDING')).isPending, isTrue);
      expect(BidModel.fromJson(_baseJson(status: 'APPROVED')).isPending, isFalse);
    });

    test('isApproved', () {
      expect(BidModel.fromJson(_baseJson(status: 'APPROVED')).isApproved, isTrue);
      expect(BidModel.fromJson(_baseJson(status: 'PENDING')).isApproved, isFalse);
    });

    test('isRejected', () {
      expect(BidModel.fromJson(_baseJson(status: 'REJECTED')).isRejected, isTrue);
    });

    test('isCancelled', () {
      expect(BidModel.fromJson(_baseJson(status: 'CANCELLED')).isCancelled, isTrue);
    });
  });

  // ── Formatted price getters ───────────────────────────────────────────────
  group('Formatted prices', () {
    test('formattedBidPrice has ₹ prefix', () {
      final model = BidModel.fromJson(_baseJson());
      expect(model.formattedBidPrice, startsWith('₹'));
      expect(model.formattedBidPrice, contains('45000'));
    });

    test('formattedActualPrice has ₹ prefix', () {
      final model = BidModel.fromJson(_baseJson());
      expect(model.formattedActualPrice, startsWith('₹'));
      expect(model.formattedActualPrice, contains('50000'));
    });
  });

  // ── statusDisplay ─────────────────────────────────────────────────────────
  group('BidModel.statusDisplay', () {
    final cases = {
      'PENDING': 'Pending',
      'APPROVED': 'Approved',
      'REJECTED': 'Rejected',
      'CANCELLED': 'Cancelled',
    };

    cases.forEach((status, expected) {
      test('$status → "$expected"', () {
        expect(BidModel.fromJson(_baseJson(status: status)).statusDisplay, expected);
      });
    });

    test('unknown status returns raw value', () {
      expect(BidModel.fromJson(_baseJson(status: 'UNKNOWN')).statusDisplay, 'UNKNOWN');
    });
  });

  // ── statusColor ───────────────────────────────────────────────────────────
  group('BidModel.statusColor', () {
    test('PENDING → orange', () {
      expect(BidModel.fromJson(_baseJson(status: 'PENDING')).statusColor, Colors.orange);
    });

    test('APPROVED → green', () {
      expect(BidModel.fromJson(_baseJson(status: 'APPROVED')).statusColor, Colors.green);
    });

    test('REJECTED → red', () {
      expect(BidModel.fromJson(_baseJson(status: 'REJECTED')).statusColor, Colors.red);
    });

    test('CANCELLED → grey', () {
      expect(BidModel.fromJson(_baseJson(status: 'CANCELLED')).statusColor, Colors.grey);
    });
  });

  // ── BidBidderInfo.displayName ─────────────────────────────────────────────
  group('BidBidderInfo.displayName', () {
    test('prefers fullName over username', () {
      final bidder = BidBidderInfo.fromJson({
        'id': 1,
        'username': 'user1',
        'full_name': 'Full Name',
      });
      expect(bidder.displayName, 'Full Name');
    });

    test('falls back to username when no fullName', () {
      final bidder = BidBidderInfo.fromJson({'id': 1, 'username': 'user1'});
      expect(bidder.displayName, 'user1');
    });
  });
}
