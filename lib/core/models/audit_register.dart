import '../denomination_values.dart';

enum AuditLineCategory {
  expense,
  ownerBill,
  vendorBill,
  unbilled;

  static AuditLineCategory fromJson(String? value) => switch (value) {
        'owner_bill' => AuditLineCategory.ownerBill,
        'vendor_bill' => AuditLineCategory.vendorBill,
        'unbilled' => AuditLineCategory.unbilled,
        _ => AuditLineCategory.expense,
      };

  String toJson() => switch (this) {
        AuditLineCategory.expense => 'expense',
        AuditLineCategory.ownerBill => 'owner_bill',
        AuditLineCategory.vendorBill => 'vendor_bill',
        AuditLineCategory.unbilled => 'unbilled',
      };
}

class AuditLineItem {
  const AuditLineItem({
    this.id,
    this.auditRegisterId,
    required this.category,
    required this.name,
    required this.amount,
  });

  final String? id;
  final String? auditRegisterId;
  final AuditLineCategory category;
  final String name;
  final num amount;

  factory AuditLineItem.fromJson(Map<String, dynamic> json) => AuditLineItem(
        id: json['id'] as String?,
        auditRegisterId: json['audit_register'] as String?,
        category: AuditLineCategory.fromJson(json['category'] as String?),
        name: (json['name'] as String?) ?? '',
        amount: (json['amount'] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (auditRegisterId != null) 'audit_register': auditRegisterId,
        'category': category.toJson(),
        'name': name,
        'amount': amount,
      };
}

enum AuditRegisterStatus {
  draft,
  committed;

  static AuditRegisterStatus fromJson(String? value) =>
      value == 'committed' ? AuditRegisterStatus.committed : AuditRegisterStatus.draft;

  String toJson() => name;
}

/// Sums line-item amounts per category — powers the BI Dashboard's
/// per-category breakdown across a branch's registers.
Map<AuditLineCategory, num> calculateCategoryTotals(List<AuditLineItem> items) {
  final totals = <AuditLineCategory, num>{
    for (final c in AuditLineCategory.values) c: 0,
  };
  for (final item in items) {
    totals[item.category] = (totals[item.category] ?? 0) + item.amount;
  }
  return totals;
}

/// Total cash counted across every denomination.
num calculateCashTotal(Map<int, int> denominationCounts) => denominationCounts.entries
    .fold<num>(0, (sum, entry) => sum + entry.key * entry.value);

/// Closing balance kept in the till: only denominations at or below
/// [DenominationValues.closingBalanceMaxDenomination] count (mirrors the
/// original app — larger notes get banked/removed).
num calculateClosingBalance(Map<int, int> denominationCounts) => denominationCounts.entries
    .where((e) => e.key <= DenominationValues.closingBalanceMaxDenomination)
    .fold<num>(0, (sum, entry) => sum + entry.key * entry.value);

class AuditRegister {
  const AuditRegister({
    this.id,
    required this.date,
    required this.branchId,
    this.openingBalance = 0,
    this.closingBalance = 0,
    this.denominationCounts = const {},
    this.cashTotal = 0,
    this.status = AuditRegisterStatus.draft,
    this.committedByStaffId,
  });

  final String? id;
  final DateTime date;
  final String branchId;
  final num openingBalance;
  final num closingBalance;
  final Map<int, int> denominationCounts;
  final num cashTotal;
  final AuditRegisterStatus status;
  final String? committedByStaffId;

  factory AuditRegister.fromJson(Map<String, dynamic> json) {
    final rawCounts = (json['denomination_counts'] as Map?) ?? const {};
    final counts = <int, int>{
      for (final entry in rawCounts.entries)
        int.parse(entry.key as String): (entry.value as num).toInt(),
    };
    return AuditRegister(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      branchId: (json['branch'] as String?) ?? '',
      openingBalance: (json['opening_balance'] as num?) ?? 0,
      closingBalance: (json['closing_balance'] as num?) ?? 0,
      denominationCounts: counts,
      cashTotal: (json['cash_total'] as num?) ?? 0,
      status: AuditRegisterStatus.fromJson(json['status'] as String?),
      committedByStaffId: json['committed_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'branch': branchId,
        'opening_balance': openingBalance,
        'closing_balance': closingBalance,
        'denomination_counts': {
          for (final entry in denominationCounts.entries) entry.key.toString(): entry.value,
        },
        'cash_total': cashTotal,
        'status': status.toJson(),
        if (committedByStaffId != null) 'committed_by': committedByStaffId,
      };
}
