import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/features/denomination/archive/archive_providers.dart';
import 'package:lalitha_app/features/denomination/dashboard/dashboard_providers.dart';
import 'package:lalitha_app/features/denomination/denomination_home_screen.dart';
import 'package:lalitha_app/features/denomination/register/register_providers.dart';

import '../../support/localized_test_app.dart';

Widget _homeWithOverrides() => ProviderScope(
      overrides: [
        registerBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        archiveBranchesProvider.overrideWith((ref) async => const <Branch>[]),
        dashboardBranchesProvider.overrideWith((ref) async => const <Branch>[]),
      ],
      child: localizedTestApp(home: const DenominationHomeScreen()),
    );

void main() {
  testWidgets('lists the Register Entry, Archive, and Dashboard tools', (tester) async {
    await tester.pumpWidget(_homeWithOverrides());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerEntryTile')), findsOneWidget);
    expect(find.byKey(const Key('archiveTile')), findsOneWidget);
    expect(find.byKey(const Key('dashboardTile')), findsOneWidget);
  });

  testWidgets('tapping Register Entry navigates to the Register screen', (tester) async {
    await tester.pumpWidget(_homeWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('registerEntryTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerBranchDropdown')), findsOneWidget);
  });

  testWidgets('tapping Archive navigates to the Archive screen', (tester) async {
    await tester.pumpWidget(_homeWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('archiveTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('archiveBranchDropdown')), findsOneWidget);
  });

  testWidgets('tapping Dashboard navigates to the Dashboard screen', (tester) async {
    await tester.pumpWidget(_homeWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dashboardTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboardBranchDropdown')), findsOneWidget);
  });
}
