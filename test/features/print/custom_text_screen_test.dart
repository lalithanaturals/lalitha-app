import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/custom_print.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/custom_print_repository.dart';
import 'package:lalitha_app/features/print/custom_text/custom_text_providers.dart';
import 'package:lalitha_app/features/print/custom_text/custom_text_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockCustomPrintRepository extends Mock implements CustomPrintRepository {}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');

Future<void> _pumpScreen(WidgetTester tester, {required CustomPrintRepository repo}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customTextBranchesProvider.overrideWith((ref) async => [_branch]),
        customPrintRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const CustomTextScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapPrint(WidgetTester tester) async {
  // The button may not be mounted yet (lazy ListView viewport culling), so
  // ensureVisible (which needs the element to already exist) can't find it —
  // scrollUntilVisible drags the list until the finder actually matches.
  await tester.scrollUntilVisible(
    find.byKey(const Key('printCustomTextButton')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('printCustomTextButton')));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CustomPrint(printType: PrintType.customText, content: {}, branchId: 'fallback'),
    );
  });

  testWidgets('validates branch selection before printing', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('customTextField')), 'Happy Diwali!');
    await tester.pump();
    await _tapPrint(tester);

    expect(find.textContaining('Select a branch first'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('validates non-empty text before printing', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('customTextBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await _tapPrint(tester);

    expect(find.textContaining('Enter some text first'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('printing sends text, alignment, bold, and font size in content', (tester) async {
    final repo = _MockCustomPrintRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('customTextBranchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('customTextField')), 'Happy Diwali!');
    await tester.tap(find.text('Right'));
    await tester.tap(find.byKey(const Key('boldSwitch')));
    await tester.pump();

    await _tapPrint(tester);

    final captured = verify(() => repo.create(captureAny())).captured;
    expect(captured, hasLength(1));
    final print = captured.first as CustomPrint;
    expect(print.printType, PrintType.customText);
    expect(print.branchId, 'branch1');
    expect(print.content['text'], 'Happy Diwali!');
    expect(print.content['alignment'], 'right');
    expect(print.content['bold'], true);
    expect(find.text('Custom text printed'), findsOneWidget);
  });

  testWidgets('preview reflects the entered text', (tester) async {
    final repo = _MockCustomPrintRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('customTextField')), 'Preview me');
    await tester.pump();

    final previewFinder = find.descendant(
      of: find.byKey(const Key('customTextPreview')),
      matching: find.text('Preview me'),
    );
    expect(previewFinder, findsOneWidget);
  });
}
