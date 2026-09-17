import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'coupon/coupon_screen.dart';
import 'custom_text/custom_text_screen.dart';
import 'estimate/estimate_screen.dart';
import 'location_card/location_card_screen.dart';
import 'price_tag/price_tag_screen.dart';
import 'visiting_card/visiting_card_screen.dart';

/// Landing screen for the Print module. Lists the individual print tools —
/// this now covers every screen from the original Print app.
class PrintHomeScreen extends StatelessWidget {
  const PrintHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.printHomeTitle),
        backgroundColor: AppColors.print,
        foregroundColor: Colors.white,
      ),
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
          _ToolTile(
            key: const Key('visitingCardTile'),
            icon: Icons.badge_outlined,
            title: l10n.visitingCardTileTitle,
            subtitle: l10n.visitingCardTileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VisitingCardScreen()),
            ),
          ),
          _ToolTile(
            key: const Key('customTextTile'),
            icon: Icons.text_fields_outlined,
            title: l10n.customTextTileTitle,
            subtitle: l10n.customTextTileSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomTextScreen()),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.print,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.print),
        onTap: onTap,
      ),
    );
  }
}
