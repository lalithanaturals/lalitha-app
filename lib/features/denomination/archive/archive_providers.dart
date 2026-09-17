import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/audit_register.dart';
import '../../../core/models/branch.dart';
import '../../../core/providers.dart';

final archiveBranchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final archiveRegistersProvider = FutureProvider.autoDispose.family<List<AuditRegister>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(auditRegisterRepositoryProvider).listForBranch(branchId);
});

final archiveLineItemsProvider = FutureProvider.autoDispose.family<List<AuditLineItem>, String>((ref, registerId) {
  return ref.watch(auditRegisterRepositoryProvider).listLineItems(registerId);
});
