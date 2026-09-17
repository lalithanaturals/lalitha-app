import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/price_tag.dart';
import 'package:lalitha_app/core/models/product.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/price_tag_repository.dart';
import 'package:lalitha_app/core/repositories/product_repository.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_providers.dart';
import 'package:lalitha_app/features/print/price_tag/price_tag_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockPriceTagRepository extends Mock implements PriceTagRepository {}

/// A stateful fake (not a Mock) so `create` actually shows up in a
/// subsequent `listAll` — needed to exercise the real
/// `ref.refresh(productsProvider.future)` flow after adding a product.
class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository([List<Product> initial = const []]) : _products = List.of(initial);

  final List<Product> _products;
  int _nextId = 100;

  @override
  Future<List<Product>> listAll() async => List.of(_products);

  @override
  Future<Product> create(Product product) async {
    final created = Product(id: 'prod${_nextId++}', brandName: product.brandName);
    _products.add(created);
    return created;
  }
}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');
const _staff = Staff(id: 'staff1', name: 'Bhargav', branchId: 'branch1');
const _product = Product(id: 'prod1', brandName: 'Cold Pressed Oil', defaultPrice: 300);

Future<void> _pumpScreen(
  WidgetTester tester, {
  required PriceTagRepository repo,
  ProductRepository? productRepo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        branchesProvider.overrideWith((ref) async => [_branch]),
        staffForBranchProvider.overrideWith((ref, branchId) async => [_staff]),
        priceTagRepositoryProvider.overrideWithValue(repo),
        productRepositoryProvider.overrideWithValue(productRepo ?? _FakeProductRepository([_product])),
      ],
      child: localizedTestApp(home: const PriceTagScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Product(id: 'fallback', brandName: 'fallback'));
    registerFallbackValue(
      PriceTag.compute(
        productId: 'fallback',
        mrp: 0,
        discountType: DiscountType.percent,
        discountValue: 0,
        branchId: 'fallback',
      ),
    );
  });

  testWidgets('shows a live-computed final price as MRP/discount change', (tester) async {
    final repo = _MockPriceTagRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('mrpField')), '200');
    await tester.enterText(find.byKey(const Key('discountValueField')), '10');
    await tester.pump();

    expect(find.byKey(const Key('finalPriceText')), findsOneWidget);
    expect(find.text('Final Price: ₹180.00'), findsOneWidget);
  });

  testWidgets('switching to flat discount recomputes the final price', (tester) async {
    final repo = _MockPriceTagRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.enterText(find.byKey(const Key('mrpField')), '200');
    await tester.enterText(find.byKey(const Key('discountValueField')), '30');
    await tester.tap(find.text('Flat Off'));
    await tester.pump();

    expect(find.text('Final Price: ₹170.00'), findsOneWidget);
  });

  testWidgets('shows a validation message when saving without branch/product selected', (tester) async {
    final repo = _MockPriceTagRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pump();

    expect(find.textContaining('Select a branch and a product'), findsOneWidget);
    verifyNever(() => repo.create(any()));
  });

  testWidgets('saving after selecting branch/staff/product calls the repository', (tester) async {
    final repo = _MockPriceTagRepository();
    when(() => repo.create(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('branchDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gajuwaka').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('productDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cold Pressed Oil').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('mrpField')), '100');
    await tester.pump();

    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    verify(() => repo.create(any())).called(1);
    expect(find.text('Price tag saved'), findsOneWidget);
  });

  testWidgets('adding a product creates it, selects it, and refreshes the dropdown', (tester) async {
    final repo = _MockPriceTagRepository();
    final productRepo = _FakeProductRepository([_product]);
    await _pumpScreen(tester, repo: repo, productRepo: productRepo);

    await tester.tap(find.byKey(const Key('addProductButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('newProductNameField')), 'New Brand');
    await tester.tap(find.byKey(const Key('confirmAddProductButton')));
    await tester.pumpAndSettle();

    expect(await productRepo.listAll(), hasLength(2));
    expect(find.text('New Brand'), findsOneWidget);
  });

  testWidgets('adding a product with a blank name does not call the repository', (tester) async {
    final repo = _MockPriceTagRepository();
    final productRepo = _FakeProductRepository([_product]);
    await _pumpScreen(tester, repo: repo, productRepo: productRepo);

    await tester.tap(find.byKey(const Key('addProductButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirmAddProductButton')));
    await tester.pumpAndSettle();

    expect(await productRepo.listAll(), hasLength(1));
  });
}
