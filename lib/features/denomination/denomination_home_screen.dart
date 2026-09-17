import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'archive/archive_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'register/register_screen.dart';

/// Landing screen for the Denomination module. Register entry/commit,
/// Archive/Search, and the BI Dashboard are live; exports
/// (JPEG/PDF/Thermal/WhatsApp) — Denomination/PROJECT_PLAN.md §4 — are not
/// yet implemented.
class DenominationHomeScreen extends StatelessWidget {
  const DenominationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.denominationModuleTitle),
        backgroundColor: AppColors.denomination,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              key: const Key('registerEntryTile'),
              leading: const CircleAvatar(
                backgroundColor: AppColors.denomination,
                child: Icon(Icons.receipt_long_outlined, color: Colors.white),
              ),
              title: Text(l10n.registerEntryTitle),
              subtitle: Text(l10n.denominationModuleSubtitle),
              trailing: const Icon(Icons.chevron_right, color: AppColors.denomination),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              key: const Key('archiveTile'),
              leading: const CircleAvatar(
                backgroundColor: AppColors.denomination,
                child: Icon(Icons.folder_outlined, color: Colors.white),
              ),
              title: Text(l10n.archiveTileTitle),
              subtitle: Text(l10n.archiveTileSubtitle),
              trailing: const Icon(Icons.chevron_right, color: AppColors.denomination),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              key: const Key('dashboardTile'),
              leading: const CircleAvatar(
                backgroundColor: AppColors.denomination,
                child: Icon(Icons.bar_chart_outlined, color: Colors.white),
              ),
              title: Text(l10n.dashboardTileTitle),
              subtitle: Text(l10n.dashboardTileSubtitle),
              trailing: const Icon(Icons.chevron_right, color: AppColors.denomination),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
