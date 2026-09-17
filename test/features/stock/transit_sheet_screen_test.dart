import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/inventory.dart';
import 'package:lalitha_app/core/models/transit_sheet.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/transit_sheet_repository.dart';
import 'package:lalitha_app/features/stock/transit_sheet/transit_sheet_providers.dart';
import 'package:lalitha_app/features/stock/transit_sheet/transit_sheet_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockTransitSheetRepository extends Mock implements TransitSheetRepository {}

const _branch1 = Branch(id: 'branch1', name: 'Gajuwaka');
const _branch2 = Branch(id: 'branch2', name: 'Kurmannapalem');
const _item = InventoryItem(id: 'item1', categoryId: 'cat1', name: 'Ghee 500ml');

Future<void> _pumpScreen(WidgetTester tester, {required TransitSheetRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transitSheetBranchesProvider.overrideWith((ref) async => [_branch1, _branch2]),
        transitSheetAllItemsProvider.overrideWith((ref) async => [_item]),
        transitSheetRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const TransitSheetScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapDispatch(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('dispatchButton')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('dispatchButton')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const TransitSheet(fromBranchId: 'fallback', toBranchId: 'fallback'));
  });

  testWidgets('validates both branches selected before dispatching', (tester) async {
    final repo = _MockTransitSheetRepository();
    await _pumpScreen(tester, repo: repo);

    await _tapDispatch(tester);

    expect(find.textContaining('Select both a from-branch and a to-branch'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('validates from and to branches differ', (tester) async {
    final repo = _MockTransitSheetRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('fromBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('toBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await _tapDispatch(tester);

    expect(find.textContaining('must be different'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('validates at least one item with a quantity is selected', (tester) async {
    final repo = _MockTransitSheetRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('fromBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('toBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kurmannapalem').last);
    await tester.pumpAndSettle();

    await _tapDispatch(tester);

    expect(find.textContaining('Add at least one item'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('dispatching sends a dispatched sheet with the selected item/quantity', (tester) async {
    final repo = _MockTransitSheetRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('fromBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('toBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kurmannapalem').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('transitItemDropdown_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ghee 500ml').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('transitItemQtyField_0')), '15');
    await tester.pump();

    await _tapDispatch(tester);

    final captured = verify(() => repo.create(captureAny())).captured;
    expect(captured, hasLength(1));
    final sheet = captured.first as TransitSheet;
    expect(sheet.fromBranchId, 'branch1');
    expect(sheet.toBranchId, 'branch2');
    expect(sheet.status, TransitSheetStatus.dispatched);
    expect(sheet.items, hasLength(1));
    expect(sheet.items.first.quantity, 15);
    expect(find.text('Transit sheet dispatched'), findsOneWidget);
  });
}
