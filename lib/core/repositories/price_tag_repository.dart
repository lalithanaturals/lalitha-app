import 'package:pocketbase/pocketbase.dart';

import '../models/price_tag.dart';

class PriceTagRepository {
  PriceTagRepository(this._pb);

  final PocketBase _pb;

  Future<List<PriceTag>> listForBranch(String branchId, {int page = 1, int perPage = 30}) async {
    final result = await _pb.collection('price_tags').getList(
          page: page,
          perPage: perPage,
          filter: 'branch = "$branchId"',
          sort: '-created',
        );
    return result.items.map((r) => PriceTag.fromJson(r.toJson())).toList();
  }

  Future<PriceTag> create(PriceTag tag) async {
    final record = await _pb.collection('price_tags').create(body: tag.toJson());
    return PriceTag.fromJson(record.toJson());
  }

  Future<PriceTag> update(PriceTag tag) async {
    assert(tag.id != null, 'cannot update a PriceTag without an id');
    final record = await _pb.collection('price_tags').update(tag.id!, body: tag.toJson());
    return PriceTag.fromJson(record.toJson());
  }

  Future<void> delete(String id) => _pb.collection('price_tags').delete(id);
}
