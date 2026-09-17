import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/transit_sheet.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/transit_sheet_repository.dart';
import 'package:lalitha_app/features/stock/transit_history/transit_history_providers.dart';
import 'package:lalitha_app/features/stock/transit_history/transit_history_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockTransitSheetRepository extends Mock implements TransitSheetRepository {}

const _branch1 = Branch(id: 'branch1', name: 'Gajuwaka');
const _branch2 = Branch(id: 'branch2', name: 'Kurmannapalem');

Future<void> _pumpScreen(
  WidgetTester tester, {
  List<TransitSheet> sheets = const [],
  TransitSheetRepository? repo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transitHistoryBranchesProvider.overrideWith((ref) async => [_branch1, _branch2]),
        transitHistorySheetsProvider.overrideWith((ref, branchId) async => sheets),
        transitHistoryItemsProvider.overrideWith((ref, sheetId) async => const [
              TransitSheetItem(itemId: 'item1', itemName: 'Ghee 500ml', quantity: 5),
            ]),
        if (repo != null) transitSheetRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const TransitHistoryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectBranch(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('transitHistoryBranchDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(TransitSheetStatus.draft);
  });

  testWidgets('shows a no-sheets message when the branch has none', (tester) async {
    await _pumpScreen(tester);
    await _selectBranch(tester, 'Gajuwaka');

    expect(find.byKey(const Key('noTransitSheetsText')), findsOneWidget);
  });

  testWidgets('lists sheets with a from -> to summary and status', (tester) async {
    await _pumpScreen(tester, sheets: [
      TransitSheet(
        id: 'sheet1',
        fromBranchId: 'branch1',
        toBranchId: 'branch2',
        status: TransitSheetStatus.dispatched,
      ),
    ]);
    await _selectBranch(tester, 'Gajuwaka');

    expect(find.byKey(const Key('transitHistoryTile_sheet1')), findsOneWidget);
    expect(find.textContaining('Gajuwaka'), findsWidgets);
    expect(find.textContaining('Kurmannapalem'), findsWidgets);
    expect(find.text('In Transit'), findsOneWidget);
  });

  testWidgets('expanding a sheet shows its line items', (tester) async {
    await _pumpScreen(tester, sheets: [
      TransitSheet(id: 'sheet1', fromBranchId: 'branch1', toBranchId: 'branch2'),
    ]);
    await _selectBranch(tester, 'Gajuwaka');

    await tester.tap(find.byKey(const Key('transitHistoryExpansion_sheet1')));
    await tester.pumpAndSettle();

    expect(find.text('Ghee 500ml'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('shows Mark Received only when the selected branch is the dispatched receiver', (tester) async {
    await _pumpScreen(tester, sheets: [
      TransitSheet(
        id: 'sheet1',
        fromBranchId: 'branch1',
        toBranchId: 'branch2',
        status: TransitSheetStatus.dispatched,
      ),
    ]);
    // branch1 is the sender, not the receiver — no Mark Received here.
    await _selectBranch(tester, 'Gajuwaka');
    await tester.tap(find.byKey(const Key('transitHistoryExpansion_sheet1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('markReceivedButton_sheet1')), findsNothing);
  });

  testWidgets('tapping Mark Received calls updateStatus and shows a confirmation', (tester) async {
    final repo = _MockTransitSheetRepository();
    when(() => repo.updateStatus(any(), any())).thenAnswer(
      (_) async => const TransitSheet(id: 'sheet1', fromBranchId: 'branch1', toBranchId: 'branch2'),
    );
    await _pumpScreen(
      tester,
      repo: repo,
      sheets: [
        TransitSheet(
          id: 'sheet1',
          fromBranchId: 'branch1',
          toBranchId: 'branch2',
          status: TransitSheetStatus.dispatched,
        ),
      ],
    );
    // branch2 is the receiver of this dispatched sheet.
    await _selectBranch(tester, 'Kurmannapalem');
    await tester.tap(find.byKey(const Key('transitHistoryExpansion_sheet1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('markReceivedButton_sheet1')));
    await tester.pumpAndSettle();

    verify(() => repo.updateStatus('sheet1', TransitSheetStatus.received)).called(1);
    expect(find.text('Marked as received'), findsOneWidget);
  });
}
