# lalitha_app

Flutter client for the Lalitha Naturals app suite, backed by [`lalitha-backend`](../lalitha-backend)
(PocketBase). See [PROJECT_PLAN.md](../Print/PROJECT_PLAN.md) in the `Print` repo for the full
suite-wide architecture, and its §4/§5 for the data model and API contract this app is built
against.

**Currently implemented: the Print module's Price Tag, Estimate (Quick Items), Coupon, and
Location Card screens** — the first module migrated, per the master plan's phased approach (Print
was chosen first because it's the only one of the four original apps with no existing Google
Sheets integration to migrate). Visiting card, custom text, and the other three apps' modules
follow the same `lib/core` + `lib/features/<module>` pattern once scheduled.

**Fully localized: English (default) + Telugu**, via Flutter's standard `gen-l10n` — see
[Internationalization](#internationalization) below.

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
      print_home_screen.dart   entry point — lists the Print module's tools
      price_tag/                the Price Tag screen + its Riverpod FutureProviders
      estimate/                  the Estimate/Quick Items screen + its FutureProviders
      coupon/                    the Coupon issue/redeem screen + its FutureProviders
      location_card/              the Location Card screen + its FutureProviders
  l10n/
    app_en.arb          English strings (template/default locale)
    app_te.arb           Telugu strings (full parallel translation)
    generated/            AppLocalizations, checked into the repo (see l10n.yaml)
```

Models keep their calculation logic (`calculateFinalPrice`, `calculateEstimateTotal`) as free
functions separate from I/O, so business rules are unit-testable without touching PocketBase or
the widget tree — repositories are tested against a mocked `http.Client`
(`package:http/testing.dart`), and screens are tested with Riverpod provider overrides.

## Internationalization

Uses Flutter's framework-native `gen-l10n` toolchain (`flutter_localizations` + ARB files), not a
custom solution:

- `lib/l10n/app_en.arb` is the template/default locale; `lib/l10n/app_te.arb` is a full parallel
  Telugu translation. Every screen's user-facing strings live in the ARB files, never hardcoded
  in a widget — `AppLocalizations.of(context)!.someKey` throughout.
- `l10n.yaml` configures codegen to write `AppLocalizations` into `lib/l10n/generated/`
  (`output-dir`), which is checked into git rather than left as a hidden build artifact — it's
  reviewable, and `flutter test`/`flutter analyze` don't depend on a codegen step having run
  first (though `flutter pub get` regenerates it automatically if `app_*.arb` changes).
- `MaterialApp` wires `AppLocalizations.localizationsDelegates` /
  `AppLocalizations.supportedLocales` in `main.dart`; the OS locale picks English or Telugu
  automatically, or override with `MaterialApp(locale: Locale('te'), ...)`.
- **Adding a new screen:** add its keys to `app_en.arb` first (with a `@key` description for
  anything non-obvious, and `placeholders` for any interpolated values), add the matching Telugu
  translation to `app_te.arb`, then reference `AppLocalizations.of(context)!.yourKey` in the
  widget. Widget tests should wrap screens with `test/support/localized_test_app.dart`'s
  `localizedTestApp()` helper (or set `localizationsDelegates`/`supportedLocales` directly) —
  without it, `AppLocalizations.of(context)` throws a null-check error.
- Telugu strings were machine-translated for this initial pass using standard business
  vocabulary — **a native speaker should review them before this reaches real staff.**

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
flutter test      # 69 tests: model/calculation unit tests, repository tests against a mocked
                   # HTTP client, widget tests for the Print home/Price Tag/Estimate/Coupon/
                   # Location Card screens, and locale-switching tests (English/Telugu)
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
- `CouponRepository`: issue, redeem (sends only the changed fields), and branch-filtered listing
- `PriceTagScreen`: live-recomputed final price as inputs change, validation before save, and
  that Save actually calls the repository with the computed `PriceTag`
- `EstimateScreen`: live-recomputed running total as item rows are added/edited/removed,
  validation (branch required, at least one item), blank customer name falling back to
  "Walk-in Customer", and that Save calls the repository with the built `Estimate`
- `CouponScreen`: issue validation, that issuing calls the repository with the entered fields,
  the coupon list rendering redeemed vs. not-redeemed state per branch, and that redeeming calls
  the repository and refreshes the list
- `CustomPrint`/`CustomPrintRepository`: `PrintType` JSON round-trip (`custom_text`,
  `visiting_card`, `location_card`), arbitrary `content` map round-trip, and the branch +
  print-type filter sent to PocketBase
- `LocationCardScreen`: print button disabled until a branch is selected, the preview shows the
  selected branch's name/address, printing one branch calls the repository with a
  `location_card` record for it, and "Print Both Branches" calls it once per active branch
- `PrintHomeScreen`/app boot: all four tool tiles are present and navigate to their screens
- Localization: `AppLocalizations.supportedLocales` includes English and Telugu, and a screen
  actually renders Telugu text when the app locale is `te`
