import 'package:pocketbase/pocketbase.dart';

import '../models/estimate.dart';

class EstimateRepository {
  EstimateRepository(this._pb);

  final PocketBase _pb;

  /// Creates the estimate record, then all of its line items, then patches
  /// the estimate's `total_amount` — mirrors the master plan's contract
  /// (estimate_items is a separate collection related by `estimate`).
  Future<Estimate> create(Estimate estimate) async {
    final estimateRecord = await _pb.collection('estimates').create(body: estimate.toJson());

    final createdItems = <EstimateItem>[];
    for (final item in estimate.items) {
      final itemRecord = await _pb.collection('estimate_items').create(
            body: item.toJson()..['estimate'] = estimateRecord.id,
          );
      createdItems.add(EstimateItem.fromJson(itemRecord.toJson()));
    }

    return Estimate.fromJson(estimateRecord.toJson(), items: createdItems);
  }

  Future<List<EstimateItem>> itemsFor(String estimateId) async {
    final records = await _pb.collection('estimate_items').getFullList(
          filter: 'estimate = "$estimateId"',
        );
    return records.map((r) => EstimateItem.fromJson(r.toJson())).toList();
  }

  /// Deleting the parent also cascades to its items server-side
  /// (estimate_items.estimate has cascadeDelete enabled).
  Future<void> delete(String id) => _pb.collection('estimates').delete(id);
}
