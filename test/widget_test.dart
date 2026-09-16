import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/features/print/estimate/estimate_providers.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/main.dart';

Widget _appWithOverrides() => ProviderScope(
      overrides: [
        branchesProvider.overrideWith((ref) async => const <Branch>[]),
        productsProvider.overrideWith((ref) async => const <Product>[]),
        staffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
        estimateBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        estimateStaffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
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
}
