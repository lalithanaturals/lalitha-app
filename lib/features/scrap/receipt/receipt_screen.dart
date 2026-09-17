import 'package:flutter/material.dart';

import '../../../core/exchange_rates.dart';
import '../../../core/models/exchange_record.dart';
import '../../../l10n/generated/app_localizations.dart';

/// A read-only, thermal-receipt-styled preview of an [ExchangeRecord] —
/// mirrors the original app's printed receipt layout. Actual native ESC/POS
/// printing is deferred suite-wide (master plan Phase 3); for now this is
/// the "print preview" scrap-calc/PROJECT_PLAN.md §4 #4 calls for.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.record});

  final ExchangeRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusLabel =
        record.status == ExchangeStatus.order ? l10n.statusOrderLabel : l10n.statusEstimateLabel;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Lalitha Naturals', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (record.displayId != null)
              Text('${l10n.displayIdLabel}: ${record.displayId}',
                  key: const Key('receiptDisplayIdText')),
            Text('${l10n.customerLabel}: ${record.customerName}'),
            if (record.customerPhone.isNotEmpty) Text(record.customerPhone),
            Text(statusLabel, key: const Key('receiptStatusText')),
            const Divider(height: 24),
            if (record.alWeights.isNotEmpty) ...[
              _buildMaterialSection(context, l10n, 'al', 'Aluminum', record.alTotals, record.alWeights,
                  record.alHandles),
              const SizedBox(height: 16),
            ],
            if (record.stWeights.isNotEmpty) ...[
              _buildMaterialSection(
                  context, l10n, 'st', 'Steel', record.stTotals, record.stWeights, record.stHandles),
              const SizedBox(height: 16),
            ],
            const Divider(height: 24),
            Text(
              l10n.grandTotalLabel('₹${record.netTotalAmount.toStringAsFixed(2)}'),
              key: const Key('receiptGrandTotalText'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialSection(
    BuildContext context,
    AppLocalizations l10n,
    String materialKey,
    String materialName,
    MaterialTotals totals,
    List<num> weights,
    num handles,
  ) {
    final rate = ExchangeRates.ratePerKg[materialKey]!;
    return Column(
      key: Key('receiptMaterialSection_$materialKey'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$materialName (₹${rate.toStringAsFixed(0)}/kg)',
            style: Theme.of(context).textTheme.titleMedium),
        Text('${l10n.weightEntriesLabel}: ${weights.map((w) => w.toString()).join(', ')}'),
        Text('${l10n.handlesLabel}: $handles'),
        Text('${l10n.grossWeightLabel}: ${totals.grossWeightKg.toStringAsFixed(2)} kg'),
        Text('${l10n.handlesDeductionLabel}: ${totals.handlesDeductionKg.toStringAsFixed(2)} kg'),
        Text('${l10n.netWeightLabel}: ${totals.netWeightKg.toStringAsFixed(2)} kg'),
        Text(
          '${l10n.materialCostLabel}: ₹${totals.cost.toStringAsFixed(2)}',
          key: Key('receiptMaterialCost_$materialKey'),
        ),
      ],
    );
  }
}
