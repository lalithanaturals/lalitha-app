import 'package:pocketbase/pocketbase.dart';

import '../models/coupon.dart';

class CouponRepository {
  CouponRepository(this._pb);

  final PocketBase _pb;

  Future<Coupon> issue(Coupon coupon) async {
    final record = await _pb.collection('coupons').create(body: coupon.toJson());
    return Coupon.fromJson(record.toJson());
  }

  Future<Coupon> redeem(String id, {DateTime? at}) async {
    final record = await _pb.collection('coupons').update(
          id,
          body: {
            'redeemed': true,
            'redeemed_at': (at ?? DateTime.now()).toIso8601String(),
          },
        );
    return Coupon.fromJson(record.toJson());
  }
}
