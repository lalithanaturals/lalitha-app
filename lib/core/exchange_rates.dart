/// Static per-kg exchange rates and the per-handle weight deduction, mirroring
/// the original scrap-calc app's hardcoded `rates = { al: 150.00, st: 50.00 }`
/// and `handles * 0.10` deduction. Same tech debt flagged for
/// [BusinessInfo] — a future pass should move this into the `settings`
/// collection so it's admin-editable without a rebuild (scrap-calc's
/// PROJECT_PLAN.md §5 raises the same question).
class ExchangeRates {
  const ExchangeRates._();

  static const ratePerKg = {'al': 150.0, 'st': 50.0};
  static const handleDeductionPerHandleKg = 0.10;
}
