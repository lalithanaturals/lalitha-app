import '../exchange_rates.dart';

enum ExchangeStatus {
  estimate,
  order;

  static ExchangeStatus fromJson(String? value) =>
      value == 'order' ? ExchangeStatus.order : ExchangeStatus.estimate;

  String toJson() => name;
}

/// One material's computed weight/value breakdown.
///
/// [handlesDeductionKg] and [netWeightKg] are in kilograms (mirrors the
/// original app deducting handle weight from the gross weight before
/// pricing); [cost] is in rupees (`netWeightKg * ratePerKg`).
class MaterialTotals {
  const MaterialTotals({
    required this.grossWeightKg,
    required this.handlesDeductionKg,
    required this.netWeightKg,
    required this.cost,
  });

  final num grossWeightKg;
  final num handlesDeductionKg;
  final num netWeightKg;
  final num cost;
}

/// Pure calculation matching the original scrap-calc app's `computeMaterial`:
/// gross weight minus a fixed per-handle deduction, priced at [ratePerKg].
/// Never goes negative.
MaterialTotals calculateMaterialTotals({
  required List<num> weights,
  required num handles,
  required num ratePerKg,
}) {
  final gross = weights.fold<num>(0, (sum, w) => sum + w);
  final handlesDeductionKg = handles * ExchangeRates.handleDeductionPerHandleKg;
  final netWeightKg = (gross - handlesDeductionKg).clamp(0, double.infinity);
  final cost = netWeightKg * ratePerKg;
  return MaterialTotals(
    grossWeightKg: gross,
    handlesDeductionKg: handlesDeductionKg,
    netWeightKg: netWeightKg,
    cost: cost,
  );
}

class ExchangeRecord {
  const ExchangeRecord({
    this.id,
    this.displayId,
    required this.branchId,
    this.staffId,
    this.customerName = 'Walk-in Customer',
    this.customerPhone = '',
    this.status = ExchangeStatus.estimate,
    this.alWeights = const [],
    this.alHandles = 0,
    this.stWeights = const [],
    this.stHandles = 0,
  });

  final String? id;
  final String? displayId;
  final String branchId;
  final String? staffId;
  final String customerName;
  final String customerPhone;
  final ExchangeStatus status;
  final List<num> alWeights;
  final num alHandles;
  final List<num> stWeights;
  final num stHandles;

  MaterialTotals get alTotals => calculateMaterialTotals(
        weights: alWeights,
        handles: alHandles,
        ratePerKg: ExchangeRates.ratePerKg['al']!,
      );

  MaterialTotals get stTotals => calculateMaterialTotals(
        weights: stWeights,
        handles: stHandles,
        ratePerKg: ExchangeRates.ratePerKg['st']!,
      );

  num get grossTotalKg => alTotals.grossWeightKg + stTotals.grossWeightKg;
  num get handlesDeductionKg => alTotals.handlesDeductionKg + stTotals.handlesDeductionKg;
  num get netTotalAmount => alTotals.cost + stTotals.cost;

  factory ExchangeRecord.fromJson(Map<String, dynamic> json) => ExchangeRecord(
        id: json['id'] as String?,
        displayId: json['display_id'] as String?,
        branchId: (json['branch'] as String?) ?? '',
        staffId: json['staff'] as String?,
        customerName: (json['customer_name'] as String?)?.isNotEmpty == true
            ? json['customer_name'] as String
            : 'Walk-in Customer',
        customerPhone: (json['customer_phone'] as String?) ?? '',
        status: ExchangeStatus.fromJson(json['status'] as String?),
        alWeights: ((json['al_weights'] as List?) ?? const []).cast<num>(),
        alHandles: (json['al_handles'] as num?) ?? 0,
        stWeights: ((json['st_weights'] as List?) ?? const []).cast<num>(),
        stHandles: (json['st_handles'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'branch': branchId,
        if (staffId != null) 'staff': staffId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'status': status.toJson(),
        'al_weights': alWeights,
        'al_handles': alHandles,
        'st_weights': stWeights,
        'st_handles': stHandles,
        'gross_total': grossTotalKg,
        'handles_deduction': handlesDeductionKg,
        'net_total': netTotalAmount,
      };
}
