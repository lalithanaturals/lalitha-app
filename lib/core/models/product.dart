class Product {
  const Product({
    required this.id,
    required this.brandName,
    this.defaultPrice = 0,
  });

  final String id;
  final String brandName;
  final num defaultPrice;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        brandName: json['brand_name'] as String,
        defaultPrice: (json['default_price'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'brand_name': brandName,
        'default_price': defaultPrice,
      };
}
