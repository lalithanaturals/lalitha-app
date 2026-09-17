import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'inventory/inventory_screen.dart';
import 'transit_sheet/transit_sheet_screen.dart';

/// Landing screen for the Stock-transfer module (inventory counts + transit
/// sheets between branches).
class StockHomeScreen extends StatelessWidget {
  const StockHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stockHomeTitle),
        backgroundColor: AppColors.stock,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              key: const Key('inventoryTile'),
              leading: const CircleAvatar(
                backgroundColor: AppColors.stock,
                child: Icon(Icons.inventory_2_outlined, color: Colors.white),
              ),
              title: Text(l10n.inventoryTileTitle),
              subtitle: Text(l10n.inventoryTileSubtitle),
              trailing: const Icon(Icons.chevron_right, color: AppColors.stock),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              key: const Key('transitSheetTile'),
              leading: const CircleAvatar(
                backgroundColor: AppColors.stock,
                child: Icon(Icons.local_shipping_outlined, color: Colors.white),
              ),
              title: Text(l10n.transitSheetTileTitle),
              subtitle: Text(l10n.transitSheetTileSubtitle),
              trailing: const Icon(Icons.chevron_right, color: AppColors.stock),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransitSheetScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
