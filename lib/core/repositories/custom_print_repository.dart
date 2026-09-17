import 'package:pocketbase/pocketbase.dart';

import '../models/custom_print.dart';

class CustomPrintRepository {
  CustomPrintRepository(this._pb);

  final PocketBase _pb;

  Future<CustomPrint> create(CustomPrint print) async {
    final record = await _pb.collection('custom_prints').create(body: print.toJson());
    return CustomPrint.fromJson(record.toJson());
  }

  Future<List<CustomPrint>> listForBranch(String branchId, {required PrintType printType}) async {
    final records = await _pb.collection('custom_prints').getFullList(
          filter: 'branch = "$branchId" && print_type = "${printType.toJson()}"',
          sort: '-created',
        );
    return records.map((r) => CustomPrint.fromJson(r.toJson())).toList();
  }
}
