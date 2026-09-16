import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/models/estimate.dart';
import 'package:lalitha_app/core/repositories/estimate_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('EstimateRepository.create', () {
    test('creates the estimate then each item, tagged with the new estimate id', () async {
      final requests = <http.Request>[];
      var estimateCounter = 0;
      var itemCounter = 0;

      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          requests.add(request);
          final body = jsonDecode(request.body) as Map<String, dynamic>;

          if (request.url.path == '/api/collections/estimates/records') {
            estimateCounter++;
            final response = {
              'id': 'est-$estimateCounter',
              'collectionId': 'estimates',
              'collectionName': 'estimates',
              ...body,
            };
            return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
          }

          if (request.url.path == '/api/collections/estimate_items/records') {
            itemCounter++;
            final response = {
              'id': 'item-$itemCounter',
              'collectionId': 'estimate_items',
              'collectionName': 'estimate_items',
              ...body,
            };
            return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
          }

          return http.Response('not found', 404);
        }),
      );

      final repo = EstimateRepository(pb);
      final estimate = const Estimate(
        branchId: 'branch1',
        customerName: 'Ravi Kumar',
        items: [
          EstimateItem(itemName: 'Ghee 500ml', quantity: 2, unitPrice: 350),
          EstimateItem(itemName: 'Honey 250ml', quantity: 1, unitPrice: 220),
        ],
      );

      final created = await repo.create(estimate);

      expect(created.id, 'est-1');
      expect(created.items, hasLength(2));
      expect(created.items[0].estimateId, 'est-1');
      expect(created.items[1].estimateId, 'est-1');

      // 1 estimate create + 2 item creates
      expect(requests, hasLength(3));
    });
  });
}
