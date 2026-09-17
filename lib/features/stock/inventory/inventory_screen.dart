import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/inventory.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'inventory_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String? _selectedBranchId;
  String? _selectedCategoryId;
  final Set<String> _updatingItemIds = {};
  String? _errorMessage;

  Future<void> _adjust(InventoryItem item, num current, num delta) async {
    final l10n = AppLocalizations.of(context)!;
    final branchId = _selectedBranchId;
    if (branchId == null) return;
    final next = current + delta;
    if (next < 0) return;

    setState(() {
      _updatingItemIds.add(item.id);
      _errorMessage = null;
    });
    try {
      await ref.read(inventoryRepositoryProvider).setStockQuantity(
            itemId: item.id,
            branchId: branchId,
            quantity: next,
          );
      ref.invalidate(stockForBranchProvider(branchId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.stockUpdatedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToUpdateStockError(e.toString()));
    } finally {
      if (mounted) setState(() => _updatingItemIds.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(inventoryBranchesProvider);
    final categoriesAsync = ref.watch(inventoryCategoriesProvider);
    final itemsAsync = _selectedCategoryId == null
        ? const AsyncValue.data(<InventoryItem>[])
        : ref.watch(itemsForCategoryProvider(_selectedCategoryId!));
    final stockAsync = _selectedBranchId == null
        ? const AsyncValue.data(<InventoryStock>[])
        : ref.watch(stockForBranchProvider(_selectedBranchId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryTileTitle),
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
                key: const Key('inventoryBranchDropdown'),
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
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                key: const Key('inventoryCategoryDropdown'),
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(labelText: l10n.categoryLabel),
                items: categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategoryId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: itemsAsync.when(
                data: (items) => stockAsync.when(
                  data: (stockRows) {
                    final quantities = {
                      for (final s in stockRows) s.itemId: s.quantity,
                    };
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final quantity = quantities[item.id] ?? 0;
                        final isUpdating = _updatingItemIds.contains(item.id);
                        return Card(
                          key: Key('inventoryItemTile_${item.id}'),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text('${l10n.currentStockLabel}: $quantity'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: Key('decrementButton_${item.id}'),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: (isUpdating || _selectedBranchId == null)
                                      ? null
                                      : () => _adjust(item, quantity, -1),
                                ),
                                if (isUpdating)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  Text('$quantity'),
                                IconButton(
                                  key: Key('incrementButton_${item.id}'),
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: (isUpdating || _selectedBranchId == null)
                                      ? null
                                      : () => _adjust(item, quantity, 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('$e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
