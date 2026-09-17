import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/inventory.dart';
import '../../../core/providers.dart';

final transitSheetBranchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final transitSheetAllItemsProvider = FutureProvider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryRepositoryProvider).listAllItems();
});
