import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/exchange_record.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/exchange_record_repository.dart';
import 'package:lalitha_app/features/scrap/search/search_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockExchangeRecordRepository extends Mock implements ExchangeRecordRepository {}

Future<void> _pumpScreen(WidgetTester tester, {required ExchangeRecordRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [exchangeRecordRepositoryProvider.overrideWithValue(repo)],
      child: localizedTestApp(home: const SearchScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('searching shows the returned results', (tester) async {
    final repo = _MockExchangeRecordRepository();
    when(() => repo.search(any())).thenAnswer((_) async => const [
          ExchangeRecord(
            id: 'rec1',
            displayId: 'EX-1',
            branchId: 'branch1',
            customerName: 'Ravi Kumar',
            customerPhone: '9999900000',
            status: ExchangeStatus.estimate,
            alWeights: [10],
          ),
        ]);
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('searchQueryField')), 'Ravi');
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('searchResultTile_rec1')), findsOneWidget);
    expect(find.textContaining('EX-1'), findsOneWidget);
    expect(find.textContaining('Ravi Kumar'), findsOneWidget);
  });

  testWidgets('shows a no-results message when the search returns nothing', (tester) async {
    final repo = _MockExchangeRecordRepository();
    when(() => repo.search(any())).thenAnswer((_) async => const []);
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('searchQueryField')), 'nobody');
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('noResultsText')), findsOneWidget);
  });

  testWidgets('estimate results show a Convert to Order action; order results do not', (tester) async {
    final repo = _MockExchangeRecordRepository();
    when(() => repo.search(any())).thenAnswer((_) async => const [
          ExchangeRecord(id: 'est1', branchId: 'branch1', status: ExchangeStatus.estimate),
          ExchangeRecord(id: 'ord1', branchId: 'branch1', status: ExchangeStatus.order),
        ]);
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('convertToOrderButton_est1')), findsOneWidget);
    expect(find.byKey(const Key('convertToOrderButton_ord1')), findsNothing);
  });

  testWidgets('converting to order calls the repository and updates the tile', (tester) async {
    final repo = _MockExchangeRecordRepository();
    when(() => repo.search(any())).thenAnswer((_) async => const [
          ExchangeRecord(id: 'est1', branchId: 'branch1', status: ExchangeStatus.estimate),
        ]);
    when(() => repo.convertToOrder('est1')).thenAnswer(
      (_) async => const ExchangeRecord(id: 'est1', branchId: 'branch1', status: ExchangeStatus.order),
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('convertToOrderButton_est1')));
    await tester.pumpAndSettle();

    verify(() => repo.convertToOrder('est1')).called(1);
    expect(find.byKey(const Key('convertToOrderButton_est1')), findsNothing);
    expect(find.text('Converted to order'), findsOneWidget);
  });
}
