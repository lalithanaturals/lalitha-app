import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';

void main() {
  group('Branch', () {
    test('fromJson parses fields and defaults is_active to true', () {
      final branch = Branch.fromJson({'id': 'b1', 'name': 'Gajuwaka'});
      expect(branch.id, 'b1');
      expect(branch.name, 'Gajuwaka');
      expect(branch.isActive, isTrue);
      expect(branch.address, '');
    });

    test('toJson excludes id (server-assigned)', () {
      const branch = Branch(id: 'b1', name: 'Kurmannapalem', address: 'VUDA Colony');
      final json = branch.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['name'], 'Kurmannapalem');
      expect(json['address'], 'VUDA Colony');
    });
  });

  group('Staff', () {
    test('fromJson maps the branch relation field', () {
      final staff = Staff.fromJson({'id': 's1', 'name': 'Bhargav', 'branch': 'b1'});
      expect(staff.branchId, 'b1');
      expect(staff.isActive, isTrue);
    });
  });

  group('Product', () {
    test('fromJson defaults default_price to 0 when absent', () {
      final product = Product.fromJson({'id': 'p1', 'brand_name': 'Lalitha Naturals Ghee'});
      expect(product.defaultPrice, 0);
    });

    test('toJson round-trips brand_name and default_price', () {
      const product = Product(id: 'p1', brandName: 'Cold Pressed Oil', defaultPrice: 350);
      final json = product.toJson();
      expect(json['brand_name'], 'Cold Pressed Oil');
      expect(json['default_price'], 350);
    });
  });
}
