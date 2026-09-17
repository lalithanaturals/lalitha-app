import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'login_providers.dart';

/// Every collection except `staff` requires an authenticated user, so this
/// screen has to succeed before anything else in the app can load data —
/// see lalitha-api's pb_migrations/1700000021_staff_pin_login.js.
class StaffLoginScreen extends ConsumerStatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  ConsumerState<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends ConsumerState<StaffLoginScreen> {
  final _pinController = TextEditingController();
  String? _selectedStaffId;
  bool _loggingIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedStaffId == null) {
      setState(() => _errorMessage = l10n.selectStaffError);
      return;
    }
    setState(() {
      _loggingIn = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).loginWithPin(_selectedStaffId!, _pinController.text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.invalidPinError);
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final staffAsync = ref.watch(activeStaffProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        backgroundColor: AppColors.suite,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: staffAsync.when(
          data: (staffList) => ListView(
            children: [
              DropdownButtonFormField<String>(
                key: const Key('loginStaffDropdown'),
                initialValue: _selectedStaffId,
                decoration: InputDecoration(labelText: l10n.staffLabel),
                items: staffList
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaffId = value),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('loginPinField'),
                controller: _pinController,
                decoration: InputDecoration(labelText: l10n.pinLabel),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  key: const Key('loginErrorText'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('loginButton'),
                onPressed: _loggingIn ? null : _login,
                child: Text(l10n.loginButton),
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
