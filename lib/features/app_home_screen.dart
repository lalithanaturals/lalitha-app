import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'print/print_home_screen.dart';
import 'stock/stock_home_screen.dart';

/// Suite-wide entry point: one app, one tile per module, per the master
/// plan's "one Flutter app, four modules" recommendation. Print and Stock
/// are live; scrap-calc and Denomination modules get a tile here once
/// they're migrated.
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
        ],
      ),
    );
  }
}
