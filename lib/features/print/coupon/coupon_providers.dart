import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/coupon.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';

final couponBranchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final couponStaffForBranchProvider = FutureProvider.family<List<Staff>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(staffRepositoryProvider).listForBranch(branchId);
});

/// Re-fetchable list of coupons for a branch — `ref.invalidate(couponsForBranchProvider(id))`
/// after issuing/redeeming refreshes the screen from the backend rather than hand-patching
/// local state.
final couponsForBranchProvider = FutureProvider.family<List<Coupon>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(couponRepositoryProvider).listForBranch(branchId);
});
