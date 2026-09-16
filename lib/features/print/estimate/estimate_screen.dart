import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/estimate.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
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
    if (_selectedBranchId == null) {
      setState(() => _errorMessage = 'Select a branch first.');
      return;
    }
    final items = _draftItems;
    if (items.isEmpty) {
      setState(() => _errorMessage = 'Add at least one item.');
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
            ? 'Walk-in Customer'
            : _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        items: items,
      );
      await ref.read(estimateRepositoryProvider).create(estimate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estimate saved')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(estimateBranchesProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(estimateStaffForBranchProvider(_selectedBranchId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Estimate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('estimateBranchDropdown'),
                initialValue: _selectedBranchId,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: branches
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedBranchId = value;
                  _selectedStaffId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load branches: $e'),
            ),
            const SizedBox(height: 12),
            staffAsync.when(
              data: (staff) => DropdownButtonFormField<String>(
                key: const Key('estimateStaffDropdown'),
                initialValue: _selectedStaffId,
                decoration: const InputDecoration(labelText: 'Staff'),
                items: staff
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaffId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load staff: $e'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('customerNameField'),
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('customerPhoneField'),
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Customer Phone (optional)'),
            ),
            const SizedBox(height: 20),
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < _items.length; i++) _buildItemRow(i),
            TextButton.icon(
              key: const Key('addItemButton'),
              onPressed: _addItemRow,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
            const Divider(),
            Text(
              'Total: ₹${_total.toStringAsFixed(2)}',
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
              child: _saving ? const CircularProgressIndicator() : const Text('Save & Print'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int index) {
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
              decoration: const InputDecoration(labelText: 'Item'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: Key('itemQtyField_$index'),
              controller: draft.quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Qty'),
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
              decoration: const InputDecoration(labelText: 'Unit Price'),
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
