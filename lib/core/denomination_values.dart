/// Current Indian currency denominations the register counts (₹2000 notes
/// are out of circulation), matching the original Denomination app's grid.
/// Same settings-collection tech debt as [BusinessInfo]/[ExchangeRates] if
/// this list ever needs to change without a rebuild.
class DenominationValues {
  const DenominationValues._();

  static const values = [500, 200, 100, 50, 20, 10, 5, 2, 1];

  /// Notes above this value are excluded from [calculateClosingBalance] —
  /// mirrors the original app's `recalcRegister` rule (`if (v <= 200)`),
  /// where ₹500 notes get banked/removed and only smaller denominations
  /// stay in the till as the working float.
  static const closingBalanceMaxDenomination = 200;
}
