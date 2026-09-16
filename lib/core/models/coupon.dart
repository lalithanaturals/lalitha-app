class Coupon {
  const Coupon({
    this.id,
    required this.couponType,
    required this.branchId,
    this.staffId,
    required this.discountValue,
    this.redeemed = false,
    this.redeemedAt,
  });

  final String? id;
  final String couponType;
  final String branchId;
  final String? staffId;
  final num discountValue;
  final bool redeemed;
  final DateTime? redeemedAt;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json['id'] as String?,
        couponType: (json['coupon_type'] as String?) ?? '',
        branchId: (json['branch'] as String?) ?? '',
        staffId: json['staff'] as String?,
        discountValue: (json['discount_value'] as num?) ?? 0,
        redeemed: (json['redeemed'] as bool?) ?? false,
        redeemedAt: (json['redeemed_at'] as String?)?.isNotEmpty == true
            ? DateTime.tryParse(json['redeemed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'coupon_type': couponType,
        'branch': branchId,
        if (staffId != null) 'staff': staffId,
        'discount_value': discountValue,
        'redeemed': redeemed,
        if (redeemedAt != null) 'redeemed_at': redeemedAt!.toIso8601String(),
      };

  Coupon markRedeemed({DateTime? at}) => Coupon(
        id: id,
        couponType: couponType,
        branchId: branchId,
        staffId: staffId,
        discountValue: discountValue,
        redeemed: true,
        redeemedAt: at ?? DateTime.now(),
      );
}
