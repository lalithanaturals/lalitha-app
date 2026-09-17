import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/branch.dart';
import '../../../core/models/transit_sheet.dart';
import '../../../core/providers.dart';

final transitHistoryBranchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.watch(branchRepositoryProvider).listActive();
});

final transitHistorySheetsProvider = FutureProvider.family<List<TransitSheet>, String>((ref, branchId) {
  if (branchId.isEmpty) return Future.value(const []);
  return ref.watch(transitSheetRepositoryProvider).listForBranch(branchId);
});

/// Line items for one sheet, with names filled in from
/// [transitSheetAllItemsProvider]-shaped data (see the family's dependency
/// below) — kept as its own family so each sheet's items load only once its
/// ExpansionTile is expanded.
final transitHistoryItemsProvider = FutureProvider.family<List<TransitSheetItem>, String>((ref, sheetId) async {
  final allItems = await ref.watch(inventoryAllItemsForTransitHistoryProvider.future);
  final itemNames = {for (final i in allItems) i.id: i.name};
  return ref.watch(transitSheetRepositoryProvider).listItems(sheetId, itemNames: itemNames);
});

final inventoryAllItemsForTransitHistoryProvider = FutureProvider((ref) {
  return ref.watch(inventoryRepositoryProvider).listAllItems();
});
