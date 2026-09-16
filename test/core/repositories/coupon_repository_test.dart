import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/repositories/coupon_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('CouponRepository.redeem', () {
    test('PATCHes only redeemed/redeemed_at and returns the updated coupon', () async {
      String? capturedMethod;
      Map<String, dynamic>? capturedBody;
      Uri? capturedUri;

      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedMethod = request.method;
          capturedUri = request.url;
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'coupon1',
            'collectionId': 'coupons',
            'collectionName': 'coupons',
            'coupon_type': 'festival',
            'branch': 'branch1',
            'discount_value': 15,
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = CouponRepository(pb);
      final at = DateTime.utc(2026, 9, 16, 12);
      final result = await repo.redeem('coupon1', at: at);

      expect(capturedMethod, 'PATCH');
      expect(capturedUri!.path, '/api/collections/coupons/records/coupon1');
      expect(capturedBody!['redeemed'], true);
      expect(capturedBody!['redeemed_at'], at.toIso8601String());
      expect(capturedBody!.containsKey('coupon_type'), isFalse,
          reason: 'redeem should only send the fields that changed');
      expect(result.redeemed, isTrue);
    });
  });
}
