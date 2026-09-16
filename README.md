# lalitha_app

Flutter client for the Lalitha Naturals app suite, backed by [`lalitha-backend`](../lalitha-backend)
(PocketBase). See [PROJECT_PLAN.md](../Print/PROJECT_PLAN.md) in the `Print` repo for the full
suite-wide architecture, and its §4/§5 for the data model and API contract this app is built
against.

**Currently implemented: the Print module's Price Tag screen** — the first module migrated, per
the master plan's phased approach (Print was chosen first because it's the only one of the four
original apps with no existing Google Sheets integration to migrate). Estimates, coupons, and the
other three apps' modules follow the same `lib/core` + `lib/features/<module>` pattern once
scheduled.

## Architecture

```
lib/
  core/
    client/           AppPocketBaseClient — owns the single PocketBase instance
    models/           Branch, Staff, Product, PriceTag, Estimate/EstimateItem, Coupon
                       (pure fromJson/toJson + pure calculation helpers, no I/O)
    repositories/      thin wrappers around PocketBase's REST calls per collection
    providers.dart      Riverpod providers wiring client -> repositories
  features/
    print/
      price_tag/        the Price Tag screen + its Riverpod FutureProviders
```

Models keep their calculation logic (`calculateFinalPrice`, `calculateEstimateTotal`) as free
functions separate from I/O, so business rules are unit-testable without touching PocketBase or
the widget tree — repositories are tested against a mocked `http.Client`
(`package:http/testing.dart`), and screens are tested with Riverpod provider overrides.

## Running

Point the app at a running `lalitha-backend` instance (defaults to `http://127.0.0.1:8090` —
override `backendBaseUrlProvider` in `lib/core/providers.dart` or via a `ProviderScope` override
for a Pi/cloud deployment):

```bash
flutter run
```

## Testing

```bash
flutter analyze   # static analysis — currently clean
flutter test      # 37 tests: model/calculation unit tests, repository tests against a mocked
                   # HTTP client, and widget tests for the Price Tag screen
```

No Docker/network is required to run `flutter test` — repository tests fake the PocketBase HTTP
layer directly, and screen tests override the Riverpod providers with fixed data, so the whole
suite runs fully offline and deterministically.

### What's covered

- `PriceTag`: discount math (`calculateFinalPrice` for percent/flat, clamped at zero),
  `DiscountType` JSON parsing, full JSON round-trip
- `Estimate`/`EstimateItem`: line-total and running-total math, JSON shape sent to the backend
- `Coupon`: redeem lifecycle, JSON round-trip of `redeemed_at`
- `Branch`/`Staff`/`Product`: JSON parsing and defaults
- `PriceTagRepository`: request shape (filter/method/path) sent to PocketBase for list/create/delete
- `EstimateRepository`: multi-step create (estimate, then each item tagged with its new parent id)
- `CouponRepository`: redeem sends only the changed fields
- `PriceTagScreen`: live-recomputed final price as inputs change, validation before save, and
  that Save actually calls the repository with the computed `PriceTag`
