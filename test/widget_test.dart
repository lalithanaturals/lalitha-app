import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/coupon.dart';
import 'package:lalitha_app/core/models/inventory.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/features/print/coupon/coupon_providers.dart';
import 'package:lalitha_app/features/print/custom_text/custom_text_providers.dart';
import 'package:lalitha_app/features/print/estimate/estimate_providers.dart';
import 'package:lalitha_app/features/print/location_card/location_card_providers.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/features/print/visiting_card/visiting_card_providers.dart';
import 'package:lalitha_app/features/scrap/calculator/calculator_providers.dart';
import 'package:lalitha_app/features/stock/inventory/inventory_providers.dart';
import 'package:lalitha_app/features/stock/transit_sheet/transit_sheet_providers.dart';
import 'package:lalitha_app/main.dart';

Widget _appWithOverrides() => ProviderScope(
      overrides: [
        branchesProvider.overrideWith((ref) async => const <Branch>[]),
        productsProvider.overrideWith((ref) async => const <Product>[]),
        staffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
        estimateBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        estimateStaffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
        couponBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        couponStaffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
        couponsForBranchProvider.overrideWith((ref, branchId) async => const <Coupon>[]),
        locationCardBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        visitingCardBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        customTextBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        inventoryBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        inventoryCategoriesProvider.overrideWith((ref) async => const <InventoryCategory>[]),
        transitSheetBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        transitSheetAllItemsProvider.overrideWith((ref) async => const <InventoryItem>[]),
        calculatorBranchesProvider.overrideWith((ref) async => const <Branch>[]),
      ],
      child: const LalithaApp(),
    );

void main() {
  testWidgets('LalithaApp boots to the suite-wide module picker', (WidgetTester tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('printModuleTile')), findsOneWidget);
    expect(find.byKey(const Key('stockModuleTile')), findsOneWidget);
    expect(find.byKey(const Key('scrapModuleTile')), findsOneWidget);
  });

  testWidgets('tapping the Print module tile navigates to the Print home screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('printModuleTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('priceTagTile')), findsOneWidget);
  });

  testWidgets('tapping the Stock module tile navigates to the Stock home screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stockModuleTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventoryTile')), findsOneWidget);
    expect(find.byKey(const Key('transitSheetTile')), findsOneWidget);
  });

  testWidgets('tapping the Scrap Exchange tile navigates to the Calculator screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('scrapModuleTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calculatorBranchDropdown')), findsOneWidget);
  });
}
