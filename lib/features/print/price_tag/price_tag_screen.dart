import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/price_tag.dart';
import '../../../core/models/product.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
import '../../../core/repositories/product_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (_selectedBranchId == null || _selectedProductId == null) {
      setState(() => _errorMessage = l10n.selectBranchAndProductError);
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
          SnackBar(content: Text(l10n.priceTagSavedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToSaveError(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Matches the old app's "+ Add Brand Name" button — Price Tag's Product
  /// field is a dropdown of pre-existing `products` records, but the
  /// original app let anyone type a new brand name on the spot rather than
  /// requiring an admin to pre-populate a catalog. `products.createRule` is
  /// open to any authenticated user for the same reason (see
  /// lalitha-backend's 1700000024_relax_products_create_and_seed_staff.js).
  Future<void> _showAddProductDialog() async {
    final created = await showDialog<Product>(
      context: context,
      builder: (dialogContext) => _AddProductDialog(productRepository: ref.read(productRepositoryProvider)),
    );
    if (created != null) {
      // Await the refetch before selecting the new id — otherwise the
      // dropdown can briefly rebuild with the old cached list (which
      // doesn't contain `created.id` yet) and its value, throwing
      // DropdownButtonFormField's "exactly one matching item" assertion.
      final refreshedProducts = await ref.refresh(productsProvider.future);
      if (mounted && refreshedProducts.any((p) => p.id == created.id)) {
        setState(() => _selectedProductId = created.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(branchesProvider);
    final productsAsync = ref.watch(productsProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(staffForBranchProvider(_selectedBranchId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.priceTagTileTitle),
        backgroundColor: AppColors.print,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('branchDropdown'),
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
                key: const Key('staffDropdown'),
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
            productsAsync.when(
              data: (products) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('productDropdown'),
                      initialValue: _selectedProductId,
                      decoration: InputDecoration(labelText: l10n.productLabel),
                      items: products
                          .map((p) => DropdownMenuItem(value: p.id, child: Text(p.brandName)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedProductId = value),
                    ),
                  ),
                  IconButton(
                    key: const Key('addProductButton'),
                    tooltip: l10n.addProductTooltip,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.print),
                    onPressed: _showAddProductDialog,
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('mrpField'),
              controller: _mrpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.mrpLabel),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SegmentedButton<DiscountType>(
              key: const Key('discountTypeSelector'),
              segments: [
                ButtonSegment(value: DiscountType.percent, label: Text(l10n.discountPercentOption)),
                ButtonSegment(value: DiscountType.flat, label: Text(l10n.discountFlatOption)),
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
                labelText: _discountType == DiscountType.percent
                    ? l10n.discountPercentFieldLabel
                    : l10n.discountAmountFieldLabel,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.finalPriceLabel('₹${_finalPrice.toStringAsFixed(2)}'),
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
              child: _saving ? const CircularProgressIndicator() : Text(l10n.saveAndPrint),
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns its own `TextEditingController` so it disposes itself as part of
/// the dialog route's normal exit-transition lifecycle, rather than a
/// caller disposing one manually right after `showDialog` returns — doing
/// that races the closing animation and throws "TextEditingController used
/// after being disposed" while the dialog is still fading out.
class _AddProductDialog extends StatefulWidget {
  const _AddProductDialog({required this.productRepository});

  final ProductRepository productRepository;

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final product = await widget.productRepository.create(Product(id: '', brandName: name));
    if (mounted) Navigator.of(context).pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addProductDialogTitle),
      content: TextField(
        key: const Key('newProductNameField'),
        controller: _nameController,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.brandNameLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          key: const Key('confirmAddProductButton'),
          onPressed: _confirm,
          child: Text(l10n.addLineItemLabel),
        ),
      ],
    );
  }
}
