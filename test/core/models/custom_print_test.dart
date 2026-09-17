import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/custom_print.dart';

void main() {
  group('PrintType', () {
    test('fromJson parses each known value', () {
      expect(PrintType.fromJson('custom_text'), PrintType.customText);
      expect(PrintType.fromJson('visiting_card'), PrintType.visitingCard);
      expect(PrintType.fromJson('location_card'), PrintType.locationCard);
    });

    test('fromJson defaults to customText for null/unknown values', () {
      expect(PrintType.fromJson(null), PrintType.customText);
      expect(PrintType.fromJson('garbage'), PrintType.customText);
    });

    test('toJson round-trips through fromJson for every value', () {
      for (final type in PrintType.values) {
        expect(PrintType.fromJson(type.toJson()), type);
      }
    });
  });

  group('CustomPrint JSON', () {
    test('round-trips content as an arbitrary JSON map', () {
      final content = {'branchName': 'Gajuwaka', 'address': 'MIG-20, Vuda Colony, Gajuwaka'};
      final print = CustomPrint(
        printType: PrintType.locationCard,
        content: content,
        branchId: 'branch1',
        staffId: 'staff1',
      );
      final json = print.toJson();
      expect(json['print_type'], 'location_card');
      expect(json['content'], content);
      expect(json['branch'], 'branch1');
      expect(json['staff'], 'staff1');

      final parsed = CustomPrint.fromJson({...json, 'id': 'cp1'});
      expect(parsed.id, 'cp1');
      expect(parsed.printType, PrintType.locationCard);
      expect(parsed.content, content);
    });

    test('fromJson defaults content to an empty map when absent', () {
      final print = CustomPrint.fromJson({'print_type': 'custom_text', 'branch': 'branch1'});
      expect(print.content, isEmpty);
    });

    test('toJson omits staff when staffId is null', () {
      const print = CustomPrint(
        printType: PrintType.visitingCard,
        content: {},
        branchId: 'branch1',
      );
      expect(print.toJson().containsKey('staff'), isFalse);
    });
  });
}
