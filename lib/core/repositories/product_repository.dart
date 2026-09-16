import 'package:pocketbase/pocketbase.dart';

import '../models/product.dart';

class ProductRepository {
  ProductRepository(this._pb);

  final PocketBase _pb;

  Future<List<Product>> listAll() async {
    final records = await _pb.collection('products').getFullList(sort: 'brand_name');
    return records.map((r) => Product.fromJson(r.toJson())).toList();
  }

  Future<Product> create(Product product) async {
    final record = await _pb.collection('products').create(body: product.toJson());
    return Product.fromJson(record.toJson());
  }
}
