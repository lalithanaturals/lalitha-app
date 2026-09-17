import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lalitha_app/core/models/audit_register.dart';
import 'package:lalitha_app/core/repositories/audit_register_repository.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('AuditRegisterRepository.commit', () {
    test('PATCHes status to committed and stamps committed_by', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'reg1',
            'collectionId': 'audit_registers',
            'collectionName': 'audit_registers',
            'date': '2026-09-17T00:00:00.000Z',
            'branch': 'branch1',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = AuditRegisterRepository(pb);
      final result = await repo.commit('reg1', committedByStaffId: 'staff1');

      expect(capturedBody!['status'], 'committed');
      expect(capturedBody!['committed_by'], 'staff1');
      expect(result.status, AuditRegisterStatus.committed);
    });
  });

  group('AuditRegisterRepository.findPreviousRegister', () {
    test('returns null when no earlier register exists', () async {
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          final body = jsonEncode({'page': 1, 'perPage': 1, 'totalItems': 0, 'totalPages': 0, 'items': []});
          return http.Response(body, 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = AuditRegisterRepository(pb);
      final result = await repo.findPreviousRegister('branch1', DateTime.utc(2026, 9, 17));

      expect(result, isNull);
    });

    test('sends a "date <" filter sorted descending and returns the first match', () async {
      Uri? capturedUri;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedUri = request.url;
          final body = jsonEncode({
            'page': 1,
            'perPage': 1,
            'totalItems': 1,
            'totalPages': 1,
            'items': [
              {
                'id': 'reg-yesterday',
                'collectionId': 'audit_registers',
                'collectionName': 'audit_registers',
                'date': '2026-09-16T00:00:00.000Z',
                'branch': 'branch1',
                'closing_balance': 3210,
              },
            ],
          });
          return http.Response(body, 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = AuditRegisterRepository(pb);
      final result = await repo.findPreviousRegister('branch1', DateTime.utc(2026, 9, 17));

      expect(result, isNotNull);
      expect(result!.closingBalance, 3210);
      expect(capturedUri!.queryParameters['filter'], contains('branch = "branch1"'));
      expect(capturedUri!.queryParameters['filter'], contains('date <'));
      expect(capturedUri!.queryParameters['sort'], '-date');
    });
  });

  group('AuditRegisterRepository.addLineItem', () {
    test('POSTs the category/name/amount', () async {
      Map<String, dynamic>? capturedBody;
      final pb = PocketBase(
        'http://mock.local',
        httpClientFactory: () => MockClient((request) async {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          final response = {
            'id': 'item1',
            'collectionId': 'audit_line_items',
            'collectionName': 'audit_line_items',
            ...capturedBody!,
          };
          return http.Response(jsonEncode(response), 200, headers: {'content-type': 'application/json'});
        }),
      );

      final repo = AuditRegisterRepository(pb);
      final result = await repo.addLineItem(const AuditLineItem(
        auditRegisterId: 'reg1',
        category: AuditLineCategory.expense,
        name: 'Electricity',
        amount: 450,
      ));

      expect(capturedBody!['category'], 'expense');
      expect(capturedBody!['amount'], 450);
      expect(result.id, 'item1');
    });
  });
}
