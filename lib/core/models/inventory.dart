class InventoryCategory {
  const InventoryCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory InventoryCategory.fromJson(Map<String, dynamic> json) => InventoryCategory(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'name': name};
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.code = '',
    this.uom = '',
    this.minLimit = 0,
  });

  final String id;
  final String categoryId;
  final String name;
  final String code;
  final String uom;
  final num minLimit;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        categoryId: (json['category'] as String?) ?? '',
        name: json['name'] as String,
        code: (json['code'] as String?) ?? '',
        uom: (json['uom'] as String?) ?? '',
        minLimit: (json['min_limit'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'category': categoryId,
        'name': name,
        'code': code,
        'uom': uom,
        'min_limit': minLimit,
      };
}

class InventoryStock {
  const InventoryStock({
    this.id,
    required this.itemId,
    required this.branchId,
    required this.quantity,
    this.updatedByStaffId,
  });

  final String? id;
  final String itemId;
  final String branchId;
  final num quantity;
  final String? updatedByStaffId;

  factory InventoryStock.fromJson(Map<String, dynamic> json) => InventoryStock(
        id: json['id'] as String?,
        itemId: (json['item'] as String?) ?? '',
        branchId: (json['branch'] as String?) ?? '',
        quantity: (json['quantity'] as num?) ?? 0,
        updatedByStaffId: json['updated_by'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'item': itemId,
        'branch': branchId,
        'quantity': quantity,
        if (updatedByStaffId != null) 'updated_by': updatedByStaffId,
      };
}
