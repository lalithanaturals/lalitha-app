import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/inventory.dart';

void main() {
  group('InventoryCategory', () {
    test('fromJson/toJson round-trip name', () {
      final category = InventoryCategory.fromJson({'id': 'c1', 'name': 'Groceries'});
      expect(category.id, 'c1');
      expect(category.toJson(), {'name': 'Groceries'});
    });
  });

  group('InventoryItem', () {
    test('fromJson defaults code/uom/minLimit when absent', () {
      final item = InventoryItem.fromJson({'id': 'i1', 'category': 'c1', 'name': 'Ghee 500ml'});
      expect(item.code, '');
      expect(item.uom, '');
      expect(item.minLimit, 0);
    });

    test('toJson includes all fields', () {
      const item = InventoryItem(
        id: 'i1',
        categoryId: 'c1',
        name: 'Ghee 500ml',
        code: 'GHE500',
        uom: 'bottle',
        minLimit: 10,
      );
      expect(item.toJson(), {
        'category': 'c1',
        'name': 'Ghee 500ml',
        'code': 'GHE500',
        'uom': 'bottle',
        'min_limit': 10,
      });
    });
  });

  group('InventoryStock', () {
    test('toJson omits updated_by when null', () {
      const stock = InventoryStock(itemId: 'i1', branchId: 'b1', quantity: 5);
      expect(stock.toJson().containsKey('updated_by'), isFalse);
    });

    test('toJson includes updated_by when present', () {
      const stock = InventoryStock(
        itemId: 'i1',
        branchId: 'b1',
        quantity: 5,
        updatedByStaffId: 'staff1',
      );
      expect(stock.toJson()['updated_by'], 'staff1');
    });

    test('fromJson defaults quantity to 0 when absent', () {
      final stock = InventoryStock.fromJson({'item': 'i1', 'branch': 'b1'});
      expect(stock.quantity, 0);
    });
  });
}
