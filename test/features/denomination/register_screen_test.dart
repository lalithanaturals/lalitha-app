import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/audit_register.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/audit_register_repository.dart';
import 'package:lalitha_app/features/denomination/register/register_providers.dart';
import 'package:lalitha_app/features/denomination/register/register_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockAuditRegisterRepository extends Mock implements AuditRegisterRepository {}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');
const _staff = Staff(id: 'staff1', name: 'Bhargav', branchId: 'branch1');

Future<void> _pumpScreen(WidgetTester tester, {required AuditRegisterRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        registerBranchesProvider.overrideWith((ref) async => [_branch]),
        registerStaffForBranchProvider.overrideWith((ref, branchId) async => [_staff]),
        auditRegisterRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const RegisterScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectBranch(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('registerBranchDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gajuwaka').last);
  await tester.pumpAndSettle();
}

Future<void> _tapCommit(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('commitButton')),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('commitButton')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuditLineItem(category: AuditLineCategory.expense, name: '', amount: 0));
    registerFallbackValue(AuditRegister(date: DateTime.utc(2026, 1, 1), branchId: 'fallback'));
  });

  testWidgets('selecting a branch loads the opening balance from the previous register', (tester) async {
    final repo = _MockAuditRegisterRepository();
    when(() => repo.findPreviousRegister(any(), any())).thenAnswer(
      (_) async => AuditRegister(
        date: DateTime.utc(2026, 9, 16),
        branchId: 'branch1',
        closingBalance: 3210,
        status: AuditRegisterStatus.committed,
      ),
    );
    await _pumpScreen(tester, repo: repo);

    await _selectBranch(tester);

    expect(find.text('Opening Balance: ₹3210.00'), findsOneWidget);
  });

  testWidgets('cash total and closing balance update live as denominations are entered', (tester) async {
    final repo = _MockAuditRegisterRepository();
    when(() => repo.findPreviousRegister(any(), any())).thenAnswer((_) async => null);
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('denomField_500')), '4');
    await tester.enterText(find.byKey(const Key('denomField_100')), '2');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('cashTotalText')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    // cash total: 500*4 + 100*2 = 2200
    expect(find.text('Cash Total: ₹2200.00'), findsOneWidget);
    // closing balance excludes the ₹500 notes: 100*2 = 200
    expect(find.text('Closing Balance: ₹200.00'), findsOneWidget);
  });

  testWidgets('shows a validation message when committing without a branch selected', (tester) async {
    final repo = _MockAuditRegisterRepository();
    await _pumpScreen(tester, repo: repo);

    await _tapCommit(tester);

    expect(find.textContaining('Select a branch first'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('committing creates the register, its line items, then commits it', (tester) async {
    final repo = _MockAuditRegisterRepository();
    when(() => repo.findPreviousRegister(any(), any())).thenAnswer((_) async => null);
    when(() => repo.create(any())).thenAnswer(
      (invocation) async {
        final sent = invocation.positionalArguments.first as AuditRegister;
        return AuditRegister(
          id: 'reg1',
          date: sent.date,
          branchId: sent.branchId,
          openingBalance: sent.openingBalance,
          closingBalance: sent.closingBalance,
          denominationCounts: sent.denominationCounts,
          cashTotal: sent.cashTotal,
          status: sent.status,
        );
      },
    );
    when(() => repo.addLineItem(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as AuditLineItem,
    );
    when(() => repo.commit(any(), committedByStaffId: any(named: 'committedByStaffId'))).thenAnswer(
      (_) async => AuditRegister(id: 'reg1', date: DateTime.now(), branchId: 'branch1'),
    );

    await _pumpScreen(tester, repo: repo);
    await _selectBranch(tester);

    await tester.enterText(find.byKey(const Key('denomField_100')), '5');
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('addLineItem_expense')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('addLineItem_expense')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('lineItemName_expense_0')), 'Electricity');
    await tester.enterText(find.byKey(const Key('lineItemAmount_expense_0')), '450');
    await tester.pump();

    await _tapCommit(tester);

    final createdArg = verify(() => repo.create(captureAny())).captured.single as AuditRegister;
    expect(createdArg.branchId, 'branch1');
    expect(createdArg.denominationCounts, {100: 5});
    expect(createdArg.status, AuditRegisterStatus.draft);

    final lineItemArg = verify(() => repo.addLineItem(captureAny())).captured.single as AuditLineItem;
    expect(lineItemArg.auditRegisterId, 'reg1');
    expect(lineItemArg.name, 'Electricity');
    expect(lineItemArg.amount, 450);

    verify(() => repo.commit('reg1', committedByStaffId: any(named: 'committedByStaffId'))).called(1);
    expect(find.text('Register committed'), findsOneWidget);
  });
}
