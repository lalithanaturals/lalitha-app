import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import 'client/pocketbase_client.dart';
import 'repositories/branch_repository.dart';
import 'repositories/coupon_repository.dart';
import 'repositories/estimate_repository.dart';
import 'repositories/price_tag_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/staff_repository.dart';

/// Override this in `main.dart`/tests to point at the Pi/cloud deployment
/// or a local dev instance — see lalitha-backend/PROJECT_PLAN.md §5.1.
final backendBaseUrlProvider = Provider<String>((ref) => 'http://127.0.0.1:8090');

final pocketBaseClientProvider = Provider<AppPocketBaseClient>((ref) {
  return AppPocketBaseClient(ref.watch(backendBaseUrlProvider));
});

final pocketBaseProvider = Provider<PocketBase>((ref) {
  return ref.watch(pocketBaseClientProvider).pb;
});

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository(ref.watch(pocketBaseProvider));
});

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.watch(pocketBaseProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(pocketBaseProvider));
});

final priceTagRepositoryProvider = Provider<PriceTagRepository>((ref) {
  return PriceTagRepository(ref.watch(pocketBaseProvider));
});

final estimateRepositoryProvider = Provider<EstimateRepository>((ref) {
  return EstimateRepository(ref.watch(pocketBaseProvider));
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepository(ref.watch(pocketBaseProvider));
});
