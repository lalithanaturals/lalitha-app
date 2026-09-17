import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/inventory.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/inventory_repository.dart';
import 'package:lalitha_app/features/stock/inventory/inventory_providers.dart';
import 'package:lalitha_app/features/stock/inventory/inventory_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockInventoryRepository extends Mock implements InventoryRepository {}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');
const _category = InventoryCategory(id: 'cat1', name: 'Groceries');
const _item = InventoryItem(id: 'item1', categoryId: 'cat1', name: 'Ghee 500ml');

Future<void> _pumpScreen(
  WidgetTester tester, {
  required InventoryRepository repo,
  List<InventoryStock> stock = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryBranchesProvider.overrideWith((ref) async => [_branch]),
        inventoryCategoriesProvider.overrideWith((ref) async => [_category]),
        itemsForCategoryProvider.overrideWith((ref, categoryId) async => [_item]),
        stockForBranchProvider.overrideWith((ref, branchId) async => stock),
        inventoryRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const InventoryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectBranchAndCategory(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('inventoryBranchDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gajuwaka').last);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('inventoryCategoryDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Groceries').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows items with a quantity of 0 when no stock row exists', (tester) async {
    final repo = _MockInventoryRepository();
    await _pumpScreen(tester, repo: repo);
    await _selectBranchAndCategory(tester);

    expect(find.byKey(const Key('inventoryItemTile_item1')), findsOneWidget);
    expect(find.textContaining('Current Stock: 0'), findsOneWidget);
  });

  testWidgets('shows the existing quantity from the stock row', (tester) async {
    final repo = _MockInventoryRepository();
    await _pumpScreen(
      tester,
      repo: repo,
      stock: const [InventoryStock(id: 's1', itemId: 'item1', branchId: 'branch1', quantity: 7)],
    );
    await _selectBranchAndCategory(tester);

    expect(find.textContaining('Current Stock: 7'), findsOneWidget);
  });

  testWidgets('tapping + calls setStockQuantity with quantity + 1', (tester) async {
    final repo = _MockInventoryRepository();
    when(() => repo.setStockQuantity(
          itemId: any(named: 'itemId'),
          branchId: any(named: 'branchId'),
          quantity: any(named: 'quantity'),
        )).thenAnswer(
      (invocation) async => InventoryStock(
        id: 's1',
        itemId: invocation.namedArguments[#itemId] as String,
        branchId: invocation.namedArguments[#branchId] as String,
        quantity: invocation.namedArguments[#quantity] as num,
      ),
    );
    await _pumpScreen(
      tester,
      repo: repo,
      stock: const [InventoryStock(id: 's1', itemId: 'item1', branchId: 'branch1', quantity: 3)],
    );
    await _selectBranchAndCategory(tester);

    await tester.tap(find.byKey(const Key('incrementButton_item1')));
    await tester.pumpAndSettle();

    verify(() => repo.setStockQuantity(itemId: 'item1', branchId: 'branch1', quantity: 4)).called(1);
    expect(find.text('Stock updated'), findsOneWidget);
  });

  testWidgets('the − button does not go below zero', (tester) async {
    final repo = _MockInventoryRepository();
    await _pumpScreen(
      tester,
      repo: repo,
      stock: const [InventoryStock(id: 's1', itemId: 'item1', branchId: 'branch1', quantity: 0)],
    );
    await _selectBranchAndCategory(tester);

    await tester.tap(find.byKey(const Key('decrementButton_item1')));
    await tester.pumpAndSettle();

    verifyNever(() => repo.setStockQuantity(
          itemId: any(named: 'itemId'),
          branchId: any(named: 'branchId'),
          quantity: any(named: 'quantity'),
        ));
  });
}
