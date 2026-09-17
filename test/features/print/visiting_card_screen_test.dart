import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/custom_print.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/custom_print_repository.dart';
import 'package:lalitha_app/features/print/visiting_card/visiting_card_providers.dart';
import 'package:lalitha_app/features/print/visiting_card/visiting_card_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockCustomPrintRepository extends Mock implements CustomPrintRepository {}

const _branch1 = Branch(id: 'branch1', name: 'Gajuwaka', address: 'MIG-20, Vuda Colony, Gajuwaka');
const _branch2 = Branch(id: 'branch2', name: 'Kurmannapalem', address: 'Vuda phase 7, Gajuwaka');

Future<void> _pumpScreen(
  WidgetTester tester, {
  required CustomPrintRepository repo,
  List<Branch> branches = const [_branch1, _branch2],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        visitingCardBranchesProvider.overrideWith((ref) async => branches),
        customPrintRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const VisitingCardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CustomPrint(printType: PrintType.visitingCard, content: {}, branchId: 'fallback'),
    );
  });

  testWidgets('preview shows both branch addresses and business info', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    expect(find.text('Lalitha Naturals'), findsOneWidget);
    expect(find.textContaining('MIG-20, Vuda Colony, Gajuwaka'), findsOneWidget);
    expect(find.textContaining('Vuda phase 7, Gajuwaka'), findsOneWidget);
    expect(find.textContaining('9676287766'), findsOneWidget);
  });

  testWidgets('shows a validation message when printing without a branch selected', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.ensureVisible(find.byKey(const Key('printVisitingCardButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('printVisitingCardButton')));
    await tester.pump();

    expect(find.textContaining('Select a branch first'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('printing calls the repository with a visiting_card covering both branches', (tester) async {
    final repo = _MockCustomPrintRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('visitingCardBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('printVisitingCardButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('printVisitingCardButton')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.create(captureAny())).captured;
    expect(captured, hasLength(1));
    final print = captured.first as CustomPrint;
    expect(print.printType, PrintType.visitingCard);
    expect(print.branchId, 'branch1');
    final branchesInContent = print.content['branches'] as List;
    expect(branchesInContent, hasLength(2));
    expect(find.text('Visiting card printed'), findsOneWidget);
  });
}
