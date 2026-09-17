import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/audit_register.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedBranchId;

  String _categoryLabel(AppLocalizations l10n, AuditLineCategory category) => switch (category) {
        AuditLineCategory.expense => l10n.expenseCategoryLabel,
        AuditLineCategory.ownerBill => l10n.ownerBillCategoryLabel,
        AuditLineCategory.vendorBill => l10n.vendorBillCategoryLabel,
        AuditLineCategory.unbilled => l10n.unbilledCategoryLabel,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(dashboardBranchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        backgroundColor: AppColors.denomination,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('dashboardBranchDropdown'),
                initialValue: _selectedBranchId,
                decoration: InputDecoration(labelText: l10n.branchLabel),
                items: branches
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBranchId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildSummary(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    if (_selectedBranchId == null) return const SizedBox.shrink();

    final registersAsync = ref.watch(dashboardRegistersProvider(_selectedBranchId!));
    final lineItemsAsync = ref.watch(dashboardLineItemsProvider(_selectedBranchId!));

    return registersAsync.when(
      data: (registers) => lineItemsAsync.when(
        data: (lineItems) {
          final totalCash = registers.fold<num>(0, (sum, r) => sum + r.cashTotal);
          final categoryTotals = calculateCategoryTotals(lineItems);
          return ListView(
            children: [
              Text('${l10n.registerCountLabel}: ${registers.length}',
                  key: const Key('registerCountText')),
              const SizedBox(height: 8),
              Text(
                '${l10n.totalCashLabel}: ₹${totalCash.toStringAsFixed(2)}',
                key: const Key('totalCashText'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(l10n.categoryBreakdownLabel, style: Theme.of(context).textTheme.titleMedium),
              for (final category in AuditLineCategory.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_categoryLabel(l10n, category)),
                      Text(
                        '₹${(categoryTotals[category] ?? 0).toStringAsFixed(2)}',
                        key: Key('categoryTotal_${category.name}'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('$e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
    );
  }
}
