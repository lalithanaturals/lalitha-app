import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/exchange_record.dart';

void main() {
  group('calculateMaterialTotals', () {
    test('gross weight is the sum of entered weights', () {
      final totals = calculateMaterialTotals(weights: [2.5, 3.0, 1.5], handles: 0, ratePerKg: 100);
      expect(totals.grossWeightKg, 7.0);
    });

    test('deducts 0.10kg per handle before pricing', () {
      final totals = calculateMaterialTotals(weights: [10], handles: 3, ratePerKg: 150);
      expect(totals.handlesDeductionKg, closeTo(0.3, 1e-9));
      expect(totals.netWeightKg, closeTo(9.7, 1e-9));
      expect(totals.cost, closeTo(1455, 1e-9));
    });

    test('net weight never goes negative', () {
      final totals = calculateMaterialTotals(weights: [0.05], handles: 10, ratePerKg: 50);
      expect(totals.netWeightKg, 0);
      expect(totals.cost, 0);
    });

    test('zero weights and handles yields all zeros', () {
      final totals = calculateMaterialTotals(weights: [], handles: 0, ratePerKg: 150);
      expect(totals.grossWeightKg, 0);
      expect(totals.netWeightKg, 0);
      expect(totals.cost, 0);
    });
  });

  group('ExchangeRecord aggregate totals', () {
    test('combines aluminum and steel at their own rates', () {
      const record = ExchangeRecord(
        branchId: 'branch1',
        alWeights: [10],
        alHandles: 0,
        stWeights: [20],
        stHandles: 0,
      );
      // al: 10kg * ₹150 = 1500; st: 20kg * ₹50 = 1000
      expect(record.alTotals.cost, 1500);
      expect(record.stTotals.cost, 1000);
      expect(record.netTotalAmount, 2500);
      expect(record.grossTotalKg, 30);
    });
  });

  group('ExchangeStatus', () {
    test('fromJson parses order and defaults everything else to estimate', () {
      expect(ExchangeStatus.fromJson('order'), ExchangeStatus.order);
      expect(ExchangeStatus.fromJson('estimate'), ExchangeStatus.estimate);
      expect(ExchangeStatus.fromJson(null), ExchangeStatus.estimate);
      expect(ExchangeStatus.fromJson('garbage'), ExchangeStatus.estimate);
    });
  });

  group('ExchangeRecord JSON', () {
    test('toJson includes computed gross/handles/net totals', () {
      const record = ExchangeRecord(
        branchId: 'branch1',
        alWeights: [10],
        alHandles: 2,
      );
      final json = record.toJson();
      expect(json['al_weights'], [10]);
      expect(json['gross_total'], 10);
      expect(json['handles_deduction'], closeTo(0.2, 1e-9));
      expect(json['net_total'], closeTo(1470, 1e-9)); // (10 - 0.2) * 150
    });

    test('fromJson defaults customerName to Walk-in Customer when blank', () {
      final record = ExchangeRecord.fromJson({'branch': 'branch1', 'customer_name': ''});
      expect(record.customerName, 'Walk-in Customer');
    });

    test('fromJson preserves display_id', () {
      final record = ExchangeRecord.fromJson({'branch': 'branch1', 'display_id': 'EX-42'});
      expect(record.displayId, 'EX-42');
    });
  });
}
