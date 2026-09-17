import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/business_info.dart';
import '../../../core/models/branch.dart';
import '../../../core/models/custom_print.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'visiting_card_providers.dart';

class VisitingCardScreen extends ConsumerStatefulWidget {
  const VisitingCardScreen({super.key});

  @override
  ConsumerState<VisitingCardScreen> createState() => _VisitingCardScreenState();
}

class _VisitingCardScreenState extends ConsumerState<VisitingCardScreen> {
  String? _selectedBranchId;
  bool _printing = false;
  String? _errorMessage;

  Map<String, dynamic> _buildContent(List<Branch> branches) => {
        'tagline': BusinessInfo.tagline,
        'coreOfferings': BusinessInfo.coreOfferings,
        'branches': [
          for (final b in branches) {'name': b.name, 'address': b.address},
        ],
        'phone': BusinessInfo.phone,
        'website': BusinessInfo.website,
      };

  Future<void> _print(List<Branch> branches) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedBranchId == null) {
      setState(() => _errorMessage = l10n.selectBranchError);
      return;
    }
    setState(() {
      _printing = true;
      _errorMessage = null;
    });
    try {
      final print = CustomPrint(
        printType: PrintType.visitingCard,
        content: _buildContent(branches),
        branchId: _selectedBranchId!,
      );
      await ref.read(customPrintRepositoryProvider).create(print);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.visitingCardPrintedMessage)),
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
    final branchesAsync = ref.watch(visitingCardBranchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.visitingCardTileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: branchesAsync.when(
          data: (branches) => ListView(
            children: [
              DropdownButtonFormField<String>(
                key: const Key('visitingCardBranchDropdown'),
                initialValue: _selectedBranchId,
                decoration: InputDecoration(labelText: l10n.branchLabel),
                items: branches
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBranchId = value),
              ),
              const SizedBox(height: 20),
              Card(
                key: const Key('visitingCardPreview'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lalitha Naturals', style: Theme.of(context).textTheme.titleLarge),
                      Text(BusinessInfo.tagline, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Text(l10n.coreOfferingsLabel,
                          style: Theme.of(context).textTheme.titleSmall),
                      for (final offering in BusinessInfo.coreOfferings) Text('• $offering'),
                      const SizedBox(height: 12),
                      for (final b in branches) ...[
                        Text(b.name, style: Theme.of(context).textTheme.titleSmall),
                        Text(b.address),
                        const SizedBox(height: 8),
                      ],
                      Text('${l10n.phoneLabel}: ${BusinessInfo.phone}'),
                      Text(BusinessInfo.website),
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
                key: const Key('printVisitingCardButton'),
                onPressed: _printing ? null : () => _print(branches),
                child: _printing ? const CircularProgressIndicator() : Text(l10n.saveAndPrint),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
      ),
    );
  }
}
