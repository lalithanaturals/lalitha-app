import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/coupon.dart';
import 'package:lalitha_app/core/models/inventory.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/features/auth/auth_gate.dart';
import 'package:lalitha_app/features/auth/login_providers.dart';
import 'package:lalitha_app/features/print/coupon/coupon_providers.dart';
import 'package:lalitha_app/features/print/custom_text/custom_text_providers.dart';
import 'package:lalitha_app/features/print/estimate/estimate_providers.dart';
import 'package:lalitha_app/features/print/location_card/location_card_providers.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/features/print/visiting_card/visiting_card_providers.dart';
import 'package:lalitha_app/features/denomination/register/register_providers.dart';
import 'package:lalitha_app/features/scrap/calculator/calculator_providers.dart';
import 'package:lalitha_app/features/stock/inventory/inventory_providers.dart';
import 'package:lalitha_app/features/stock/transit_sheet/transit_sheet_providers.dart';

import '../../support/localized_test_app.dart';

Future<void> _pump(WidgetTester tester, {required bool loggedIn}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(loggedIn)),
        activeStaffProvider.overrideWith((ref) async => const <Staff>[]),
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
        registerBranchesProvider.overrideWith((ref) async => const <Branch>[]),
      ],
      child: localizedTestApp(home: const AuthGate()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the staff login screen when logged out', (tester) async {
    await _pump(tester, loggedIn: false);

    expect(find.byKey(const Key('loginButton')), findsOneWidget);
    expect(find.byKey(const Key('printModuleTile')), findsNothing);
  });

  testWidgets('shows the module picker when logged in', (tester) async {
    await _pump(tester, loggedIn: true);

    expect(find.byKey(const Key('printModuleTile')), findsOneWidget);
    expect(find.byKey(const Key('loginButton')), findsNothing);
  });
}
