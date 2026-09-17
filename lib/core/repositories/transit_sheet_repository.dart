import 'package:pocketbase/pocketbase.dart';

import '../models/transit_sheet.dart';

class TransitSheetRepository {
  TransitSheetRepository(this._pb);

  final PocketBase _pb;

  Future<TransitSheet> create(TransitSheet sheet) async {
    final sheetRecord = await _pb.collection('transit_sheets').create(body: sheet.toJson());

    final createdItems = <TransitSheetItem>[];
    for (final item in sheet.items) {
      final itemRecord = await _pb.collection('transit_sheet_items').create(
            body: item.toJson()..['transit_sheet'] = sheetRecord.id,
          );
      createdItems.add(TransitSheetItem.fromJson(itemRecord.toJson(), itemName: item.itemName));
    }

    return TransitSheet.fromJson(sheetRecord.toJson(), items: createdItems);
  }

  /// Sheets where the branch is either sending or receiving.
  Future<List<TransitSheet>> listForBranch(String branchId) async {
    final records = await _pb.collection('transit_sheets').getFullList(
          filter: '(from_branch = "$branchId" || to_branch = "$branchId")',
          sort: '-created',
        );
    return records.map((r) => TransitSheet.fromJson(r.toJson())).toList();
  }

  Future<TransitSheet> updateStatus(String id, TransitSheetStatus status, {DateTime? at}) async {
    final body = <String, dynamic>{'status': status.toJson()};
    if (status == TransitSheetStatus.dispatched) {
      body['dispatched_at'] = (at ?? DateTime.now()).toIso8601String();
    } else if (status == TransitSheetStatus.received) {
      body['received_at'] = (at ?? DateTime.now()).toIso8601String();
    }
    final record = await _pb.collection('transit_sheets').update(id, body: body);
    return TransitSheet.fromJson(record.toJson());
  }
}
