import 'package:pocketbase/pocketbase.dart';

import '../models/branch.dart';

class BranchRepository {
  BranchRepository(this._pb);

  final PocketBase _pb;

  Future<List<Branch>> listActive() async {
    final records = await _pb.collection('branches').getFullList(
          filter: 'is_active = true',
          sort: 'name',
        );
    return records.map((r) => Branch.fromJson(r.toJson())).toList();
  }
}
