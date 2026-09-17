import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'archive/archive_screen.dart';
import 'register/register_screen.dart';

/// Landing screen for the Denomination module. Register entry/commit and
/// Archive/Search are live; exports (JPEG/PDF/Thermal/WhatsApp) and the BI
/// dashboard (Denomination/PROJECT_PLAN.md §4) are not yet implemented.
class DenominationHomeScreen extends StatelessWidget {
  const DenominationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.denominationModuleTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              key: const Key('registerEntryTile'),
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(l10n.registerEntryTitle),
              subtitle: Text(l10n.denominationModuleSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('archiveTile'),
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.archiveTileTitle),
              subtitle: Text(l10n.archiveTileSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
