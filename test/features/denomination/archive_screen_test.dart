import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/audit_register.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/features/denomination/archive/archive_providers.dart';
import 'package:lalitha_app/features/denomination/archive/archive_screen.dart';

import '../../support/localized_test_app.dart';

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');

Future<void> _pumpScreen(
  WidgetTester tester, {
  List<AuditRegister> registers = const [],
  List<AuditLineItem> lineItems = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        archiveBranchesProvider.overrideWith((ref) async => [_branch]),
        archiveRegistersProvider.overrideWith((ref, branchId) async => registers),
        archiveLineItemsProvider.overrideWith((ref, registerId) async => lineItems),
      ],
      child: localizedTestApp(home: const ArchiveScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectBranch(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('archiveBranchDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gajuwaka').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a no-registers message when the branch has none', (tester) async {
    await _pumpScreen(tester);
    await _selectBranch(tester);

    expect(find.byKey(const Key('noRegistersText')), findsOneWidget);
  });

  testWidgets('lists registers with date, status, cash total, and closing balance', (tester) async {
    await _pumpScreen(tester, registers: [
      AuditRegister(
        id: 'reg1',
        date: DateTime.utc(2026, 9, 17),
        branchId: 'branch1',
        status: AuditRegisterStatus.committed,
        cashTotal: 5000,
        closingBalance: 1200,
      ),
    ]);
    await _selectBranch(tester);

    expect(find.byKey(const Key('archiveRegisterTile_reg1')), findsOneWidget);
    expect(find.textContaining('2026-09-17'), findsOneWidget);
    expect(find.textContaining('Committed'), findsOneWidget);
    expect(find.textContaining('₹5000.00'), findsOneWidget);
    expect(find.textContaining('₹1200.00'), findsOneWidget);
  });

  testWidgets('expanding a register shows its line items', (tester) async {
    await _pumpScreen(
      tester,
      registers: [
        AuditRegister(
          id: 'reg1',
          date: DateTime.utc(2026, 9, 17),
          branchId: 'branch1',
        ),
      ],
      lineItems: const [
        AuditLineItem(category: AuditLineCategory.expense, name: 'Electricity', amount: 450),
      ],
    );
    await _selectBranch(tester);

    await tester.tap(find.byKey(const Key('archiveRegisterExpansion_reg1')));
    await tester.pumpAndSettle();

    expect(find.text('Electricity'), findsOneWidget);
    expect(find.text('₹450.00'), findsOneWidget);
  });

  testWidgets('expanding a register with no line items shows a message', (tester) async {
    await _pumpScreen(
      tester,
      registers: [
        AuditRegister(id: 'reg1', date: DateTime.utc(2026, 9, 17), branchId: 'branch1'),
      ],
    );
    await _selectBranch(tester);

    await tester.tap(find.byKey(const Key('archiveRegisterExpansion_reg1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('noLineItemsText_reg1')), findsOneWidget);
  });

  testWidgets('tapping View Receipt navigates to the receipt preview', (tester) async {
    await _pumpScreen(
      tester,
      registers: [
        AuditRegister(id: 'reg1', date: DateTime.utc(2026, 9, 17), branchId: 'branch1', cashTotal: 1000),
      ],
    );
    await _selectBranch(tester);

    await tester.tap(find.byKey(const Key('archiveRegisterExpansion_reg1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('viewReceiptButton_reg1')));
    await tester.pumpAndSettle();

    expect(find.text('Cash Total: ₹1000.00'), findsOneWidget);
  });
}
