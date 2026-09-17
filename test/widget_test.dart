import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/coupon.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/features/print/coupon/coupon_providers.dart';
import 'package:lalitha_app/features/print/custom_text/custom_text_providers.dart';
import 'package:lalitha_app/features/print/estimate/estimate_providers.dart';
import 'package:lalitha_app/features/print/location_card/location_card_providers.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/features/print/visiting_card/visiting_card_providers.dart';
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
      ],
      child: const LalithaApp(),
    );

void main() {
  testWidgets('LalithaApp boots to the Print module home screen', (WidgetTester tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    expect(find.text('Lalitha Naturals — Print'), findsOneWidget);
    expect(find.byKey(const Key('priceTagTile')), findsOneWidget);
    expect(find.byKey(const Key('estimateTile')), findsOneWidget);
    expect(find.byKey(const Key('couponTile')), findsOneWidget);
    expect(find.byKey(const Key('locationCardTile')), findsOneWidget);
    expect(find.byKey(const Key('visitingCardTile')), findsOneWidget);
    expect(find.byKey(const Key('customTextTile')), findsOneWidget);
  });

  testWidgets('tapping the Price Tag tile navigates to the Price Tag screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('priceTagTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mrpField')), findsOneWidget);
  });

  testWidgets('tapping the Estimate tile navigates to the Estimate screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('estimateTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('addItemButton')), findsOneWidget);
  });

  testWidgets('tapping the Coupon tile navigates to the Coupon screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('couponTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('issueCouponButton')), findsOneWidget);
  });

  testWidgets('tapping the Location Card tile navigates to the Location Card screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('locationCardTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('locationCardBranchDropdown')), findsOneWidget);
  });

  testWidgets('tapping the Visiting Card tile navigates to the Visiting Card screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('visitingCardTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('visitingCardBranchDropdown')), findsOneWidget);
  });

  testWidgets('tapping the Custom Text tile navigates to the Custom Text screen', (tester) async {
    await tester.pumpWidget(_appWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customTextTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customTextField')), findsOneWidget);
  });
}
