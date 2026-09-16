class Branch {
  const Branch({
    required this.id,
    required this.name,
    this.address = '',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final bool isActive;

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as String,
        name: json['name'] as String,
        address: (json['address'] as String?) ?? '',
        isActive: (json['is_active'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'is_active': isActive,
      };
}
