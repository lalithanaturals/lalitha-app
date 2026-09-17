import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/audit_register.dart';

void main() {
  group('calculateCashTotal', () {
    test('sums value * count across every denomination', () {
      final total = calculateCashTotal({500: 2, 100: 3, 10: 5});
      expect(total, 1000 + 300 + 50);
    });

    test('returns 0 for an empty count map', () {
      expect(calculateCashTotal({}), 0);
    });
  });

  group('calculateClosingBalance', () {
    test('excludes denominations above 200', () {
      final closing = calculateClosingBalance({500: 4, 200: 2, 100: 1});
      // 500 notes excluded; 200*2 + 100*1 = 500
      expect(closing, 500);
    });

    test('includes 200 itself (boundary is inclusive)', () {
      final closing = calculateClosingBalance({200: 1});
      expect(closing, 200);
    });

    test('all-large-denomination counts yield a zero closing balance', () {
      expect(calculateClosingBalance({500: 10}), 0);
    });
  });

  group('AuditLineCategory', () {
    test('fromJson parses each known value', () {
      expect(AuditLineCategory.fromJson('expense'), AuditLineCategory.expense);
      expect(AuditLineCategory.fromJson('owner_bill'), AuditLineCategory.ownerBill);
      expect(AuditLineCategory.fromJson('vendor_bill'), AuditLineCategory.vendorBill);
      expect(AuditLineCategory.fromJson('unbilled'), AuditLineCategory.unbilled);
    });

    test('fromJson defaults to expense for null/unknown values', () {
      expect(AuditLineCategory.fromJson(null), AuditLineCategory.expense);
      expect(AuditLineCategory.fromJson('garbage'), AuditLineCategory.expense);
    });

    test('toJson round-trips through fromJson for every value', () {
      for (final category in AuditLineCategory.values) {
        expect(AuditLineCategory.fromJson(category.toJson()), category);
      }
    });
  });

  group('AuditRegister JSON', () {
    test('toJson serializes denomination_counts with string keys', () {
      final register = AuditRegister(
        date: DateTime.utc(2026, 9, 17),
        branchId: 'branch1',
        denominationCounts: const {500: 2, 100: 1},
      );
      final json = register.toJson();
      expect(json['denomination_counts'], {'500': 2, '100': 1});
    });

    test('fromJson parses denomination_counts back into int keys', () {
      final register = AuditRegister.fromJson({
        'date': '2026-09-17T00:00:00.000Z',
        'branch': 'branch1',
        'denomination_counts': {'500': 2, '100': 1},
      });
      expect(register.denominationCounts, {500: 2, 100: 1});
    });

    test('fromJson defaults status to draft', () {
      final register = AuditRegister.fromJson({
        'date': '2026-09-17T00:00:00.000Z',
        'branch': 'branch1',
      });
      expect(register.status, AuditRegisterStatus.draft);
    });
  });

  group('AuditLineItem JSON', () {
    test('toJson omits audit_register when not yet assigned', () {
      const item = AuditLineItem(
        category: AuditLineCategory.expense,
        name: 'Electricity',
        amount: 450,
      );
      expect(item.toJson().containsKey('audit_register'), isFalse);
    });
  });
}
