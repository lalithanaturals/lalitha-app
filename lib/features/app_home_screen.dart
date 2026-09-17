import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'denomination/denomination_home_screen.dart';
import 'print/print_home_screen.dart';
import 'scrap/calculator/calculator_screen.dart';
import 'stock/stock_home_screen.dart';

/// Suite-wide entry point: one app, one tile per module, per the master
/// plan's "one Flutter app, four modules" recommendation. All four
/// modules — Print, Stock-transfer, scrap-calc, Denomination — are live.
class AppHomeScreen extends StatelessWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appHomeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              key: const Key('printModuleTile'),
              leading: const Icon(Icons.print_outlined),
              title: Text(l10n.printModuleTitle),
              subtitle: Text(l10n.printModuleSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrintHomeScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('stockModuleTile'),
              leading: const Icon(Icons.inventory_outlined),
              title: Text(l10n.stockModuleTitle),
              subtitle: Text(l10n.stockModuleSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StockHomeScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('scrapModuleTile'),
              leading: const Icon(Icons.calculate_outlined),
              title: Text(l10n.scrapModuleTitle),
              subtitle: Text(l10n.scrapModuleSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalculatorScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('denominationModuleTile'),
              leading: const Icon(Icons.currency_rupee_outlined),
              title: Text(l10n.denominationModuleTitle),
              subtitle: Text(l10n.denominationModuleSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DenominationHomeScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
