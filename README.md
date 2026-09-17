# lalitha_app

Flutter client for the Lalitha Naturals app suite, backed by [`lalitha-backend`](../lalitha-backend)
(PocketBase). See [PROJECT_PLAN.md](../Print/PROJECT_PLAN.md) in the `Print` repo for the full
suite-wide architecture, and its §4/§5 for the data model and API contract this app is built
against.

**All four modules are live.** The app's home screen is a module picker (`AppHomeScreen`):

- **Print** — fully migrated: all six original screens (Price Tag, Estimate, Coupon, Location
  Card, Visiting Card, Custom Text).
- **Stock-transfer** — Inventory (per-branch stock counts with +/- adjustment) and Transit Sheet
  (dispatch stock between branches). Barcode scanning and offline caching (Stock-transfer's
  PROJECT_PLAN.md §3) are not yet implemented.
- **scrap-calc** — the aluminum/steel Exchange Calculator (Get Estimation / Submit Order) and
  Search (find past estimates/orders by name/phone/ID, convert an estimate to an order).
  Thermal-receipt print preview (scrap-calc's PROJECT_PLAN.md §4) is not yet implemented.
- **Denomination** — the daily cash Audit Register (denomination counts, category line items,
  commit), Archive (browse past registers per branch, expand to view line items), and a BI
  Dashboard (register count, total cash counted, and a per-category breakdown — all summed across
  a branch's registers). Exports (JPEG/PDF/Thermal/WhatsApp — Denomination's PROJECT_PLAN.md §4)
  are not yet implemented.

**Fully localized: English (default) + Telugu**, via Flutter's standard `gen-l10n` — see
[Internationalization](#internationalization) below.

## Architecture

```
lib/
  core/
    client/           AppPocketBaseClient — owns the single PocketBase instance
    models/           Branch, Staff, Product, PriceTag, Estimate/EstimateItem, Coupon,
                       CustomPrint/PrintType, InventoryCategory/InventoryItem/InventoryStock,
                       TransitSheet/TransitSheetItem, ExchangeRecord/MaterialTotals,
                       AuditRegister/AuditLineItem (pure fromJson/toJson + pure calculation
                       helpers, no I/O)
    repositories/      thin wrappers around PocketBase's REST calls per collection
    providers.dart      Riverpod providers wiring client -> repositories
    business_info.dart   static business info (tagline, offerings, phone, website) — see
                          the note in that file about migrating it to the `settings` collection
    exchange_rates.dart   static al/st per-kg rates + per-handle deduction — same
                           settings-collection tech debt as business_info.dart
    denomination_values.dart   the ₹500..₹1 denomination list + the closing-balance cutoff —
                                same settings-collection tech debt
  features/
    app_home_screen.dart   suite-wide entry point — one tile per module (Print, Stock, ...)
    print/
      print_home_screen.dart   lists the Print module's tools
      price_tag/                the Price Tag screen + its Riverpod FutureProviders
      estimate/                  the Estimate/Quick Items screen + its FutureProviders
      coupon/                    the Coupon issue/redeem screen + its FutureProviders
      location_card/              the Location Card screen + its FutureProviders
      visiting_card/               the Visiting Card screen + its FutureProviders
      custom_text/                 the Custom Text screen + its FutureProviders
    stock/
      stock_home_screen.dart    lists the Stock-transfer module's tools
      inventory/                  per-branch stock counts (+/- adjustment) + its FutureProviders
      transit_sheet/               dispatch stock between branches + its FutureProviders
    scrap/
      calculator/                the al/st exchange Calculator + its FutureProviders
      search/                     search past estimates/orders, convert estimate -> order
    denomination/
      denomination_home_screen.dart   lists the Denomination module's tools
      register/                        the Audit Register entry/commit screen + its FutureProviders
      archive/                          browse past registers per branch + its FutureProviders
      dashboard/                        cash/category totals across a branch + its FutureProviders
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
flutter test      # 173 tests: model/calculation unit tests, repository tests against a mocked
                   # HTTP client, widget tests for all six Print-module screens plus
                   # Stock-transfer (Inventory, Transit Sheet), scrap-calc (Calculator, Search),
                   # and Denomination (Audit Register, Archive, Dashboard), the suite-wide
                   # module picker, and locale-switching tests (English/Telugu)
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
- `VisitingCardScreen`: the static preview shows both branches' addresses and business info,
  validation requires a branch selection before printing (for attribution), and printing calls
  the repository with a `visiting_card` record whose `content` covers every active branch
- `CustomTextScreen`: validates a branch and non-empty text before printing, and printing sends
  the text/alignment/bold/font-size fields as a `custom_text` record's `content`
- `PrintHomeScreen`/app boot: all six tool tiles are present and navigate to their screens
- Localization: `AppLocalizations.supportedLocales` includes English and Telugu, and a screen
  actually renders Telugu text when the app locale is `te`
- `InventoryRepository`: `setStockQuantity` upserts correctly (creates when no (item, branch) row
  exists yet, patches the existing row otherwise) and `listItemsForCategory`'s filter
- `TransitSheetRepository`: multi-step create (sheet, then each item tagged with its new parent
  id), the `(from_branch = X || to_branch = X)` filter for `listForBranch`, and that
  `updateStatus` stamps `dispatched_at`/`received_at` only for the relevant transition
- `InventoryScreen`: items with no stock row show quantity 0, +/- calls
  `setStockQuantity(quantity ± 1)`, and − is a no-op (never calls the repository) at quantity 0
- `TransitSheetScreen`: validates both branches selected, that they differ, and that at least one
  item/quantity is entered before dispatching; dispatching sends a `dispatched` sheet with the
  selected item and quantity
- `AppHomeScreen`/`StockHomeScreen`: module and tool tiles are present and navigate correctly
- `ExchangeRecord`/`calculateMaterialTotals`: gross weight sums entered weights, the 0.10kg
  per-handle deduction is applied before pricing (never negative), aluminum/steel are priced at
  their own rate, and `toJson`/`fromJson` round-trip the computed totals and `display_id`
- `ExchangeRecordRepository`: `create` sends the computed totals and surfaces the server-assigned
  `display_id`; `convertToOrder` PATCHes only `status`; `search` builds the
  customer_name/customer_phone/display_id filter (and skips the request entirely for a blank
  query)
- `CalculatorScreen`: the grand total recomputes live as weights are entered or handles are
  adjusted, switching material tabs shows that material's own weight rows and rate, validation
  requires a branch before saving, and Get Estimation/Submit Order create a record with the
  matching status
- `calculateCashTotal`/`calculateClosingBalance`: cash total sums every denomination's
  value × count; closing balance excludes denominations above ₹200 (mirrors the original app's
  "larger notes get banked" rule), including the ₹200 boundary itself
- `AuditRegister`/`AuditLineItem` JSON: `denomination_counts` round-trips between `int` keys in
  Dart and string keys over the wire; `AuditLineCategory` JSON round-trip for all four categories
- `AuditRegisterRepository`: `commit` PATCHes `status`+`committed_by` only; `findPreviousRegister`
  sends a `date <` filter sorted descending (returns `null` when none exists) for the
  opening-balance-chaining lookup; `addLineItem` posts category/name/amount
- `RegisterScreen`: selecting a branch loads the opening balance from the previous register (or 0
  if none), the cash total/closing balance recompute live as denomination counts are entered,
  validation requires a branch before committing, and committing creates the register, then each
  entered line item tagged with its new parent id, then commits it
- `DenominationHomeScreen`: the Register Entry tile is present and navigates to the screen
- `SearchScreen`: results render from `ExchangeRecordRepository.search`, a "no results" message
  shows when the search comes back empty, the "Convert to Order" action appears only on
  `estimate`-status results (never on `order` ones), and converting calls `convertToOrder` and
  updates that result's tile in place
- `CalculatorScreen`: the search icon navigates to `SearchScreen`
- `AuditRegisterRepository.listForBranch`: filters by branch and sorts by date descending
- `ArchiveScreen`: a "no registers" message when a branch has none, each register lists its
  date/status/cash-total/closing-balance, and expanding it shows its line items (or a "no line
  items" message when there are none)
- `calculateCategoryTotals`: sums line-item amounts per category, zeroing categories with no
  items (rather than omitting them), and returns all-zero totals for an empty item list
- `AuditRegisterRepository.listAllLineItemsForBranch`: uses PocketBase's relation-traversal
  filter (`audit_register.branch = X`) to fetch every line item across a branch's registers in
  one request rather than one per register
- `DashboardScreen`: shows the register count and total cash summed across all of a branch's
  registers, the per-category breakdown summed across all of its line items, and all-zero totals
  when the branch has no registers yet
- `DenominationHomeScreen`: the Register Entry, Archive, and Dashboard tiles are all present and
  navigate
