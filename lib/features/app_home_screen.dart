import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/providers.dart';
import '../l10n/generated/app_localizations.dart';
import 'denomination/denomination_home_screen.dart';
import 'print/print_home_screen.dart';
import 'scrap/calculator/calculator_screen.dart';
import 'stock/stock_home_screen.dart';

/// Suite-wide entry point: one app, one tile per module, per the master
/// plan's "one Flutter app, four modules" recommendation. All four
/// modules — Print, Stock-transfer, scrap-calc, Denomination — are live.
class AppHomeScreen extends ConsumerWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appHomeTitle),
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            tooltip: l10n.logoutButton,
            onPressed: () => ref.read(authRepositoryProvider).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ModuleTile(
            key: const Key('printModuleTile'),
            color: AppColors.print,
            icon: Icons.print_outlined,
            title: l10n.printModuleTitle,
            subtitle: l10n.printModuleSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrintHomeScreen()),
            ),
          ),
          _ModuleTile(
            key: const Key('stockModuleTile'),
            color: AppColors.stock,
            icon: Icons.inventory_outlined,
            title: l10n.stockModuleTitle,
            subtitle: l10n.stockModuleSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StockHomeScreen()),
            ),
          ),
          _ModuleTile(
            key: const Key('scrapModuleTile'),
            color: AppColors.scrap,
            icon: Icons.calculate_outlined,
            title: l10n.scrapModuleTitle,
            subtitle: l10n.scrapModuleSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalculatorScreen()),
            ),
          ),
          _ModuleTile(
            key: const Key('denominationModuleTile'),
            color: AppColors.denomination,
            icon: Icons.currency_rupee_outlined,
            title: l10n.denominationModuleTitle,
            subtitle: l10n.denominationModuleSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DenominationHomeScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A module tile with a colored circular icon badge — carries each module's
/// original brand color (see [AppColors]) into the suite's home screen so
/// the four modules stay visually distinct the way their separate apps were.
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }
}
