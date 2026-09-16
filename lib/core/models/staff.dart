class Staff {
  const Staff({
    required this.id,
    required this.name,
    required this.branchId,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String branchId;
  final bool isActive;

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] as String,
        name: json['name'] as String,
        branchId: (json['branch'] as String?) ?? '',
        isActive: (json['is_active'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'branch': branchId,
        'is_active': isActive,
      };
}
