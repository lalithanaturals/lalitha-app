enum DiscountType {
  percent,
  flat;

  static DiscountType fromJson(String? value) => switch (value) {
        'flat' => DiscountType.flat,
        _ => DiscountType.percent,
      };

  String toJson() => name;
}

/// Pure calculation, independent of any model, so both the UI and the
/// [PriceTag] model can share it and it can be unit-tested on its own.
///
/// Mirrors the discount logic from the original Print app's price tag
/// generator: a percent discount is applied against [mrp], a flat discount
/// is subtracted directly. The result never goes below zero.
num calculateFinalPrice({
  required num mrp,
  required DiscountType discountType,
  required num discountValue,
}) {
  final raw = switch (discountType) {
    DiscountType.percent => mrp - (mrp * discountValue / 100),
    DiscountType.flat => mrp - discountValue,
  };
  return raw < 0 ? 0 : raw;
}

class PriceTag {
  const PriceTag({
    this.id,
    required this.productId,
    required this.mrp,
    required this.discountType,
    required this.discountValue,
    required this.finalPrice,
    this.layout = 'standard',
    required this.branchId,
    this.staffId,
  });

  final String? id;
  final String productId;
  final num mrp;
  final DiscountType discountType;
  final num discountValue;
  final num finalPrice;
  final String layout;
  final String branchId;
  final String? staffId;

  factory PriceTag.fromJson(Map<String, dynamic> json) => PriceTag(
        id: json['id'] as String?,
        productId: (json['product'] as String?) ?? '',
        mrp: (json['mrp'] as num?) ?? 0,
        discountType: DiscountType.fromJson(json['discount_type'] as String?),
        discountValue: (json['discount_value'] as num?) ?? 0,
        finalPrice: (json['final_price'] as num?) ?? 0,
        layout: (json['layout'] as String?) ?? 'standard',
        branchId: (json['branch'] as String?) ?? '',
        staffId: json['staff'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'product': productId,
        'mrp': mrp,
        'discount_type': discountType.toJson(),
        'discount_value': discountValue,
        'final_price': finalPrice,
        'layout': layout,
        'branch': branchId,
        if (staffId != null) 'staff': staffId,
      };

  /// Builds a [PriceTag] with [finalPrice] freshly computed from
  /// [mrp]/[discountType]/[discountValue], so callers never have to
  /// remember to keep the two in sync by hand.
  factory PriceTag.compute({
    String? id,
    required String productId,
    required num mrp,
    required DiscountType discountType,
    required num discountValue,
    String layout = 'standard',
    required String branchId,
    String? staffId,
  }) {
    return PriceTag(
      id: id,
      productId: productId,
      mrp: mrp,
      discountType: discountType,
      discountValue: discountValue,
      finalPrice: calculateFinalPrice(
        mrp: mrp,
        discountType: discountType,
        discountValue: discountValue,
      ),
      layout: layout,
      branchId: branchId,
      staffId: staffId,
    );
  }
}
