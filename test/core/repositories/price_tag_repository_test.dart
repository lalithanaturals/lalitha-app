import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/models/price_tag.dart';
import 'package:lalitha_app/core/repositories/price_tag_repository.dart';
import 'package:pocketbase/pocketbase.dart';

PocketBase _mockedClient(MockClientHandler handler) {
  return PocketBase(
    'http://mock.local',
    httpClientFactory: () => MockClient(handler),
  );
}

void main() {
  group('PriceTagRepository.listForBranch', () {
    test('sends the expected branch filter and maps results', () async {
      Uri? capturedUri;
      final pb = _mockedClient((request) async {
        capturedUri = request.url;
        final body = jsonEncode({
          'page': 1,
          'perPage': 30,
          'totalItems': 1,
          'totalPages': 1,
          'items': [
            {
              'id': 'pt1',
              'collectionId': 'price_tags',
              'collectionName': 'price_tags',
              'product': 'prod1',
              'mrp': 100,
              'discount_type': 'percent',
              'discount_value': 10,
              'final_price': 90,
              'layout': 'standard',
              'branch': 'branch1',
              'staff': 'staff1',
            },
          ],
        });
        return http.Response(body, 200, headers: {'content-type': 'application/json'});
      });

      final repo = PriceTagRepository(pb);
      final result = await repo.listForBranch('branch1');

      expect(result, hasLength(1));
      expect(result.first.finalPrice, 90);
      expect(capturedUri!.path, '/api/collections/price_tags/records');
      expect(capturedUri!.queryParameters['filter'], 'branch = "branch1"');
    });
  });

  group('PriceTagRepository.create', () {
    test('POSTs the tag payload and returns the created record', () async {
      String? capturedMethod;
      Map<String, dynamic>? capturedBody;
      final pb = _mockedClient((request) async {
        capturedMethod = request.method;
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        final response = {
          'id': 'pt-new',
          'collectionId': 'price_tags',
          'collectionName': 'price_tags',
          ...capturedBody!,
        };
        return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
      });

      final repo = PriceTagRepository(pb);
      final tag = PriceTag.compute(
        productId: 'prod1',
        mrp: 200,
        discountType: DiscountType.flat,
        discountValue: 20,
        branchId: 'branch1',
        staffId: 'staff1',
      );
      final created = await repo.create(tag);

      expect(capturedMethod, 'POST');
      expect(capturedBody!['final_price'], 180);
      expect(created.id, 'pt-new');
      expect(created.finalPrice, 180);
    });
  });

  group('PriceTagRepository.delete', () {
    test('sends a DELETE to the record path', () async {
      String? capturedMethod;
      Uri? capturedUri;
      final pb = _mockedClient((request) async {
        capturedMethod = request.method;
        capturedUri = request.url;
        return http.Response('', 204);
      });

      final repo = PriceTagRepository(pb);
      await repo.delete('pt1');

      expect(capturedMethod, 'DELETE');
      expect(capturedUri!.path, '/api/collections/price_tags/records/pt1');
    });
  });
}
