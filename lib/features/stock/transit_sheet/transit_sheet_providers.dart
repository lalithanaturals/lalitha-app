import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/inventory.dart';
import '../../../core/models/staff.dart';
import '../../../core/providers.dart';

final transitSheetBranchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final transitSheetAllItemsProvider = FutureProvider.autoDispose<List<InventoryItem>>((ref) {
  return ref.watch(inventoryRepositoryProvider).listAllItems();
});

final transitSheetStaffForBranchProvider = FutureProvider.autoDispose.family<List<Staff>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(staffRepositoryProvider).listForBranch(branchId);
});
