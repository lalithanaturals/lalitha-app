import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/models/transit_sheet.dart';
import 'package:lalitha_app/core/repositories/transit_sheet_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('TransitSheetRepository.create', () {
    test('creates the sheet then each item, tagged with the new sheet id', () async {
      var sheetCounter = 0;
      var itemCounter = 0;
      final requests = <http.Request>[];

      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          requests.add(request);
          final body = jsonDecode(request.body) as Map<String, dynamic>;

          if (request.url.path == '/api/collections/transit_sheets/records') {
            sheetCounter++;
            final response = {
              'id': 'sheet-$sheetCounter',
              'collectionId': 'transit_sheets',
              'collectionName': 'transit_sheets',
              ...body,
            };
            return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
          }

          itemCounter++;
          final response = {
            'id': 'item-$itemCounter',
            'collectionId': 'transit_sheet_items',
            'collectionName': 'transit_sheet_items',
            ...body,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = TransitSheetRepository(pb);
      final sheet = const TransitSheet(
        fromBranchId: 'branch1',
        toBranchId: 'branch2',
        status: TransitSheetStatus.draft,
        items: [
          TransitSheetItem(itemId: 'item1', itemName: 'Widget', quantity: 5),
          TransitSheetItem(itemId: 'item2', itemName: 'Gadget', quantity: 2),
        ],
      );

      final created = await repo.create(sheet);

      expect(created.id, 'sheet-1');
      expect(created.items, hasLength(2));
      expect(created.items[0].transitSheetId, 'sheet-1');
      expect(requests, hasLength(3));
    });
  });

  group('TransitSheetRepository.listForBranch', () {
    test('filters sheets where the branch is sending or receiving', () async {
      Uri? capturedUri;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedUri = request.url;
          final body = jsonEncode({'page': 1, 'perPage': 30, 'totalItems': 0, 'totalPages': 0, 'items': []});
          return http.Response(body, 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = TransitSheetRepository(pb);
      await repo.listForBranch('branch1');

      expect(
        capturedUri!.queryParameters['filter'],
        '(from_branch = "branch1" || to_branch = "branch1")',
      );
    });
  });

  group('TransitSheetRepository.updateStatus', () {
    test('dispatching stamps dispatched_at', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'sheet1',
            'collectionId': 'transit_sheets',
            'collectionName': 'transit_sheets',
            'from_branch': 'branch1',
            'to_branch': 'branch2',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = TransitSheetRepository(pb);
      final at = DateTime.utc(2026, 9, 17, 10);
      final result = await repo.updateStatus('sheet1', TransitSheetStatus.dispatched, at: at);

      expect(capturedBody!['status'], 'dispatched');
      expect(capturedBody!['dispatched_at'], at.toIso8601String());
      expect(capturedBody!.containsKey('received_at'), isFalse);
      expect(result.status, TransitSheetStatus.dispatched);
    });

    test('receiving stamps received_at', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'sheet1',
            'collectionId': 'transit_sheets',
            'collectionName': 'transit_sheets',
            'from_branch': 'branch1',
            'to_branch': 'branch2',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = TransitSheetRepository(pb);
      final result = await repo.updateStatus('sheet1', TransitSheetStatus.received);

      expect(capturedBody!['status'], 'received');
      expect(capturedBody!.containsKey('received_at'), isTrue);
      expect(result.status, TransitSheetStatus.received);
    });
  });
}
