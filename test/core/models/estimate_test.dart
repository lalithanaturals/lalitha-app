import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/estimate.dart';

void main() {
  group('EstimateItem.lineTotal', () {
    test('multiplies quantity by unit price', () {
      const item = EstimateItem(itemName: 'Soap', quantity: 3, unitPrice: 40);
      expect(item.lineTotal, 120);
    });

    test('supports fractional quantities', () {
      const item = EstimateItem(itemName: 'Jaggery (kg)', quantity: 1.5, unitPrice: 100);
      expect(item.lineTotal, 150);
    });
  });

  group('calculateEstimateTotal', () {
    test('sums line totals across items', () {
      const items = [
        EstimateItem(itemName: 'A', quantity: 2, unitPrice: 50),
        EstimateItem(itemName: 'B', quantity: 1, unitPrice: 75),
        EstimateItem(itemName: 'C', quantity: 3, unitPrice: 10),
      ];
      expect(calculateEstimateTotal(items), 205);
    });

    test('returns 0 for an empty item list', () {
      expect(calculateEstimateTotal(const []), 0);
    });
  });

  group('Estimate.totalAmount', () {
    test('reflects the sum of its items', () {
      const estimate = Estimate(
        branchId: 'branch1',
        items: [
          EstimateItem(itemName: 'A', quantity: 2, unitPrice: 50),
          EstimateItem(itemName: 'B', quantity: 1, unitPrice: 25),
        ],
      );
      expect(estimate.totalAmount, 125);
    });

    test('defaults customerName to Walk-in Customer', () {
      const estimate = Estimate(branchId: 'branch1');
      expect(estimate.customerName, 'Walk-in Customer');
    });
  });

  group('EstimateItem JSON', () {
    test('toJson includes a computed line_total', () {
      const item = EstimateItem(estimateId: 'est1', itemName: 'X', quantity: 4, unitPrice: 25);
      final json = item.toJson();
      expect(json['line_total'], 100);
      expect(json['estimate'], 'est1');
    });

    test('fromJson parses required fields with quantity defaulting to 1', () {
      final item = EstimateItem.fromJson({'item_name': 'Y', 'unit_price': 60});
      expect(item.quantity, 1);
      expect(item.lineTotal, 60);
    });
  });
}
