import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/price_tag.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
import 'price_tag_providers.dart';

class PriceTagScreen extends ConsumerStatefulWidget {
  const PriceTagScreen({super.key});

  @override
  ConsumerState<PriceTagScreen> createState() => _PriceTagScreenState();
}

class _PriceTagScreenState extends ConsumerState<PriceTagScreen> {
  final _mrpController = TextEditingController();
  final _discountValueController = TextEditingController();
  DiscountType _discountType = DiscountType.percent;
  String? _selectedBranchId;
  String? _selectedStaffId;
  String? _selectedProductId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mrpController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  num get _mrp => num.tryParse(_mrpController.text) ?? 0;
  num get _discountValue => num.tryParse(_discountValueController.text) ?? 0;

  num get _finalPrice => calculateFinalPrice(
        mrp: _mrp,
        discountType: _discountType,
        discountValue: _discountValue,
      );

  Future<void> _save() async {
    if (_selectedBranchId == null || _selectedProductId == null) {
      setState(() => _errorMessage = 'Select a branch and a product first.');
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final tag = PriceTag.compute(
        productId: _selectedProductId!,
        mrp: _mrp,
        discountType: _discountType,
        discountValue: _discountValue,
        branchId: _selectedBranchId!,
        staffId: _selectedStaffId,
      );
      await ref.read(priceTagRepositoryProvider).create(tag);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price tag saved')),
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
    final branchesAsync = ref.watch(branchesProvider);
    final productsAsync = ref.watch(productsProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(staffForBranchProvider(_selectedBranchId!));

    return Scaffold(
      appBar: AppBar(title: const Text('Price Tag')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('branchDropdown'),
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
                key: const Key('staffDropdown'),
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
            productsAsync.when(
              data: (products) => DropdownButtonFormField<String>(
                key: const Key('productDropdown'),
                initialValue: _selectedProductId,
                decoration: const InputDecoration(labelText: 'Product'),
                items: products
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.brandName)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedProductId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load products: $e'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('mrpField'),
              controller: _mrpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'MRP'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SegmentedButton<DiscountType>(
              key: const Key('discountTypeSelector'),
              segments: const [
                ButtonSegment(value: DiscountType.percent, label: Text('% Off')),
                ButtonSegment(value: DiscountType.flat, label: Text('Flat Off')),
              ],
              selected: {_discountType},
              onSelectionChanged: (selection) => setState(() => _discountType = selection.first),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('discountValueField'),
              controller: _discountValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _discountType == DiscountType.percent ? 'Discount %' : 'Discount Amount',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Price: ₹${_finalPrice.toStringAsFixed(2)}',
              key: const Key('finalPriceText'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('saveButton'),
              onPressed: _saving ? null : _save,
              child: _saving ? const CircularProgressIndicator() : const Text('Save & Print'),
            ),
          ],
        ),
      ),
    );
  }
}
