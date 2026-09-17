import 'package:pocketbase/pocketbase.dart';

import '../models/staff.dart';

class StaffRepository {
  StaffRepository(this._pb);

  final PocketBase _pb;

  Future<List<Staff>> listForBranch(String branchId) async {
    final records = await _pb.collection('staff').getFullList(
          filter: 'branch = "$branchId" && is_active = true',
          sort: 'name',
        );
    return records.map((r) => Staff.fromJson(r.toJson())).toList();
  }

  /// Every active staff member, regardless of branch — used for the login
  /// screen's "pick your name" picker, which runs before authentication
  /// (`staff.listRule` is public; see lalitha-backend's
  /// 1700000021_staff_pin_login.js).
  Future<List<Staff>> listAllActive() async {
    final records = await _pb.collection('staff').getFullList(
          filter: 'is_active = true',
          sort: 'name',
        );
    return records.map((r) => Staff.fromJson(r.toJson())).toList();
  }
}
