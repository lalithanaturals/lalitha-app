import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/audit_register.dart';
import '../../../core/models/branch.dart';
import '../../../core/providers.dart';

final dashboardBranchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final dashboardRegistersProvider = FutureProvider.family<List<AuditRegister>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(auditRegisterRepositoryProvider).listForBranch(branchId);
});

final dashboardLineItemsProvider = FutureProvider.family<List<AuditLineItem>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(auditRegisterRepositoryProvider).listAllLineItemsForBranch(branchId);
});
