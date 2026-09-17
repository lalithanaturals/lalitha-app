import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/audit_register.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../receipt/denomination_receipt_screen.dart';
import 'archive_providers.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(archiveBranchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archiveTitle),
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
                key: const Key('archiveBranchDropdown'),
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
            const SizedBox(height: 12),
            Expanded(child: _buildRegisterList(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterList(AppLocalizations l10n) {
    if (_selectedBranchId == null) return const SizedBox.shrink();
    final registersAsync = ref.watch(archiveRegistersProvider(_selectedBranchId!));
    return registersAsync.when(
      data: (registers) {
        if (registers.isEmpty) {
          return Text(l10n.noRegistersMessage, key: const Key('noRegistersText'));
        }
        return ListView.builder(
          itemCount: registers.length,
          itemBuilder: (context, index) => _buildRegisterTile(l10n, registers[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
    );
  }

  Widget _buildRegisterTile(AppLocalizations l10n, AuditRegister register) {
    final statusLabel = register.status == AuditRegisterStatus.committed
        ? l10n.statusCommittedLabel
        : l10n.statusDraftLabel;
    final dateStr =
        '${register.date.year}-${register.date.month.toString().padLeft(2, '0')}-${register.date.day.toString().padLeft(2, '0')}';
    return Card(
      key: Key('archiveRegisterTile_${register.id}'),
      child: ExpansionTile(
        key: Key('archiveRegisterExpansion_${register.id}'),
        title: Text('$dateStr — $statusLabel'),
        subtitle: Text(
          '${l10n.cashTotalLabel}: ₹${register.cashTotal.toStringAsFixed(2)} · '
          '${l10n.closingBalanceLabel}: ₹${register.closingBalance.toStringAsFixed(2)}',
        ),
        children: [_buildLineItems(l10n, register)],
      ),
    );
  }

  Widget _buildLineItems(AppLocalizations l10n, AuditRegister register) {
    final registerId = register.id!;
    final itemsAsync = ref.watch(archiveLineItemsProvider(registerId));
    return itemsAsync.when(
      data: (items) {
        return Column(
          key: Key('lineItemsList_$registerId'),
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.noLineItemsMessage, key: Key('noLineItemsText_$registerId')),
              )
            else
              for (final item in items)
                ListTile(
                  dense: true,
                  title: Text(item.name),
                  trailing: Text('₹${item.amount.toStringAsFixed(2)}'),
                ),
            TextButton(
              key: Key('viewReceiptButton_$registerId'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DenominationReceiptScreen(register: register, lineItems: items),
                ),
              ),
              child: Text(l10n.viewReceiptButton),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text('$e'),
      ),
    );
  }
}
