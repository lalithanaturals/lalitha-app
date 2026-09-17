import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/repositories/inventory_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('InventoryRepository.setStockQuantity', () {
    test('creates a new stock row when none exists for (item, branch)', () async {
      final requests = <http.Request>[];
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            final body = jsonEncode({'page': 1, 'perPage': 1, 'totalItems': 0, 'totalPages': 0, 'items': []});
            return http.Response(body, 200, headers: {'content-type': 'application/json'});
          }
          final sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'stock1',
            'collectionId': 'inventory_stock',
            'collectionName': 'inventory_stock',
            ...sentBody,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = InventoryRepository(pb);
      final result = await repo.setStockQuantity(itemId: 'item1', branchId: 'branch1', quantity: 10);

      expect(result.id, 'stock1');
      expect(result.quantity, 10);
      final createRequest = requests.firstWhere((r) => r.method == 'POST');
      expect(jsonDecode(createRequest.body)['item'], 'item1');
    });

    test('updates the existing stock row when one already exists', () async {
      final requests = <http.Request>[];
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            final body = jsonEncode({
              'page': 1,
              'perPage': 1,
              'totalItems': 1,
              'totalPages': 1,
              'items': [
                {
                  'id': 'stock1',
                  'collectionId': 'inventory_stock',
                  'collectionName': 'inventory_stock',
                  'item': 'item1',
                  'branch': 'branch1',
                  'quantity': 5,
                },
              ],
            });
            return http.Response(body, 200, headers: {'content-type': 'application/json'});
          }
          final sentBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'stock1',
            'collectionId': 'inventory_stock',
            'collectionName': 'inventory_stock',
            'item': 'item1',
            'branch': 'branch1',
            ...sentBody,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = InventoryRepository(pb);
      final result = await repo.setStockQuantity(itemId: 'item1', branchId: 'branch1', quantity: 8);

      expect(result.quantity, 8);
      final patchRequest = requests.firstWhere((r) => r.method == 'PATCH');
      expect(patchRequest.url.path, '/api/collections/inventory_stock/records/stock1');
    });
  });

  group('InventoryRepository.listItemsForCategory', () {
    test('filters by category', () async {
      Uri? capturedUri;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedUri = request.url;
          final body = jsonEncode({'page': 1, 'perPage': 30, 'totalItems': 0, 'totalPages': 0, 'items': []});
          return http.Response(body, 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = InventoryRepository(pb);
      await repo.listItemsForCategory('cat1');

      expect(capturedUri!.queryParameters['filter'], 'category = "cat1"');
    });
  });
}
