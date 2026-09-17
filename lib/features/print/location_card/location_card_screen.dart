import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/custom_print.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'location_card_providers.dart';

class LocationCardScreen extends ConsumerStatefulWidget {
  const LocationCardScreen({super.key});

  @override
  ConsumerState<LocationCardScreen> createState() => _LocationCardScreenState();
}

class _LocationCardScreenState extends ConsumerState<LocationCardScreen> {
  String? _selectedBranchId;
  bool _printing = false;
  String? _errorMessage;

  CustomPrint _buildPrint(Branch branch) => CustomPrint(
        printType: PrintType.locationCard,
        content: {'branchName': branch.name, 'address': branch.address},
        branchId: branch.id,
      );

  Future<void> _printOne(Branch branch) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _printing = true;
      _errorMessage = null;
    });
    try {
      await ref.read(customPrintRepositoryProvider).create(_buildPrint(branch));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.locationCardPrintedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToPrintError(e.toString()));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _printBoth(List<Branch> branches) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _printing = true;
      _errorMessage = null;
    });
    try {
      for (final branch in branches) {
        await ref.read(customPrintRepositoryProvider).create(_buildPrint(branch));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.locationCardPrintedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToPrintError(e.toString()));
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(locationCardBranchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.locationCardTileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: branchesAsync.when(
          data: (branches) {
            final selected = branches.where((b) => b.id == _selectedBranchId).firstOrNull;
            return ListView(
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('locationCardBranchDropdown'),
                  initialValue: _selectedBranchId,
                  decoration: InputDecoration(labelText: l10n.branchLabel),
                  items: branches
                      .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBranchId = value),
                ),
                const SizedBox(height: 20),
                if (selected != null)
                  Card(
                    key: const Key('locationCardPreview'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selected.name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('${l10n.addressLabel}: ${selected.address}'),
                        ],
                      ),
                    ),
                  ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('printLocationCardButton'),
                  onPressed: (_printing || selected == null) ? null : () => _printOne(selected),
                  child: _printing ? const CircularProgressIndicator() : Text(l10n.saveAndPrint),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('printBothBranchesButton'),
                  onPressed: (_printing || branches.isEmpty) ? null : () => _printBoth(branches),
                  child: Text(l10n.printBothBranchesButton),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
      ),
    );
  }
}
