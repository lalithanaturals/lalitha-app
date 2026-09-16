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
}
