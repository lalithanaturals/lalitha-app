import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/estimate.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/estimate_repository.dart';
import 'package:lalitha_app/features/print/estimate/estimate_providers.dart';
import 'package:lalitha_app/features/print/estimate/estimate_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockEstimateRepository extends Mock implements EstimateRepository {}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');
const _staff = Staff(id: 'staff1', name: 'Bhargav', branchId: 'branch1');

Future<void> _pumpScreen(WidgetTester tester, {required EstimateRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        estimateBranchesProvider.overrideWith((ref) async => [_branch]),
        estimateStaffForBranchProvider.overrideWith((ref, branchId) async => [_staff]),
        estimateRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const EstimateScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Estimate(branchId: 'fallback'));
  });

  testWidgets('starts with a single empty item row and a zero total', (tester) async {
    final repo = _MockEstimateRepository();
    await _pumpScreen(tester, repo: repo);

    expect(find.byKey(const Key('itemNameField_0')), findsOneWidget);
    expect(find.text('Total: ₹0.00'), findsOneWidget);
  });

  testWidgets('total updates live as item rows are filled in', (tester) async {
    final repo = _MockEstimateRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('itemNameField_0')), 'Ghee 500ml');
    await tester.enterText(find.byKey(const Key('itemQtyField_0')), '2');
    await tester.enterText(find.byKey(const Key('itemPriceField_0')), '350');
    await tester.pump();

    expect(find.text('Total: ₹700.00'), findsOneWidget);
  });

  testWidgets('adding a second row includes it in the total', (tester) async {
    final repo = _MockEstimateRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('itemNameField_0')), 'Ghee');
    await tester.enterText(find.byKey(const Key('itemQtyField_0')), '1');
    await tester.enterText(find.byKey(const Key('itemPriceField_0')), '100');
    await tester.pump();

    await tester.tap(find.byKey(const Key('addItemButton')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('itemNameField_1')), 'Honey');
    await tester.enterText(find.byKey(const Key('itemQtyField_1')), '1');
    await tester.enterText(find.byKey(const Key('itemPriceField_1')), '220');
    await tester.pump();

    expect(find.text('Total: ₹320.00'), findsOneWidget);
  });

  testWidgets('removing a row drops it from the total', (tester) async {
    final repo = _MockEstimateRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('addItemButton')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('itemNameField_0')), 'Ghee');
    await tester.enterText(find.byKey(const Key('itemPriceField_0')), '100');
    await tester.enterText(find.byKey(const Key('itemNameField_1')), 'Honey');
    await tester.enterText(find.byKey(const Key('itemPriceField_1')), '220');
    await tester.pump();
    expect(find.text('Total: ₹320.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('removeItemButton_1')));
    await tester.pump();

    expect(find.text('Total: ₹100.00'), findsOneWidget);
  });

  testWidgets('shows a validation message when saving without a branch selected', (tester) async {
    final repo = _MockEstimateRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('itemNameField_0')), 'Ghee');
    await tester.enterText(find.byKey(const Key('itemPriceField_0')), '100');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('saveEstimateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveEstimateButton')));
    await tester.pump();

    expect(find.textContaining('Select a branch'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('shows a validation message when saving with no items entered', (tester) async {
    final repo = _MockEstimateRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('estimateBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('saveEstimateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveEstimateButton')));
    await tester.pump();

    expect(find.textContaining('Add at least one item'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('saving with a branch and items calls the repository', (tester) async {
    final repo = _MockEstimateRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('estimateBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('itemNameField_0')), 'Ghee 500ml');
    await tester.enterText(find.byKey(const Key('itemQtyField_0')), '2');
    await tester.enterText(find.byKey(const Key('itemPriceField_0')), '350');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('saveEstimateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveEstimateButton')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.create(captureAny())).captured;
    expect(captured, hasLength(1));
    final estimate = captured.first as Estimate;
    expect(estimate.branchId, 'branch1');
    expect(estimate.items, hasLength(1));
    expect(estimate.totalAmount, 700);
    expect(find.text('Estimate saved'), findsOneWidget);
  });

  testWidgets('blank customer name falls back to Walk-in Customer', (tester) async {
    final repo = _MockEstimateRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('estimateBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('itemNameField_0')), 'Soap');
    await tester.enterText(find.byKey(const Key('itemPriceField_0')), '40');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('saveEstimateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveEstimateButton')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.create(captureAny())).captured;
    final estimate = captured.first as Estimate;
    expect(estimate.customerName, 'Walk-in Customer');
  });
}
