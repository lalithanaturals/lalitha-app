import 'package:flutter/material.dart';

import '../../../core/denomination_values.dart';
import '../../../core/models/audit_register.dart';
import '../../../l10n/generated/app_localizations.dart';

/// A read-only, thermal-receipt-styled preview of an [AuditRegister] and
/// its line items — mirrors the original app's "Standard Print View /
/// Thermal Receipt" export. JPEG/PDF/WhatsApp export and actual native
/// ESC/POS printing stay deferred (Denomination/PROJECT_PLAN.md §4,
/// master plan Phase 3), same pattern as every other module's receipt
/// preview.
class DenominationReceiptScreen extends StatelessWidget {
  const DenominationReceiptScreen({super.key, required this.register, required this.lineItems});

  final AuditRegister register;
  final List<AuditLineItem> lineItems;

  String _categoryLabel(AppLocalizations l10n, AuditLineCategory category) => switch (category) {
        AuditLineCategory.expense => l10n.expenseCategoryLabel,
        AuditLineCategory.ownerBill => l10n.ownerBillCategoryLabel,
        AuditLineCategory.vendorBill => l10n.vendorBillCategoryLabel,
        AuditLineCategory.unbilled => l10n.unbilledCategoryLabel,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusLabel = register.status == AuditRegisterStatus.committed
        ? l10n.statusCommittedLabel
        : l10n.statusDraftLabel;
    final dateStr = '${register.date.year}-'
        '${register.date.month.toString().padLeft(2, '0')}-'
        '${register.date.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.receiptTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Lalitha Naturals', style: Theme.of(context).textTheme.titleLarge),
            Text('${l10n.dateLabel}: $dateStr'),
            Text(statusLabel, key: const Key('denominationReceiptStatusText')),
            const Divider(height: 24),
            Text('${l10n.openingBalanceLabel}: ₹${register.openingBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(l10n.denominationCountsLabel, style: Theme.of(context).textTheme.titleMedium),
            for (final value in DenominationValues.values)
              if ((register.denominationCounts[value] ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹$value × ${register.denominationCounts[value]}'),
                      Text('₹${(value * register.denominationCounts[value]!).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
            const Divider(height: 24),
            Text(
              '${l10n.cashTotalLabel}: ₹${register.cashTotal.toStringAsFixed(2)}',
              key: const Key('denominationReceiptCashTotalText'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('${l10n.closingBalanceLabel}: ₹${register.closingBalance.toStringAsFixed(2)}'),
            if (lineItems.isNotEmpty) ...[
              const Divider(height: 24),
              for (final category in AuditLineCategory.values)
                if (lineItems.any((i) => i.category == category))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_categoryLabel(l10n, category),
                            style: Theme.of(context).textTheme.titleSmall),
                        for (final item in lineItems.where((i) => i.category == category))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.name),
                              Text('₹${item.amount.toStringAsFixed(2)}'),
                            ],
                          ),
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
