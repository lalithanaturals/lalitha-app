import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/custom_print.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/custom_print_repository.dart';
import 'package:lalitha_app/features/print/location_card/location_card_providers.dart';
import 'package:lalitha_app/features/print/location_card/location_card_screen.dart';
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
        locationCardBranchesProvider.overrideWith((ref) async => branches),
        customPrintRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const LocationCardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CustomPrint(printType: PrintType.locationCard, content: {}, branchId: 'fallback'),
    );
  });

  testWidgets('print button is disabled until a branch is selected', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    final button = tester.widget<FilledButton>(find.byKey(const Key('printLocationCardButton')));
    expect(button.onPressed, isNull);
    expect(find.byKey(const Key('locationCardPreview')), findsNothing);
  });

  testWidgets('selecting a branch shows its name and address in the preview', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('locationCardBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('locationCardPreview')), findsOneWidget);
    expect(find.textContaining('MIG-20, Vuda Colony, Gajuwaka'), findsOneWidget);
  });

  testWidgets('printing the selected branch calls the repository with a location_card', (tester) async {
    final repo = _MockCustomPrintRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('locationCardBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('printLocationCardButton')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.create(captureAny())).captured;
    expect(captured, hasLength(1));
    final print = captured.first as CustomPrint;
    expect(print.printType, PrintType.locationCard);
    expect(print.branchId, 'branch1');
    expect(print.content['branchName'], 'Gajuwaka');
    expect(find.text('Location card printed'), findsOneWidget);
  });

  testWidgets('Print Both Branches calls the repository once per branch', (tester) async {
    final repo = _MockCustomPrintRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.ensureVisible(find.byKey(const Key('printBothBranchesButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('printBothBranchesButton')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.create(captureAny())).captured;
    expect(captured, hasLength(2));
    final branchIds = captured.map((c) => (c as CustomPrint).branchId).toSet();
    expect(branchIds, {'branch1', 'branch2'});
  });
}
