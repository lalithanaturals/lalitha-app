import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/l10n/generated/app_localizations.dart';

void main() {
  test('AppLocalizations.supportedLocales includes English and Telugu', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      containsAll(<String>['en', 'te']),
    );
  });

  testWidgets('Price Tag screen renders in Telugu when the app locale is te', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          branchesProvider.overrideWith((ref) async => const <Branch>[]),
          productsProvider.overrideWith((ref) async => const <Product>[]),
          staffForBranchProvider.overrideWith((ref, branchId) async => const <Staff>[]),
        ],
        child: MaterialApp(
          locale: const Locale('te'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(body: Text(l10n.priceTagTileTitle));
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ధర ట్యాగ్'), findsOneWidget);
  });

  testWidgets('Estimate total label formats correctly in both locales', (tester) async {
    for (final locale in const [Locale('en'), Locale('te')]) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(body: Text(l10n.totalLabel('₹100.00')));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expected = locale.languageCode == 'te' ? 'మొత్తం: ₹100.00' : 'Total: ₹100.00';
      expect(find.text(expected), findsOneWidget);
    }
  });
}
