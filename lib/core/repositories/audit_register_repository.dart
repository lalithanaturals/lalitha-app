import 'package:pocketbase/pocketbase.dart';

import '../models/audit_register.dart';

class AuditRegisterRepository {
  AuditRegisterRepository(this._pb);

  final PocketBase _pb;

  Future<AuditRegister> create(AuditRegister register) async {
    final record = await _pb.collection('audit_registers').create(body: register.toJson());
    return AuditRegister.fromJson(record.toJson());
  }

  Future<AuditRegister> commit(String id, {String? committedByStaffId}) async {
    final record = await _pb.collection('audit_registers').update(
          id,
          body: {
            'status': 'committed',
            'committed_by': ?committedByStaffId,
          },
        );
    return AuditRegister.fromJson(record.toJson());
  }

  /// The most recent register for [branchId] strictly before [date] — used
  /// to auto-fill the next day's opening balance from the prior closing
  /// balance (mirrors the original app's `loadOpeningBalance`).
  Future<AuditRegister?> findPreviousRegister(String branchId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day).toIso8601String();
    final result = await _pb.collection('audit_registers').getList(
          page: 1,
          perPage: 1,
          filter: 'branch = "$branchId" && date < "$dateOnly"',
          sort: '-date',
        );
    if (result.items.isEmpty) return null;
    return AuditRegister.fromJson(result.items.first.toJson());
  }

  /// Archive listing for a branch, most recent first — powers the
  /// Archive/Search screen (Denomination/PROJECT_PLAN.md §4 #3).
  Future<List<AuditRegister>> listForBranch(String branchId) async {
    final records = await _pb.collection('audit_registers').getFullList(
          filter: 'branch = "$branchId"',
          sort: '-date',
        );
    return records.map((r) => AuditRegister.fromJson(r.toJson())).toList();
  }

  Future<List<AuditLineItem>> listLineItems(String auditRegisterId) async {
    final records = await _pb.collection('audit_line_items').getFullList(
          filter: 'audit_register = "$auditRegisterId"',
        );
    return records.map((r) => AuditLineItem.fromJson(r.toJson())).toList();
  }

  Future<AuditLineItem> addLineItem(AuditLineItem item) async {
    final record = await _pb.collection('audit_line_items').create(body: item.toJson());
    return AuditLineItem.fromJson(record.toJson());
  }
}
