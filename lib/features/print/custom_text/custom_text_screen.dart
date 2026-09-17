import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/custom_print.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'custom_text_providers.dart';

enum TextAlign3 { left, center, right }

class CustomTextScreen extends ConsumerStatefulWidget {
  const CustomTextScreen({super.key});

  @override
  ConsumerState<CustomTextScreen> createState() => _CustomTextScreenState();
}

class _CustomTextScreenState extends ConsumerState<CustomTextScreen> {
  final _textController = TextEditingController();
  TextAlign3 _alignment = TextAlign3.center;
  bool _bold = false;
  double _fontSize = 16;
  String? _selectedBranchId;
  bool _printing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  TextAlign get _flutterAlign => switch (_alignment) {
        TextAlign3.left => TextAlign.left,
        TextAlign3.center => TextAlign.center,
        TextAlign3.right => TextAlign.right,
      };

  Future<void> _print() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedBranchId == null) {
      setState(() => _errorMessage = l10n.selectBranchError);
      return;
    }
    if (_textController.text.trim().isEmpty) {
      setState(() => _errorMessage = l10n.enterTextError);
      return;
    }
    setState(() {
      _printing = true;
      _errorMessage = null;
    });
    try {
      final print = CustomPrint(
        printType: PrintType.customText,
        content: {
          'text': _textController.text.trim(),
          'alignment': _alignment.name,
          'bold': _bold,
          'fontSize': _fontSize,
        },
        branchId: _selectedBranchId!,
      );
      await ref.read(customPrintRepositoryProvider).create(print);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.customTextPrintedMessage)),
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
    final branchesAsync = ref.watch(customTextBranchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customTextTileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: branchesAsync.when(
          data: (branches) => ListView(
            children: [
              DropdownButtonFormField<String>(
                key: const Key('customTextBranchDropdown'),
                initialValue: _selectedBranchId,
                decoration: InputDecoration(labelText: l10n.branchLabel),
                items: branches
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBranchId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('customTextField'),
                controller: _textController,
                maxLines: 6,
                decoration: InputDecoration(labelText: l10n.customTextLabel),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TextAlign3>(
                key: const Key('textAlignmentSelector'),
                segments: [
                  ButtonSegment(value: TextAlign3.left, label: Text(l10n.alignLeftOption)),
                  ButtonSegment(value: TextAlign3.center, label: Text(l10n.alignCenterOption)),
                  ButtonSegment(value: TextAlign3.right, label: Text(l10n.alignRightOption)),
                ],
                selected: {_alignment},
                onSelectionChanged: (s) => setState(() => _alignment = s.first),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                key: const Key('boldSwitch'),
                title: Text(l10n.boldLabel),
                value: _bold,
                onChanged: (value) => setState(() => _bold = value),
              ),
              Row(
                children: [
                  Text(l10n.fontSizeLabel),
                  Expanded(
                    child: Slider(
                      key: const Key('fontSizeSlider'),
                      value: _fontSize,
                      min: 10,
                      max: 32,
                      divisions: 22,
                      label: _fontSize.round().toString(),
                      onChanged: (value) => setState(() => _fontSize = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                key: const Key('customTextPreview'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _textController.text,
                    textAlign: _flutterAlign,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: _bold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('printCustomTextButton'),
                onPressed: _printing ? null : _print,
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
