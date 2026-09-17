import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/exchange_record.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../receipt/receipt_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();
  List<ExchangeRecord> _results = const [];
  bool _searching = false;
  bool _hasSearched = false;
  final Set<String> _convertingIds = {};
  String? _errorMessage;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _searching = true;
      _hasSearched = true;
      _errorMessage = null;
    });
    try {
      final results = await ref.read(exchangeRecordRepositoryProvider).search(_queryController.text);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = l10n.failedToSaveError(e.toString()));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _convertToOrder(ExchangeRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _convertingIds.add(record.id!));
    try {
      final updated = await ref.read(exchangeRecordRepositoryProvider).convertToOrder(record.id!);
      if (mounted) {
        setState(() {
          _results = [
            for (final r in _results) if (r.id == updated.id) updated else r,
          ];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.orderConvertedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToConvertError(e.toString()));
    } finally {
      if (mounted) setState(() => _convertingIds.remove(record.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('searchQueryField'),
                    controller: _queryController,
                    decoration: InputDecoration(labelText: l10n.searchQueryLabel),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('searchButton'),
                  onPressed: _searching ? null : _search,
                  child: _searching
                      ? const SizedBox(
                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.searchButton),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            if (_hasSearched && !_searching && _results.isEmpty)
              Text(l10n.noResultsMessage, key: const Key('noResultsText')),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) => _buildResultTile(l10n, _results[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(AppLocalizations l10n, ExchangeRecord record) {
    final isConverting = _convertingIds.contains(record.id);
    final statusLabel =
        record.status == ExchangeStatus.order ? l10n.statusOrderLabel : l10n.statusEstimateLabel;
    return Card(
      key: Key('searchResultTile_${record.id}'),
      child: ListTile(
        title: Text('${record.displayId ?? ''} — ${record.customerName}'),
        subtitle: Text(
          '${record.customerPhone} · $statusLabel · ${l10n.netTotalLabel}: ₹${record.netTotalAmount.toStringAsFixed(2)}',
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReceiptScreen(record: record)),
        ),
        trailing: record.status == ExchangeStatus.estimate
            ? TextButton(
                key: Key('convertToOrderButton_${record.id}'),
                onPressed: isConverting ? null : () => _convertToOrder(record),
                child: isConverting
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.convertToOrderButton),
              )
            : const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
}
