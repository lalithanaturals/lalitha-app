import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/exchange_rates.dart';
import '../../../core/models/exchange_record.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../receipt/receipt_screen.dart';
import '../search/search_screen.dart';
import 'calculator_providers.dart';

enum _Material { al, st }

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final List<TextEditingController> _alWeightControllers = [TextEditingController()];
  final List<TextEditingController> _stWeightControllers = [TextEditingController()];
  num _alHandles = 0;
  num _stHandles = 0;
  _Material _activeMaterial = _Material.al;
  String? _selectedBranchId;
  String? _selectedStaffId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    for (final c in [..._alWeightControllers, ..._stWeightControllers]) {
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _activeControllers =>
      _activeMaterial == _Material.al ? _alWeightControllers : _stWeightControllers;

  List<num> get _alWeights => _parsedWeights(_alWeightControllers);
  List<num> get _stWeights => _parsedWeights(_stWeightControllers);

  List<num> _parsedWeights(List<TextEditingController> controllers) => controllers
      .map((c) => num.tryParse(c.text))
      .where((w) => w != null && w > 0)
      .cast<num>()
      .toList();

  ExchangeRecord get _currentRecord => ExchangeRecord(
        branchId: _selectedBranchId ?? '',
        staffId: _selectedStaffId,
        customerName: _customerNameController.text.trim().isEmpty
            ? 'Walk-in Customer'
            : _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        alWeights: _alWeights,
        alHandles: _alHandles,
        stWeights: _stWeights,
        stHandles: _stHandles,
      );

  void _addWeightRow() => setState(() => _activeControllers.add(TextEditingController()));

  void _removeWeightRow(int index) {
    setState(() {
      _activeControllers.removeAt(index).dispose();
      if (_activeControllers.isEmpty) _activeControllers.add(TextEditingController());
    });
  }

  void _adjustHandles(num delta) {
    setState(() {
      if (_activeMaterial == _Material.al) {
        _alHandles = (_alHandles + delta).clamp(0, double.infinity);
      } else {
        _stHandles = (_stHandles + delta).clamp(0, double.infinity);
      }
    });
  }

  Future<void> _submit(ExchangeStatus status) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedBranchId == null) {
      setState(() => _errorMessage = l10n.selectBranchError);
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final record = ExchangeRecord(
        branchId: _selectedBranchId!,
        staffId: _selectedStaffId,
        customerName: _currentRecord.customerName,
        customerPhone: _currentRecord.customerPhone,
        status: status,
        alWeights: _alWeights,
        alHandles: _alHandles,
        stWeights: _stWeights,
        stHandles: _stHandles,
      );
      final created = await ref.read(exchangeRecordRepositoryProvider).create(record);
      if (mounted) {
        final message = status == ExchangeStatus.order
            ? l10n.exchangeOrderSavedMessage
            : l10n.exchangeEstimateSavedMessage;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReceiptScreen(record: created)),
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
    final branchesAsync = ref.watch(calculatorBranchesProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(calculatorStaffForBranchProvider(_selectedBranchId!));

    final record = _currentRecord;
    final activeTotals = _activeMaterial == _Material.al ? record.alTotals : record.stTotals;
    final activeRate = ExchangeRates.ratePerKg[_activeMaterial == _Material.al ? 'al' : 'st']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculatorTitle),
        backgroundColor: AppColors.scrap,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('openSearchButton'),
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('calculatorBranchDropdown'),
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
                key: const Key('calculatorStaffDropdown'),
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
            SegmentedButton<_Material>(
              key: const Key('materialSelector'),
              segments: [
                ButtonSegment(
                  value: _Material.al,
                  label: Text(l10n.aluminumTabLabel(ExchangeRates.ratePerKg['al']!.toStringAsFixed(0))),
                ),
                ButtonSegment(
                  value: _Material.st,
                  label: Text(l10n.steelTabLabel(ExchangeRates.ratePerKg['st']!.toStringAsFixed(0))),
                ),
              ],
              selected: {_activeMaterial},
              onSelectionChanged: (s) => setState(() => _activeMaterial = s.first),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _activeControllers.length; i++) _buildWeightRow(l10n, i),
            TextButton.icon(
              key: const Key('addWeightButton'),
              onPressed: _addWeightRow,
              icon: const Icon(Icons.add),
              label: Text(l10n.addWeightLabel),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(l10n.handlesLabel),
                IconButton(
                  key: const Key('decrementHandlesButton'),
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _adjustHandles(-1),
                ),
                Text('${_activeMaterial == _Material.al ? _alHandles : _stHandles}',
                    key: const Key('handlesCountText')),
                IconButton(
                  key: const Key('incrementHandlesButton'),
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _adjustHandles(1),
                ),
              ],
            ),
            const Divider(),
            Text('${l10n.grossWeightLabel}: ${activeTotals.grossWeightKg.toStringAsFixed(2)} kg'),
            Text(
                '${l10n.handlesDeductionLabel}: ${activeTotals.handlesDeductionKg.toStringAsFixed(2)} kg'),
            Text('${l10n.netWeightLabel}: ${activeTotals.netWeightKg.toStringAsFixed(2)} kg'),
            Text(
              '${l10n.materialCostLabel}: ₹${activeTotals.cost.toStringAsFixed(2)} (₹$activeRate/kg)',
              key: const Key('activeMaterialCostText'),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.grandTotalLabel('₹${record.netTotalAmount.toStringAsFixed(2)}'),
              key: const Key('grandTotalText'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('getEstimationButton'),
                    onPressed: _saving ? null : () => _submit(ExchangeStatus.estimate),
                    child: Text(l10n.getEstimationButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('submitOrderButton'),
                    onPressed: _saving ? null : () => _submit(ExchangeStatus.order),
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(l10n.submitOrderButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightRow(AppLocalizations l10n, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: Key('weightField_${_activeMaterial.name}_$index'),
              controller: _activeControllers[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.weightKgLabel),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            key: Key('removeWeightButton_${_activeMaterial.name}_$index'),
            onPressed: () => _removeWeightRow(index),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}
