import 'package:pocketbase/pocketbase.dart';

import '../models/inventory.dart';

class InventoryRepository {
  InventoryRepository(this._pb);

  final PocketBase _pb;

  Future<List<InventoryCategory>> listCategories() async {
    final records = await _pb.collection('inventory_categories').getFullList(sort: 'name');
    return records.map((r) => InventoryCategory.fromJson(r.toJson())).toList();
  }

  Future<List<InventoryItem>> listItemsForCategory(String categoryId) async {
    final records = await _pb.collection('inventory_items').getFullList(
          filter: 'category = "$categoryId"',
          sort: 'name',
        );
    return records.map((r) => InventoryItem.fromJson(r.toJson())).toList();
  }

  Future<List<InventoryItem>> listAllItems() async {
    final records = await _pb.collection('inventory_items').getFullList(sort: 'name');
    return records.map((r) => InventoryItem.fromJson(r.toJson())).toList();
  }

  Future<List<InventoryStock>> listStockForBranch(String branchId) async {
    final records = await _pb.collection('inventory_stock').getFullList(
          filter: 'branch = "$branchId"',
        );
    return records.map((r) => InventoryStock.fromJson(r.toJson())).toList();
  }

  /// Upserts the stock row for (item, branch): PocketBase enforces a unique
  /// `(item, branch)` pair, so this looks the row up first rather than
  /// blindly attempting a create every time a staff member adjusts a count.
  Future<InventoryStock> setStockQuantity({
    required String itemId,
    required String branchId,
    required num quantity,
    String? staffId,
  }) async {
    final existing = await _pb.collection('inventory_stock').getList(
          page: 1,
          perPage: 1,
          filter: 'item = "$itemId" && branch = "$branchId"',
        );

    if (existing.items.isEmpty) {
      final created = await _pb.collection('inventory_stock').create(
            body: InventoryStock(
              itemId: itemId,
              branchId: branchId,
              quantity: quantity,
              updatedByStaffId: staffId,
            ).toJson(),
          );
      return InventoryStock.fromJson(created.toJson());
    }

    final record = existing.items.first;
    final updated = await _pb.collection('inventory_stock').update(
          record.id,
          body: {
            'quantity': quantity,
            'updated_by': ?staffId,
          },
        );
    return InventoryStock.fromJson(updated.toJson());
  }
}
