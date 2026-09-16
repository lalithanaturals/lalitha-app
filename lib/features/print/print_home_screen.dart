import 'package:flutter/material.dart';

import 'estimate/estimate_screen.dart';
import 'price_tag/price_tag_screen.dart';

/// Landing screen for the Print module. Lists the individual print tools;
/// as more of the original app's screens (coupons, location/visiting
/// cards, custom text) are migrated they get a tile here too.
class PrintHomeScreen extends StatelessWidget {
  const PrintHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lalitha Naturals — Print')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ToolTile(
            key: const Key('priceTagTile'),
            icon: Icons.sell_outlined,
            title: 'Price Tag',
            subtitle: 'MRP, discount, final price',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PriceTagScreen()),
            ),
          ),
          _ToolTile(
            key: const Key('estimateTile'),
            icon: Icons.receipt_long_outlined,
            title: 'Estimate',
            subtitle: 'Quick items bill for a customer',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EstimateScreen()),
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
