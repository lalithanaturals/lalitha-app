import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/main.dart';

void main() {
  testWidgets('LalithaApp boots to the Price Tag screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          branchesProvider.overrideWith((ref) async => const <Branch>[]),
          productsProvider.overrideWith((ref) async => const <Product>[]),
          staffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
        ],
        child: const LalithaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Price Tag'), findsOneWidget);
  });
}
