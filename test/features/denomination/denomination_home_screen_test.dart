import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/features/denomination/denomination_home_screen.dart';
import 'package:lalitha_app/features/denomination/register/register_providers.dart';

import '../../support/localized_test_app.dart';

Widget _homeWithOverrides() => ProviderScope(
      overrides: [
        registerBranchesProvider.overrideWith((ref) async => const <Branch>[]),
      ],
      child: localizedTestApp(home: const DenominationHomeScreen()),
    );

void main() {
  testWidgets('lists the Register Entry tool', (tester) async {
    await tester.pumpWidget(_homeWithOverrides());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerEntryTile')), findsOneWidget);
  });

  testWidgets('tapping Register Entry navigates to the Register screen', (tester) async {
    await tester.pumpWidget(_homeWithOverrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('registerEntryTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerBranchDropdown')), findsOneWidget);
  });
}
