import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/models/coupon.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'coupon_providers.dart';

class CouponScreen extends ConsumerStatefulWidget {
  const CouponScreen({super.key});

  @override
  ConsumerState<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends ConsumerState<CouponScreen> {
  final _couponTypeController = TextEditingController();
  final _discountValueController = TextEditingController();
  String? _selectedBranchId;
  String? _selectedStaffId;
  bool _issuing = false;
  String? _redeemingId;
  String? _errorMessage;

  @override
  void dispose() {
    _couponTypeController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    final l10n = AppLocalizations.of(context)!;
    final branchId = _selectedBranchId;
    if (branchId == null || _couponTypeController.text.trim().isEmpty) {
      setState(() => _errorMessage = l10n.selectBranchAndTypeError);
      return;
    }
    setState(() {
      _issuing = true;
      _errorMessage = null;
    });
    try {
      final coupon = Coupon(
        couponType: _couponTypeController.text.trim(),
        branchId: branchId,
        staffId: _selectedStaffId,
        discountValue: num.tryParse(_discountValueController.text) ?? 0,
      );
      await ref.read(couponRepositoryProvider).issue(coupon);
      ref.invalidate(couponsForBranchProvider(branchId));
      _couponTypeController.clear();
      _discountValueController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couponIssuedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToSaveError(e.toString()));
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  Future<void> _redeem(Coupon coupon) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _redeemingId = coupon.id);
    try {
      await ref.read(couponRepositoryProvider).redeem(coupon.id!);
      ref.invalidate(couponsForBranchProvider(coupon.branchId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couponRedeemedMessage)),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.failedToRedeemError(e.toString()));
    } finally {
      if (mounted) setState(() => _redeemingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(couponBranchesProvider);
    final AsyncValue<List<Staff>> staffAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Staff>[])
        : ref.watch(couponStaffForBranchProvider(_selectedBranchId!));
    final AsyncValue<List<Coupon>> couponsAsync = _selectedBranchId == null
        ? const AsyncValue.data(<Coupon>[])
        : ref.watch(couponsForBranchProvider(_selectedBranchId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.couponTileTitle),
        backgroundColor: AppColors.print,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            branchesAsync.when(
              data: (branches) => DropdownButtonFormField<String>(
                key: const Key('couponBranchDropdown'),
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
                key: const Key('couponStaffDropdown'),
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
              key: const Key('couponTypeField'),
              controller: _couponTypeController,
              decoration: InputDecoration(labelText: l10n.couponTypeLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('couponDiscountValueField'),
              controller: _discountValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.discountValueLabel),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('issueCouponButton'),
              onPressed: _issuing ? null : _issue,
              child: _issuing ? const CircularProgressIndicator() : Text(l10n.issueCouponButton),
            ),
            const Divider(height: 32),
            couponsAsync.when(
              data: (coupons) => Column(
                children: [
                  for (final coupon in coupons) _buildCouponTile(context, l10n, coupon),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponTile(BuildContext context, AppLocalizations l10n, Coupon coupon) {
    return Card(
      key: Key('couponTile_${coupon.id}'),
      child: ListTile(
        title: Text('${coupon.couponType} — ${coupon.discountValue}'),
        subtitle: Text(coupon.redeemed ? l10n.redeemedLabel : l10n.notRedeemedLabel),
        trailing: coupon.redeemed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : TextButton(
                key: Key('redeemButton_${coupon.id}'),
                onPressed: _redeemingId == coupon.id ? null : () => _redeem(coupon),
                child: _redeemingId == coupon.id
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.redeemButton),
              ),
      ),
    );
  }
}
