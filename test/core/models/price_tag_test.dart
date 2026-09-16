import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/price_tag.dart';

void main() {
  group('calculateFinalPrice', () {
    test('applies a percent discount against mrp', () {
      final result = calculateFinalPrice(
        mrp: 200,
        discountType: DiscountType.percent,
        discountValue: 10,
      );
      expect(result, 180);
    });

    test('applies a flat discount by subtraction', () {
      final result = calculateFinalPrice(
        mrp: 200,
        discountType: DiscountType.flat,
        discountValue: 30,
      );
      expect(result, 170);
    });

    test('never goes below zero for a percent discount over 100', () {
      final result = calculateFinalPrice(
        mrp: 100,
        discountType: DiscountType.percent,
        discountValue: 150,
      );
      expect(result, 0);
    });

    test('never goes below zero for a flat discount larger than mrp', () {
      final result = calculateFinalPrice(
        mrp: 50,
        discountType: DiscountType.flat,
        discountValue: 999,
      );
      expect(result, 0);
    });

    test('zero discount returns the original mrp', () {
      final result = calculateFinalPrice(
        mrp: 150,
        discountType: DiscountType.percent,
        discountValue: 0,
      );
      expect(result, 150);
    });
  });

  group('DiscountType.fromJson', () {
    test('parses "flat"', () {
      expect(DiscountType.fromJson('flat'), DiscountType.flat);
    });

    test('parses "percent"', () {
      expect(DiscountType.fromJson('percent'), DiscountType.percent);
    });

    test('defaults to percent for null/unknown values', () {
      expect(DiscountType.fromJson(null), DiscountType.percent);
      expect(DiscountType.fromJson('garbage'), DiscountType.percent);
    });
  });

  group('PriceTag.compute', () {
    test('derives finalPrice from mrp/discountType/discountValue', () {
      final tag = PriceTag.compute(
        productId: 'prod1',
        mrp: 500,
        discountType: DiscountType.percent,
        discountValue: 20,
        branchId: 'branch1',
      );
      expect(tag.finalPrice, 400);
    });
  });

  group('PriceTag JSON round-trip', () {
    test('fromJson/toJson preserve all fields', () {
      final json = {
        'id': 'pt1',
        'product': 'prod1',
        'mrp': 300,
        'discount_type': 'flat',
        'discount_value': 50,
        'final_price': 250,
        'layout': 'compact',
        'branch': 'branch1',
        'staff': 'staff1',
      };
      final tag = PriceTag.fromJson(json);
      expect(tag.id, 'pt1');
      expect(tag.productId, 'prod1');
      expect(tag.mrp, 300);
      expect(tag.discountType, DiscountType.flat);
      expect(tag.discountValue, 50);
      expect(tag.finalPrice, 250);
      expect(tag.layout, 'compact');
      expect(tag.branchId, 'branch1');
      expect(tag.staffId, 'staff1');

      final backToJson = tag.toJson();
      expect(backToJson['product'], 'prod1');
      expect(backToJson['discount_type'], 'flat');
      expect(backToJson['staff'], 'staff1');
    });

    test('missing optional fields fall back to sensible defaults', () {
      final tag = PriceTag.fromJson({'product': 'prod1', 'branch': 'branch1'});
      expect(tag.mrp, 0);
      expect(tag.discountType, DiscountType.percent);
      expect(tag.layout, 'standard');
      expect(tag.staffId, isNull);
    });
  });
}
