import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/exchange_record.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/exchange_record_repository.dart';
import 'package:lalitha_app/features/scrap/calculator/calculator_providers.dart';
import 'package:lalitha_app/features/scrap/calculator/calculator_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockExchangeRecordRepository extends Mock implements ExchangeRecordRepository {}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');
const _staff = Staff(id: 'staff1', name: 'Bhargav', branchId: 'branch1');

Future<void> _pumpScreen(WidgetTester tester, {required ExchangeRecordRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        calculatorBranchesProvider.overrideWith((ref) async => [_branch]),
        calculatorStaffForBranchProvider.overrideWith((ref, branchId) async => [_staff]),
        exchangeRecordRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const CalculatorScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapButton(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(find.byKey(key), 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

// The grand total sits below the fold on this info-dense screen (ListView
// viewport culling), so it isn't mounted until scrolled into view.
Future<void> _scrollToGrandTotal(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('grandTotalText')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ExchangeRecord(branchId: 'fallback'));
  });

  testWidgets('grand total updates live as an aluminum weight is entered', (tester) async {
    final repo = _MockExchangeRecordRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('weightField_al_0')), '10');
    await tester.pump();
    await _scrollToGrandTotal(tester);

    // 10kg * ₹150/kg = ₹1500.00
    expect(find.text('Grand Total: ₹1500.00'), findsOneWidget);
  });

  testWidgets('switching to steel shows the steel weight fields and its own rate', (tester) async {
    final repo = _MockExchangeRecordRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.text('Steel (₹50/kg)'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weightField_st_0')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('weightField_st_0')), '20');
    await tester.pump();
    await _scrollToGrandTotal(tester);

    // 20kg * ₹50/kg = ₹1000.00
    expect(find.text('Grand Total: ₹1000.00'), findsOneWidget);
  });

  testWidgets('incrementing handles reduces the net weight and cost', (tester) async {
    final repo = _MockExchangeRecordRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('weightField_al_0')), '10');
    await tester.pump();
    await tester.tap(find.byKey(const Key('incrementHandlesButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('incrementHandlesButton')));
    await tester.pump();

    final handlesText = tester.widget<Text>(find.byKey(const Key('handlesCountText')));
    expect(handlesText.data, '2');

    await _scrollToGrandTotal(tester);
    // handles=2 -> deduction 0.2kg -> net 9.8kg * 150 = 1470.00
    expect(find.text('Grand Total: ₹1470.00'), findsOneWidget);
  });

  testWidgets('shows a validation message when saving without a branch selected', (tester) async {
    final repo = _MockExchangeRecordRepository();
    await _pumpScreen(tester, repo: repo);

    await _tapButton(tester, const Key('getEstimationButton'));

    expect(find.textContaining('Select a branch first'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('Get Estimation creates a record with status estimate', (tester) async {
    final repo = _MockExchangeRecordRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('calculatorBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('weightField_al_0')), '5');
    await tester.pump();

    await _tapButton(tester, const Key('getEstimationButton'));

    final captured = verify(() => repo.create(captureAny())).captured;
    final record = captured.first as ExchangeRecord;
    expect(record.status, ExchangeStatus.estimate);
    expect(record.branchId, 'branch1');
    expect(record.alWeights, [5]);
    expect(find.text('Estimate saved'), findsOneWidget);
  });

  testWidgets('Submit Order creates a record with status order', (tester) async {
    final repo = _MockExchangeRecordRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('calculatorBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('weightField_al_0')), '5');
    await tester.pump();

    await _tapButton(tester, const Key('submitOrderButton'));

    final captured = verify(() => repo.create(captureAny())).captured;
    final record = captured.first as ExchangeRecord;
    expect(record.status, ExchangeStatus.order);
    expect(find.text('Order saved'), findsOneWidget);
  });

  testWidgets('tapping the search icon navigates to the Search screen', (tester) async {
    final repo = _MockExchangeRecordRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('openSearchButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('searchQueryField')), findsOneWidget);
  });
}
