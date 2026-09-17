import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/models/exchange_record.dart';
import 'package:lalitha_app/core/repositories/exchange_record_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('ExchangeRecordRepository.create', () {
    test('POSTs the computed totals and returns the server-assigned display_id', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'rec1',
            'collectionId': 'exchange_records',
            'collectionName': 'exchange_records',
            'display_id': 'EX-7',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = ExchangeRecordRepository(pb);
      const record = ExchangeRecord(branchId: 'branch1', alWeights: [10], alHandles: 1);
      final created = await repo.create(record);

      expect(capturedBody!['al_weights'], [10]);
      expect(created.displayId, 'EX-7');
      expect(created.id, 'rec1');
    });
  });

  group('ExchangeRecordRepository.convertToOrder', () {
    test('PATCHes only the status field', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'rec1',
            'collectionId': 'exchange_records',
            'collectionName': 'exchange_records',
            'branch': 'branch1',
            'display_id': 'EX-7',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = ExchangeRecordRepository(pb);
      final result = await repo.convertToOrder('rec1');

      expect(capturedBody, {'status': 'order'});
      expect(result.status, ExchangeStatus.order);
    });
  });

  group('ExchangeRecordRepository.search', () {
    test('returns an empty list without a request when the query is blank', () async {
      var called = false;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );

      final repo = ExchangeRecordRepository(pb);
      final result = await repo.search('   ');

      expect(result, isEmpty);
      expect(called, isFalse);
    });

    test('sends a filter across customer_name/customer_phone/display_id', () async {
      Uri? capturedUri;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedUri = request.url;
          final body = jsonEncode({'page': 1, 'perPage': 30, 'totalItems': 0, 'totalPages': 0, 'items': []});
          return http.Response(body, 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = ExchangeRecordRepository(pb);
      await repo.search('Ravi');

      final filter = capturedUri!.queryParameters['filter']!;
      expect(filter, contains("customer_name ~ 'Ravi'"));
      expect(filter, contains("customer_phone ~ 'Ravi'"));
      expect(filter, contains("display_id ~ 'Ravi'"));
    });
  });
}
