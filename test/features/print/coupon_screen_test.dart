import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lalitha_app/core/models/branch.dart';
import 'package:lalitha_app/core/models/coupon.dart';
import 'package:lalitha_app/core/models/staff.dart';
import 'package:lalitha_app/core/providers.dart';
import 'package:lalitha_app/core/repositories/coupon_repository.dart';
import 'package:lalitha_app/features/print/coupon/coupon_providers.dart';
import 'package:lalitha_app/features/print/coupon/coupon_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/localized_test_app.dart';

class _MockCouponRepository extends Mock implements CouponRepository {}

const _branch = Branch(id: 'branch1', name: 'Gajuwaka');
const _staff = Staff(id: 'staff1', name: 'Bhargav', branchId: 'branch1');

Future<void> _pumpScreen(
  WidgetTester tester, {
  required CouponRepository repo,
  List<Coupon> existingCoupons = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        couponBranchesProvider.overrideWith((ref) async => [_branch]),
        couponStaffForBranchProvider.overrideWith((ref, branchId) async => [_staff]),
        couponsForBranchProvider.overrideWith((ref, branchId) async => existingCoupons),
        couponRepositoryProvider.overrideWithValue(repo),
      ],
      child: localizedTestApp(home: const CouponScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectBranch(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('couponBranchDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gajuwaka').last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Coupon(couponType: 'fallback', branchId: 'fallback', discountValue: 0),
    );
  });

  testWidgets('shows a validation message when issuing without branch/type', (tester) async {
    final repo = _MockCouponRepository();
    await _pumpScreen(tester, repo: repo);

    await tester.tap(find.byKey(const Key('issueCouponButton')));
    await tester.pump();

    expect(find.textContaining('Select a branch and enter a coupon type'), findsOneWidget);
    verifyNever(() => repo.issue(any()));
  });

  testWidgets('issuing a coupon calls the repository with the entered fields', (tester) async {
    final repo = _MockCouponRepository();
    when(() => repo.issue(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first,
    );
    await _pumpScreen(tester, repo: repo);

    await _selectBranch(tester);
    await tester.enterText(find.byKey(const Key('couponTypeField')), 'festival');
    await tester.enterText(find.byKey(const Key('couponDiscountValueField')), '15');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('issueCouponButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('issueCouponButton')));
    await tester.pumpAndSettle();

    final captured = verify(() => repo.issue(captureAny())).captured;
    expect(captured, hasLength(1));
    final coupon = captured.first as Coupon;
    expect(coupon.couponType, 'festival');
    expect(coupon.branchId, 'branch1');
    expect(coupon.discountValue, 15);
    expect(find.text('Coupon issued'), findsOneWidget);
  });

  testWidgets('lists existing coupons for the selected branch with redeemed status', (tester) async {
    final repo = _MockCouponRepository();
    const coupons = [
      Coupon(id: 'c1', couponType: 'festival', branchId: 'branch1', discountValue: 10, redeemed: false),
      Coupon(id: 'c2', couponType: 'loyalty', branchId: 'branch1', discountValue: 5, redeemed: true),
    ];
    await _pumpScreen(tester, repo: repo, existingCoupons: coupons);

    await _selectBranch(tester);

    expect(find.byKey(const Key('couponTile_c1')), findsOneWidget);
    expect(find.byKey(const Key('couponTile_c2')), findsOneWidget);
    expect(find.byKey(const Key('redeemButton_c1')), findsOneWidget);
    expect(find.byKey(const Key('redeemButton_c2')), findsNothing);
  });

  testWidgets('redeeming a coupon calls the repository and shows a confirmation', (tester) async {
    final repo = _MockCouponRepository();
    const coupon = Coupon(id: 'c1', couponType: 'festival', branchId: 'branch1', discountValue: 10);
    when(() => repo.redeem(any())).thenAnswer(
      (_) async => coupon.markRedeemed(),
    );
    await _pumpScreen(tester, repo: repo, existingCoupons: const [coupon]);

    await _selectBranch(tester);

    await tester.ensureVisible(find.byKey(const Key('redeemButton_c1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('redeemButton_c1')));
    await tester.pumpAndSettle();

    verify(() => repo.redeem('c1')).called(1);
    expect(find.text('Coupon redeemed'), findsOneWidget);
  });
}
