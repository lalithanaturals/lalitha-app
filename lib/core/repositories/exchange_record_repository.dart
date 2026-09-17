import 'package:pocketbase/pocketbase.dart';

import '../models/exchange_record.dart';

class ExchangeRecordRepository {
  ExchangeRecordRepository(this._pb);

  final PocketBase _pb;

  /// The server assigns `display_id` via a hook (see
  /// lalitha-api/pb_hooks/main.pb.js) — the returned record carries it.
  Future<ExchangeRecord> create(ExchangeRecord record) async {
    final created = await _pb.collection('exchange_records').create(body: record.toJson());
    return ExchangeRecord.fromJson(created.toJson());
  }

  Future<ExchangeRecord> convertToOrder(String id) async {
    final updated = await _pb.collection('exchange_records').update(
          id,
          body: {'status': 'order'},
        );
    return ExchangeRecord.fromJson(updated.toJson());
  }

  Future<List<ExchangeRecord>> search(String query) async {
    if (query.trim().isEmpty) return const [];
    final escaped = query.replaceAll("'", "\\'");
    final records = await _pb.collection('exchange_records').getFullList(
          filter: "customer_name ~ '$escaped' || customer_phone ~ '$escaped' || display_id ~ '$escaped'",
          sort: '-created',
        );
    return records.map((r) => ExchangeRecord.fromJson(r.toJson())).toList();
  }
}
