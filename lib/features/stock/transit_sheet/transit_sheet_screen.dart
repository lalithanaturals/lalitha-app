import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/inventory.dart';
import '../../../core/models/staff.dart';
import '../../../core/models/transit_sheet.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'transit_sheet_providers.dart';

class _ItemRowDraft {
  _ItemRowDraft() : quantityController = TextEditingController(text: '1');

  String? itemId;
  final TextEditingController quantityController;

  void dispose() => quantityController.dispose();
}

class TransitSheetScreen extends ConsumerStatefulWidget {
  const TransitSheetScreen({super.key});

  @override
  ConsumerState<TransitSheetScreen> createState() => _TransitSheetScreenState();
}

class _TransitSheetScreenState extends ConsumerState<TransitSheetScreen> {
  String? _fromBranchId;
  String? _toBranchId;
  String? _staffId;
  final List<_ItemRowDraft> _rows = [_ItemRowDraft()];
  bool _dispatching = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_ItemRowDraft()));

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index).dispose();
      if (_rows.isEmpty) _rows.add(_ItemRowDraft());
    });
  }

  Future<void> _dispatch(List<InventoryItem> allItems) async {
    final l10n = AppLocalizations.of(context)!;
    if (_fromBranchId == null || _toBranchId == null) {
      setState(() => _errorMessage = l10n.selectFromAndToBranchError);
      return;
    }
    if (_fromBranchId == _toBranchId) {
      setState(() => _errorMessage = l10n.fromAndToBranchMustDifferError);
      return;
    }
    if (_staffId == null) {
      setState(() => _errorMessage = l10n.selectDispatchingStaffError);
      return;
    }
    final rowsWithItems = _rows.where((r) => r.itemId != null).toList();
    final selectedItemIds = rowsWithItems.map((r) => r.itemId).toSet();
    if (selectedItemIds.length != rowsWithItems.length) {
      setState(() => _errorMessage = l10n.duplicateTransitItemError);
      return;
    }
    final items = <TransitSheetItem>[];
    for (final row in rowsWithItems) {
      final qty = num.tryParse(row.quantityController.text);
      if (qty == null || qty <= 0) {
        setState(() => _errorMessage = l10n.invalidTransitQuantityError);
        return;
      }
      final item = allItems.firstWhere((i) => i.id == row.itemId);
      items.add(TransitSheetItem(itemId: item.id, itemName: item.name, quantity: qty));
    }
    if (items.isEmpty) {
      setState(() => _errorMessage = l10n.addAtLeastOneItemError);
      return;
    }

    setState(() {
      _dispatching = true;
      _errorMessage = null;
    });
    try {
      final sheet = TransitSheet(
        fromBranchId: _fromBranchId!,
        toBranchId: _toBranchId!,
        staffId: _staffId,
        status: TransitSheetStatus.dispatched,
        dispatchedAt: DateTime.now(),
        items: items,
      );
      await ref.read(transitSheetRepositoryProvider).create(sheet);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transitSheetDispatchedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToSaveError(e.toString()));
    } finally {
      if (mounted) setState(() => _dispatching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(transitSheetBranchesProvider);
    final itemsAsync = ref.watch(transitSheetAllItemsProvider);
    final AsyncValue<List<Staff>> staffAsync = _fromBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(transitSheetStaffForBranchProvider(_fromBranchId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transitSheetTileTitle),
        backgroundColor: AppColors.stock,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: branchesAsync.when(
          data: (branches) => itemsAsync.when(
            data: (allItems) => ListView(
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('fromBranchDropdown'),
                  initialValue: _fromBranchId,
                  decoration: InputDecoration(labelText: l10n.fromBranchLabel),
                  items: branches
                      .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _fromBranchId = value;
                    _staffId = null;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('toBranchDropdown'),
                  initialValue: _toBranchId,
                  decoration: InputDecoration(labelText: l10n.toBranchLabel),
                  items: branches
                      .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _toBranchId = value),
                ),
                const SizedBox(height: 12),
                staffAsync.when(
                  data: (staff) => DropdownButtonFormField<String>(
                    key: const Key('transitStaffDropdown'),
                    initialValue: _staffId,
                    decoration: InputDecoration(labelText: l10n.staffLabel),
                    items: staff
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _staffId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('$e'),
                ),
                const SizedBox(height: 20),
                Text(l10n.itemsLabel, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (var i = 0; i < _rows.length; i++) _buildRow(context, l10n, allItems, i),
                TextButton.icon(
                  key: const Key('addTransitItemButton'),
                  onPressed: _addRow,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addTransitItemLabel),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('dispatchButton'),
                  onPressed: _dispatching ? null : () => _dispatch(allItems),
                  child: _dispatching
                      ? const CircularProgressIndicator()
                      : Text(l10n.dispatchButton),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    AppLocalizations l10n,
    List<InventoryItem> allItems,
    int index,
  ) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              key: Key('transitItemDropdown_$index'),
              initialValue: row.itemId,
              decoration: InputDecoration(labelText: l10n.itemLabel),
              items: allItems
                  .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
                  .toList(),
              onChanged: (value) => setState(() => row.itemId = value),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: Key('transitItemQtyField_$index'),
              controller: row.quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.qtyLabel),
            ),
          ),
          IconButton(
            key: Key('removeTransitItemButton_$index'),
            onPressed: () => _removeRow(index),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}
