enum PrintType {
  customText,
  visitingCard,
  locationCard;

  static PrintType fromJson(String? value) => switch (value) {
        'visiting_card' => PrintType.visitingCard,
        'location_card' => PrintType.locationCard,
        _ => PrintType.customText,
      };

  String toJson() => switch (this) {
        PrintType.customText => 'custom_text',
        PrintType.visitingCard => 'visiting_card',
        PrintType.locationCard => 'location_card',
      };
}

/// Backs the `custom_prints` collection, which covers the three remaining
/// Print-module screens (location card, visiting card, custom text) — each
/// differs only in [printType] and the shape of [content].
class CustomPrint {
  const CustomPrint({
    this.id,
    required this.printType,
    required this.content,
    required this.branchId,
    this.staffId,
  });

  final String? id;
  final PrintType printType;
  final Map<String, dynamic> content;
  final String branchId;
  final String? staffId;

  factory CustomPrint.fromJson(Map<String, dynamic> json) => CustomPrint(
        id: json['id'] as String?,
        printType: PrintType.fromJson(json['print_type'] as String?),
        content: (json['content'] as Map?)?.cast<String, dynamic>() ?? const {},
        branchId: (json['branch'] as String?) ?? '',
        staffId: json['staff'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'print_type': printType.toJson(),
        'content': content,
        'branch': branchId,
        if (staffId != null) 'staff': staffId,
      };
}
