import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';

final estimateBranchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final estimateStaffForBranchProvider = FutureProvider.autoDispose.family<List<Staff>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(staffRepositoryProvider).listForBranch(branchId);
});
