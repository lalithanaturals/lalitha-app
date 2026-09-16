class EstimateItem {
  const EstimateItem({
    this.id,
    this.estimateId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  final String? id;
  final String? estimateId;
  final String itemName;
  final num quantity;
  final num unitPrice;

  num get lineTotal => quantity * unitPrice;

  factory EstimateItem.fromJson(Map<String, dynamic> json) => EstimateItem(
        id: json['id'] as String?,
        estimateId: json['estimate'] as String?,
        itemName: json['item_name'] as String,
        quantity: (json['quantity'] as num?) ?? 1,
        unitPrice: (json['unit_price'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (estimateId != null) 'estimate': estimateId,
        'item_name': itemName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'line_total': lineTotal,
      };
}

/// Sums line totals for a list of items — the same rule the original
/// Print app's "Quick Items" table used to compute its running total.
num calculateEstimateTotal(List<EstimateItem> items) {
  return items.fold<num>(0, (sum, item) => sum + item.lineTotal);
}

class Estimate {
  const Estimate({
    this.id,
    required this.branchId,
    this.staffId,
    this.customerName = 'Walk-in Customer',
    this.customerPhone = '',
    this.items = const [],
  });

  final String? id;
  final String branchId;
  final String? staffId;
  final String customerName;
  final String customerPhone;
  final List<EstimateItem> items;

  num get totalAmount => calculateEstimateTotal(items);

  factory Estimate.fromJson(Map<String, dynamic> json, {List<EstimateItem> items = const []}) =>
      Estimate(
        id: json['id'] as String?,
        branchId: (json['branch'] as String?) ?? '',
        staffId: json['staff'] as String?,
        customerName: (json['customer_name'] as String?) ?? 'Walk-in Customer',
        customerPhone: (json['customer_phone'] as String?) ?? '',
        items: items,
      );

  Map<String, dynamic> toJson() => {
        'branch': branchId,
        if (staffId != null) 'staff': staffId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'total_amount': totalAmount,
      };
}
