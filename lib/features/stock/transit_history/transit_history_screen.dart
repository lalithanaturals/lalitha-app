import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/branch.dart';
import '../../../core/models/transit_sheet.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'transit_history_providers.dart';

/// Lists every transit sheet where the selected branch is either the
/// sender or the receiver — the "where can I see dispatched items?" screen.
/// A branch on the receiving end of a still-`dispatched` sheet gets a "Mark
/// Received" action (TransitSheetRepository.updateStatus, already existed
/// but had no UI before this screen).
class TransitHistoryScreen extends ConsumerStatefulWidget {
  const TransitHistoryScreen({super.key});

  @override
  ConsumerState<TransitHistoryScreen> createState() => _TransitHistoryScreenState();
}

class _TransitHistoryScreenState extends ConsumerState<TransitHistoryScreen> {
  String? _selectedBranchId;

  Future<void> _markReceived(TransitSheet sheet) async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(transitSheetRepositoryProvider).updateStatus(sheet.id!, TransitSheetStatus.received);
    ref.invalidate(transitHistorySheetsProvider(_selectedBranchId!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transitReceivedMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(transitHistoryBranchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transitHistoryTitle),
        backgroundColor: AppColors.stock,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('transitHistoryBranchDropdown'),
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
            Expanded(
              child: _selectedBranchId == null
                  ? const SizedBox.shrink()
                  : _buildSheetList(l10n, branchesAsync.value ?? const []),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetList(AppLocalizations l10n, List<Branch> branches) {
    final sheetsAsync = ref.watch(transitHistorySheetsProvider(_selectedBranchId!));
    return sheetsAsync.when(
      data: (sheets) {
        if (sheets.isEmpty) {
          return Text(l10n.noTransitSheetsMessage, key: const Key('noTransitSheetsText'));
        }
        String branchName(String id) => branches.firstWhere(
              (b) => b.id == id,
              orElse: () => Branch(id: id, name: id),
            ).name;
        return ListView.builder(
          itemCount: sheets.length,
          itemBuilder: (context, index) => _buildSheetTile(l10n, sheets[index], branchName),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
    );
  }

  Widget _buildSheetTile(
    AppLocalizations l10n,
    TransitSheet sheet,
    String Function(String) branchName,
  ) {
    final statusLabel = switch (sheet.status) {
      TransitSheetStatus.dispatched => l10n.statusDispatchedLabel,
      TransitSheetStatus.received => l10n.statusReceivedLabel,
      TransitSheetStatus.draft => l10n.statusDraftLabel,
    };
    final canMarkReceived =
        sheet.status == TransitSheetStatus.dispatched && sheet.toBranchId == _selectedBranchId;
    return Card(
      key: Key('transitHistoryTile_${sheet.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        key: Key('transitHistoryExpansion_${sheet.id}'),
        title: Text(l10n.transitSheetSummaryLabel(branchName(sheet.fromBranchId), branchName(sheet.toBranchId))),
        subtitle: Text(statusLabel),
        children: [
          Consumer(
            builder: (context, ref, _) {
              final itemsAsync = ref.watch(transitHistoryItemsProvider(sheet.id!));
              return itemsAsync.when(
                data: (items) => Column(
                  children: [
                    for (final item in items)
                      ListTile(
                        dense: true,
                        title: Text(item.itemName.isEmpty ? item.itemId : item.itemName),
                        trailing: Text('${item.quantity}'),
                      ),
                    if (canMarkReceived)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: FilledButton(
                          key: Key('markReceivedButton_${sheet.id}'),
                          onPressed: () => _markReceived(sheet),
                          child: Text(l10n.markReceivedButton),
                        ),
                      ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('$e'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
