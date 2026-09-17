import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/inventory.dart';
import 'package:lalitha_app/features/stock/inventory/inventory_providers.dart';
import 'package:lalitha_app/features/stock/stock_home_screen.dart';
import 'package:lalitha_app/features/stock/transit_sheet/transit_sheet_providers.dart';

import '../../support/localized_test_app.dart';

Widget _stockHomeWithOverrides() => ProviderScope(
      overrides: [
        inventoryBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        inventoryCategoriesProvider.overrideWith((ref) async => const <InventoryCategory>[]),
        transitSheetBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        transitSheetAllItemsProvider.overrideWith((ref) async => const <InventoryItem>[]),
      ],
      child: localizedTestApp(home: const StockHomeScreen()),
    );

void main() {
  testWidgets('lists the Inventory and Transit Sheet tools', (tester) async {
    await tester.pumpWidget(_stockHomeWithOverrides());
    await tester.pumpAndSettle();

    expect(find.text('Lalitha Naturals — Stock'), findsOneWidget);
    expect(find.byKey(const Key('inventoryTile')), findsOneWidget);
    expect(find.byKey(const Key('transitSheetTile')), findsOneWidget);
  });

  testWidgets('tapping Inventory navigates to the Inventory screen', (tester) async {
    await tester.pumpWidget(_stockHomeWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('inventoryTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventoryBranchDropdown')), findsOneWidget);
  });

  testWidgets('tapping Transit Sheet navigates to the Transit Sheet screen', (tester) async {
    await tester.pumpWidget(_stockHomeWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('transitSheetTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fromBranchDropdown')), findsOneWidget);
  });
}
