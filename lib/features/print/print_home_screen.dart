import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'coupon/coupon_screen.dart';
import 'estimate/estimate_screen.dart';
import 'location_card/location_card_screen.dart';
import 'price_tag/price_tag_screen.dart';

/// Landing screen for the Print module. Lists the individual print tools;
/// as more of the original app's screens (visiting cards, custom text) are
/// migrated they get a tile here too.
class PrintHomeScreen extends StatelessWidget {
  const PrintHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.printHomeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolTile(
            key: const Key('priceTagTile'),
            icon: Icons.sell_outlined,
            title: l10n.priceTagTileTitle,
            subtitle: l10n.priceTagTileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PriceTagScreen()),
            ),
          ),
          _ToolTile(
            key: const Key('estimateTile'),
            icon: Icons.receipt_long_outlined,
            title: l10n.estimateTileTitle,
            subtitle: l10n.estimateTileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EstimateScreen()),
            ),
          ),
          _ToolTile(
            key: const Key('couponTile'),
            icon: Icons.local_offer_outlined,
            title: l10n.couponTileTitle,
            subtitle: l10n.couponTileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CouponScreen()),
            ),
          ),
          _ToolTile(
            key: const Key('locationCardTile'),
            icon: Icons.location_on_outlined,
            title: l10n.locationCardTileTitle,
            subtitle: l10n.locationCardTileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LocationCardScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
