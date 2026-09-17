import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/transit_sheet.dart';

void main() {
  group('TransitSheetStatus', () {
    test('fromJson parses each known value', () {
      expect(TransitSheetStatus.fromJson('draft'), TransitSheetStatus.draft);
      expect(TransitSheetStatus.fromJson('dispatched'), TransitSheetStatus.dispatched);
      expect(TransitSheetStatus.fromJson('received'), TransitSheetStatus.received);
    });

    test('fromJson defaults to draft for null/unknown values', () {
      expect(TransitSheetStatus.fromJson(null), TransitSheetStatus.draft);
      expect(TransitSheetStatus.fromJson('garbage'), TransitSheetStatus.draft);
    });
  });

  group('TransitSheetItem', () {
    test('toJson omits transit_sheet when not yet assigned', () {
      const item = TransitSheetItem(itemId: 'i1', itemName: 'Widget', quantity: 3);
      expect(item.toJson().containsKey('transit_sheet'), isFalse);
    });

    test('toJson includes transit_sheet once assigned', () {
      const item = TransitSheetItem(
        transitSheetId: 'sheet1',
        itemId: 'i1',
        itemName: 'Widget',
        quantity: 3,
      );
      expect(item.toJson()['transit_sheet'], 'sheet1');
    });
  });

  group('TransitSheet JSON', () {
    test('fromJson parses dispatched_at/received_at as DateTime', () {
      final sheet = TransitSheet.fromJson({
        'id': 's1',
        'from_branch': 'b1',
        'to_branch': 'b2',
        'status': 'received',
        'dispatched_at': '2026-09-17T10:00:00.000Z',
        'received_at': '2026-09-17T12:00:00.000Z',
      });
      expect(sheet.status, TransitSheetStatus.received);
      expect(sheet.dispatchedAt, DateTime.parse('2026-09-17T10:00:00.000Z'));
      expect(sheet.receivedAt, DateTime.parse('2026-09-17T12:00:00.000Z'));
    });

    test('fromJson treats empty date strings as null', () {
      final sheet = TransitSheet.fromJson({
        'from_branch': 'b1',
        'to_branch': 'b2',
        'dispatched_at': '',
      });
      expect(sheet.dispatchedAt, isNull);
    });

    test('toJson only includes stamps that are set', () {
      const sheet = TransitSheet(fromBranchId: 'b1', toBranchId: 'b2');
      final json = sheet.toJson();
      expect(json.containsKey('dispatched_at'), isFalse);
      expect(json.containsKey('received_at'), isFalse);
      expect(json['status'], 'draft');
    });
  });
}
