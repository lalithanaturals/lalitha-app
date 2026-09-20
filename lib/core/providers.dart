import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import 'client/pocketbase_client.dart';
import 'repositories/audit_register_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/branch_repository.dart';
import 'repositories/coupon_repository.dart';
import 'repositories/custom_print_repository.dart';
import 'repositories/estimate_repository.dart';
import 'repositories/exchange_record_repository.dart';
import 'repositories/inventory_repository.dart';
import 'repositories/price_tag_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/staff_repository.dart';
import 'repositories/transit_sheet_repository.dart';

/// Override this in tests (or via `main.dart`) to point at a local dev
/// instance instead — see lalitha-api/PROJECT_PLAN.md §5.1. Defaults to the
/// Pi deployment (lalitha-api's `lipi.online` vhost, TLS-terminated by
/// Apache — see lalitha-api/README.md's "Deploying to the Raspberry Pi").
final backendBaseUrlProvider = Provider<String>((ref) => 'https://lipi.online');

final pocketBaseClientProvider = Provider<AppPocketBaseClient>((ref) {
  return AppPocketBaseClient(ref.watch(backendBaseUrlProvider));
});

final pocketBaseProvider = Provider<PocketBase>((ref) {
  return ref.watch(pocketBaseClientProvider).pb;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(pocketBaseProvider));
});

/// True once staff PIN login succeeds, false after logout/token expiry —
/// drives the AuthGate that picks between StaffLoginScreen and
/// AppHomeScreen in main.dart.
final authStateProvider = StreamProvider<bool>((ref) async* {
  final pb = ref.watch(pocketBaseProvider);
  yield pb.authStore.isValid;
  yield* pb.authStore.onChange.map((_) => pb.authStore.isValid);
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

final customPrintRepositoryProvider = Provider<CustomPrintRepository>((ref) {
  return CustomPrintRepository(ref.watch(pocketBaseProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(pocketBaseProvider));
});

final transitSheetRepositoryProvider = Provider<TransitSheetRepository>((ref) {
  return TransitSheetRepository(ref.watch(pocketBaseProvider));
});

final exchangeRecordRepositoryProvider = Provider<ExchangeRecordRepository>((ref) {
  return ExchangeRecordRepository(ref.watch(pocketBaseProvider));
});

final auditRegisterRepositoryProvider = Provider<AuditRegisterRepository>((ref) {
  return AuditRegisterRepository(ref.watch(pocketBaseProvider));
});
