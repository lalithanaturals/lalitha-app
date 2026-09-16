import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/estimate.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'estimate_providers.dart';

/// One in-progress row in the "Quick Items" table — mirrors the original
/// Print app's ad-hoc item list, kept as editable text controllers until
/// Save converts the drafts into [EstimateItem]s.
class _ItemDraft {
  _ItemDraft()
      : nameController = TextEditingController(),
        quantityController = TextEditingController(text: '1'),
        priceController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  EstimateItem toItem() => EstimateItem(
        itemName: nameController.text.trim(),
        quantity: num.tryParse(quantityController.text) ?? 1,
        unitPrice: num.tryParse(priceController.text) ?? 0,
      );

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}

class EstimateScreen extends ConsumerStatefulWidget {
  const EstimateScreen({super.key});

  @override
  ConsumerState<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends ConsumerState<EstimateScreen> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final List<_ItemDraft> _items = [_ItemDraft()];
  String? _selectedBranchId;
  String? _selectedStaffId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  List<EstimateItem> get _draftItems =>
      _items.map((d) => d.toItem()).where((i) => i.itemName.isNotEmpty).toList();

  num get _total => calculateEstimateTotal(_draftItems);

  void _addItemRow() => setState(() => _items.add(_ItemDraft()));

  void _removeItemRow(int index) {
    setState(() {
      _items.removeAt(index).dispose();
      if (_items.isEmpty) _items.add(_ItemDraft());
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedBranchId == null) {
      setState(() => _errorMessage = l10n.selectBranchError);
      return;
    }
    final items = _draftItems;
    if (items.isEmpty) {
      setState(() => _errorMessage = l10n.addAtLeastOneItemError);
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final estimate = Estimate(
        branchId: _selectedBranchId!,
        staffId: _selectedStaffId,
        customerName: _customerNameController.text.trim().isEmpty
            ? l10n.walkInCustomer
            : _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        items: items,
      );
      await ref.read(estimateRepositoryProvider).create(estimate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.estimateSavedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToSaveError(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(estimateBranchesProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(estimateStaffForBranchProvider(_selectedBranchId!));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.estimateTileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('estimateBranchDropdown'),
                initialValue: _selectedBranchId,
                decoration: InputDecoration(labelText: l10n.branchLabel),
                items: branches
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedBranchId = value;
                  _selectedStaffId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),
            staffAsync.when(
              data: (staff) => DropdownButtonFormField<String>(
                key: const Key('estimateStaffDropdown'),
                initialValue: _selectedStaffId,
                decoration: InputDecoration(labelText: l10n.staffLabel),
                items: staff
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaffId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('customerNameField'),
              controller: _customerNameController,
              decoration: InputDecoration(labelText: l10n.customerNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('customerPhoneField'),
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.customerPhoneLabel),
            ),
            const SizedBox(height: 20),
            Text(l10n.itemsLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < _items.length; i++) _buildItemRow(context, l10n, i),
            TextButton.icon(
              key: const Key('addItemButton'),
              onPressed: _addItemRow,
              icon: const Icon(Icons.add),
              label: Text(l10n.addItemLabel),
            ),
            const Divider(),
            Text(
              l10n.totalLabel('₹${_total.toStringAsFixed(2)}'),
              key: const Key('estimateTotalText'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('saveEstimateButton'),
              onPressed: _saving ? null : _save,
              child: _saving ? const CircularProgressIndicator() : Text(l10n.saveAndPrint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, AppLocalizations l10n, int index) {
    final draft = _items[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              key: Key('itemNameField_$index'),
              controller: draft.nameController,
              decoration: InputDecoration(labelText: l10n.itemLabel),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: Key('itemQtyField_$index'),
              controller: draft.quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.qtyLabel),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              key: Key('itemPriceField_$index'),
              controller: draft.priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.unitPriceLabel),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            key: Key('removeItemButton_$index'),
            onPressed: () => _removeItemRow(index),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}
