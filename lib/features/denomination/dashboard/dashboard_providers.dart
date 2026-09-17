import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/audit_register.dart';
import '../../../core/models/branch.dart';
import '../../../core/providers.dart';

final dashboardBranchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final dashboardRegistersProvider = FutureProvider.autoDispose.family<List<AuditRegister>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(auditRegisterRepositoryProvider).listForBranch(branchId);
});

final dashboardLineItemsProvider = FutureProvider.autoDispose.family<List<AuditLineItem>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(auditRegisterRepositoryProvider).listAllLineItemsForBranch(branchId);
});
