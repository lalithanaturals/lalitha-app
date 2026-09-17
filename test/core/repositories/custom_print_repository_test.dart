import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/models/custom_print.dart';
import 'package:lalitha_app/core/repositories/custom_print_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('CustomPrintRepository.create', () {
    test('POSTs print_type/content/branch and returns the created record', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'cp1',
            'collectionId': 'custom_prints',
            'collectionName': 'custom_prints',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = CustomPrintRepository(pb);
      final print = CustomPrint(
        printType: PrintType.locationCard,
        content: const {'branchName': 'Gajuwaka', 'address': 'MIG-20, Vuda Colony'},
        branchId: 'branch1',
      );
      final created = await repo.create(print);

      expect(capturedBody!['print_type'], 'location_card');
      expect(capturedBody!['content'], {'branchName': 'Gajuwaka', 'address': 'MIG-20, Vuda Colony'});
      expect(created.id, 'cp1');
      expect(created.printType, PrintType.locationCard);
    });
  });

  group('CustomPrintRepository.listForBranch', () {
    test('filters by both branch and print_type', () async {
      Uri? capturedUri;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedUri = request.url;
          final body = jsonEncode({
            'page': 1,
            'perPage': 30,
            'totalItems': 0,
            'totalPages': 0,
            'items': [],
          });
          return http.Response(body, 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = CustomPrintRepository(pb);
      await repo.listForBranch('branch1', printType: PrintType.visitingCard);

      expect(
        capturedUri!.queryParameters['filter'],
        'branch = "branch1" && print_type = "visiting_card"',
      );
    });
  });
}
