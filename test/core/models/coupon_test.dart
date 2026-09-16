import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/coupon.dart';

void main() {
  group('Coupon.markRedeemed', () {
    test('flips redeemed to true and stamps redeemedAt', () {
      const coupon = Coupon(
        couponType: 'festival',
        branchId: 'branch1',
        discountValue: 10,
      );
      final redeemedAt = DateTime(2026, 9, 16);
      final redeemed = coupon.markRedeemed(at: redeemedAt);

      expect(redeemed.redeemed, isTrue);
      expect(redeemed.redeemedAt, redeemedAt);
      // original is untouched (immutability)
      expect(coupon.redeemed, isFalse);
    });
  });

  group('Coupon JSON', () {
    test('round-trips redeemed_at as ISO8601', () {
      final redeemedAt = DateTime.utc(2026, 1, 5, 10, 30);
      final coupon = Coupon(
        couponType: 'festival',
        branchId: 'branch1',
        discountValue: 20,
        redeemed: true,
        redeemedAt: redeemedAt,
      );
      final json = coupon.toJson();
      expect(json['redeemed_at'], redeemedAt.toIso8601String());

      final parsed = Coupon.fromJson({...json, 'id': 'c1'});
      expect(parsed.redeemedAt, redeemedAt);
      expect(parsed.redeemed, isTrue);
    });

    test('fromJson treats an empty redeemed_at string as null', () {
      final coupon = Coupon.fromJson({
        'coupon_type': 'x',
        'branch': 'b1',
        'discount_value': 5,
        'redeemed': false,
        'redeemed_at': '',
      });
      expect(coupon.redeemedAt, isNull);
    });
  });
}
