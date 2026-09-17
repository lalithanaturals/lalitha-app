import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/audit_register.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/features/denomination/dashboard/dashboard_providers.dart';
import 'package:lalitha_app/features/denomination/dashboard/dashboard_screen.dart';

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
        dashboardBranchesProvider.overrideWith((ref) async => [_branch]),
        dashboardRegistersProvider.overrideWith((ref, branchId) async => registers),
        dashboardLineItemsProvider.overrideWith((ref, branchId) async => lineItems),
      ],
      child: localizedTestApp(home: const DashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectBranch(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('dashboardBranchDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gajuwaka').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the register count and total cash across all registers', (tester) async {
    await _pumpScreen(tester, registers: [
      AuditRegister(id: 'r1', date: DateTime.utc(2026, 9, 16), branchId: 'branch1', cashTotal: 3000),
      AuditRegister(id: 'r2', date: DateTime.utc(2026, 9, 17), branchId: 'branch1', cashTotal: 4500),
    ]);
    await _selectBranch(tester);

    expect(find.text('Registers: 2'), findsOneWidget);
    expect(find.text('Total Cash Counted: ₹7500.00'), findsOneWidget);
  });

  testWidgets('shows the per-category breakdown summed across all line items', (tester) async {
    await _pumpScreen(
      tester,
      registers: [AuditRegister(id: 'r1', date: DateTime.utc(2026, 9, 17), branchId: 'branch1')],
      lineItems: const [
        AuditLineItem(category: AuditLineCategory.expense, name: 'Electricity', amount: 450),
        AuditLineItem(category: AuditLineCategory.expense, name: 'Water', amount: 100),
        AuditLineItem(category: AuditLineCategory.ownerBill, name: 'Rent', amount: 5000),
      ],
    );
    await _selectBranch(tester);

    expect(find.byKey(const Key('categoryTotal_expense')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('categoryTotal_expense'))).data,
      '₹550.00',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('categoryTotal_ownerBill'))).data,
      '₹5000.00',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('categoryTotal_vendorBill'))).data,
      '₹0.00',
    );
  });

  testWidgets('shows zero totals when the branch has no registers', (tester) async {
    await _pumpScreen(tester);
    await _selectBranch(tester);

    expect(find.text('Registers: 0'), findsOneWidget);
    expect(find.text('Total Cash Counted: ₹0.00'), findsOneWidget);
  });
}
