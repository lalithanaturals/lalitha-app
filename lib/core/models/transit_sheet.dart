enum TransitSheetStatus {
  draft,
  dispatched,
  received;

  static TransitSheetStatus fromJson(String? value) => switch (value) {
        'dispatched' => TransitSheetStatus.dispatched,
        'received' => TransitSheetStatus.received,
        _ => TransitSheetStatus.draft,
      };

  String toJson() => name;
}

class TransitSheetItem {
  const TransitSheetItem({
    this.id,
    this.transitSheetId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
  });

  final String? id;
  final String? transitSheetId;
  final String itemId;

  /// Not persisted on `transit_sheet_items` (only `item` id is) — carried
  /// alongside for display convenience while building a sheet in the UI.
  final String itemName;
  final num quantity;

  factory TransitSheetItem.fromJson(Map<String, dynamic> json, {String itemName = ''}) =>
      TransitSheetItem(
        id: json['id'] as String?,
        transitSheetId: json['transit_sheet'] as String?,
        itemId: (json['item'] as String?) ?? '',
        itemName: itemName,
        quantity: (json['quantity'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (transitSheetId != null) 'transit_sheet': transitSheetId,
        'item': itemId,
        'quantity': quantity,
      };
}

class TransitSheet {
  const TransitSheet({
    this.id,
    required this.fromBranchId,
    required this.toBranchId,
    this.staffId,
    this.status = TransitSheetStatus.draft,
    this.dispatchedAt,
    this.receivedAt,
    this.items = const [],
  });

  final String? id;
  final String fromBranchId;
  final String toBranchId;
  final String? staffId;
  final TransitSheetStatus status;
  final DateTime? dispatchedAt;
  final DateTime? receivedAt;
  final List<TransitSheetItem> items;

  factory TransitSheet.fromJson(Map<String, dynamic> json, {List<TransitSheetItem> items = const []}) =>
      TransitSheet(
        id: json['id'] as String?,
        fromBranchId: (json['from_branch'] as String?) ?? '',
        toBranchId: (json['to_branch'] as String?) ?? '',
        staffId: json['staff'] as String?,
        status: TransitSheetStatus.fromJson(json['status'] as String?),
        dispatchedAt: (json['dispatched_at'] as String?)?.isNotEmpty == true
            ? DateTime.tryParse(json['dispatched_at'] as String)
            : null,
        receivedAt: (json['received_at'] as String?)?.isNotEmpty == true
            ? DateTime.tryParse(json['received_at'] as String)
            : null,
        items: items,
      );

  Map<String, dynamic> toJson() => {
        'from_branch': fromBranchId,
        'to_branch': toBranchId,
        if (staffId != null) 'staff': staffId,
        'status': status.toJson(),
        if (dispatchedAt != null) 'dispatched_at': dispatchedAt!.toIso8601String(),
        if (receivedAt != null) 'received_at': receivedAt!.toIso8601String(),
      };
}
