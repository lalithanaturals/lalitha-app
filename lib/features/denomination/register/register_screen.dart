import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/denomination_values.dart';
import '../../../core/models/audit_register.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'register_providers.dart';

class _LineItemDraft {
  _LineItemDraft()
      : nameController = TextEditingController(),
        amountController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController amountController;

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // v1 always registers for today; a date picker (to file a register for a
  // past date, or navigate the archive) is deferred along with the
  // Archive/Search screen — see DenominationHomeScreen's doc comment.
  final DateTime _date = DateTime.now();
  String? _selectedBranchId;
  String? _selectedStaffId;
  num _openingBalance = 0;
  final Map<int, TextEditingController> _denominationControllers = {
    for (final v in DenominationValues.values) v: TextEditingController(),
  };
  final Map<AuditLineCategory, List<_LineItemDraft>> _lineItems = {
    for (final c in AuditLineCategory.values) c: <_LineItemDraft>[],
  };
  bool _committing = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _denominationControllers.values) {
      c.dispose();
    }
    for (final drafts in _lineItems.values) {
      for (final d in drafts) {
        d.dispose();
      }
    }
    super.dispose();
  }

  Map<int, int> get _denominationCounts => {
        for (final entry in _denominationControllers.entries)
          if ((int.tryParse(entry.value.text) ?? 0) > 0) entry.key: int.parse(entry.value.text),
      };

  Future<void> _onBranchOrDateChanged() async {
    if (_selectedBranchId == null) return;
    final repo = ref.read(auditRegisterRepositoryProvider);
    final previous = await repo.findPreviousRegister(_selectedBranchId!, _date);
    if (!mounted) return;
    setState(() => _openingBalance = previous?.closingBalance ?? 0);
  }

  void _addLineItem(AuditLineCategory category) =>
      setState(() => _lineItems[category]!.add(_LineItemDraft()));

  void _removeLineItem(AuditLineCategory category, int index) {
    setState(() {
      _lineItems[category]!.removeAt(index).dispose();
    });
  }

  Future<void> _commit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedBranchId == null) {
      setState(() => _errorMessage = l10n.selectBranchError);
      return;
    }
    setState(() {
      _committing = true;
      _errorMessage = null;
    });
    try {
      final counts = _denominationCounts;
      final register = AuditRegister(
        date: _date,
        branchId: _selectedBranchId!,
        openingBalance: _openingBalance,
        closingBalance: calculateClosingBalance(counts),
        denominationCounts: counts,
        cashTotal: calculateCashTotal(counts),
        status: AuditRegisterStatus.draft,
      );
      final repo = ref.read(auditRegisterRepositoryProvider);
      final created = await repo.create(register);

      for (final entry in _lineItems.entries) {
        for (final draft in entry.value) {
          if (draft.nameController.text.trim().isEmpty) continue;
          await repo.addLineItem(AuditLineItem(
            auditRegisterId: created.id,
            category: entry.key,
            name: draft.nameController.text.trim(),
            amount: num.tryParse(draft.amountController.text) ?? 0,
          ));
        }
      }

      await repo.commit(created.id!, committedByStaffId: _selectedStaffId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registerCommittedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToCommitError(e.toString()));
    } finally {
      if (mounted) setState(() => _committing = false);
    }
  }

  String _categoryLabel(AppLocalizations l10n, AuditLineCategory category) => switch (category) {
        AuditLineCategory.expense => l10n.expenseCategoryLabel,
        AuditLineCategory.ownerBill => l10n.ownerBillCategoryLabel,
        AuditLineCategory.vendorBill => l10n.vendorBillCategoryLabel,
        AuditLineCategory.unbilled => l10n.unbilledCategoryLabel,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(registerBranchesProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(registerStaffForBranchProvider(_selectedBranchId!));

    final counts = _denominationCounts;
    final cashTotal = calculateCashTotal(counts);
    final closingBalance = calculateClosingBalance(counts);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerEntryTitle),
        backgroundColor: AppColors.denomination,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('registerBranchDropdown'),
                initialValue: _selectedBranchId,
                decoration: InputDecoration(labelText: l10n.branchLabel),
                items: branches
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranchId = value;
                    _selectedStaffId = null;
                  });
                  _onBranchOrDateChanged();
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 12),
            staffAsync.when(
              data: (staff) => DropdownButtonFormField<String>(
                key: const Key('registerStaffDropdown'),
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
            Text('${l10n.openingBalanceLabel}: ₹${_openingBalance.toStringAsFixed(2)}',
                key: const Key('openingBalanceText')),
            const SizedBox(height: 20),
            Text(l10n.denominationCountsLabel, style: Theme.of(context).textTheme.titleMedium),
            for (final value in DenominationValues.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text('₹$value')),
                    Expanded(
                      child: TextField(
                        key: Key('denomField_$value'),
                        controller: _denominationControllers[value],
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text('${l10n.cashTotalLabel}: ₹${cashTotal.toStringAsFixed(2)}',
                key: const Key('cashTotalText')),
            Text('${l10n.closingBalanceLabel}: ₹${closingBalance.toStringAsFixed(2)}',
                key: const Key('closingBalanceText')),
            const SizedBox(height: 20),
            for (final category in AuditLineCategory.values)
              _buildCategorySection(l10n, category),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('commitButton'),
              onPressed: _committing ? null : _commit,
              child: _committing ? const CircularProgressIndicator() : Text(l10n.commitButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n, AuditLineCategory category) {
    final drafts = _lineItems[category]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_categoryLabel(l10n, category), style: Theme.of(context).textTheme.titleSmall),
          for (var i = 0; i < drafts.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      key: Key('lineItemName_${category.name}_$i'),
                      controller: drafts[i].nameController,
                      decoration: InputDecoration(labelText: l10n.lineItemNameLabel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      key: Key('lineItemAmount_${category.name}_$i'),
                      controller: drafts[i].amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.lineItemAmountLabel),
                    ),
                  ),
                  IconButton(
                    key: Key('removeLineItem_${category.name}_$i'),
                    onPressed: () => _removeLineItem(category, i),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            key: Key('addLineItem_${category.name}'),
            onPressed: () => _addLineItem(category),
            icon: const Icon(Icons.add),
            label: Text(l10n.addLineItemLabel),
          ),
        ],
      ),
    );
  }
}
