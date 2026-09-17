import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/inventory.dart';
import '../../../core/providers.dart';

final inventoryBranchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final inventoryCategoriesProvider = FutureProvider<List<InventoryCategory>>((ref) {
  return ref.watch(inventoryRepositoryProvider).listCategories();
});

final itemsForCategoryProvider = FutureProvider.family<List<InventoryItem>, String>((ref, categoryId) {
  if (categoryId.isEmpty) return Future.value(const []);
  return ref.watch(inventoryRepositoryProvider).listItemsForCategory(categoryId);
});

final stockForBranchProvider = FutureProvider.family<List<InventoryStock>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(inventoryRepositoryProvider).listStockForBranch(branchId);
});
