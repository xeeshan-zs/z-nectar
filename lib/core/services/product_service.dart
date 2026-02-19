import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/product_model.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final _col = FirebaseFirestore.instance.collection('products');

  /// Stream all products
  Stream<List<ProductModel>> getProducts() {
    return _col.orderBy('name').snapshots().map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Stream products by category
  Stream<List<ProductModel>> getByCategory(String categoryId) {
    return _col
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Stream exclusive products (admin-flagged)
  Stream<List<ProductModel>> getExclusiveProducts() {
    return _col
        .where('isExclusive', isEqualTo: true)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Stream best-selling products (top 10 by salesCount)
  Stream<List<ProductModel>> getBestSellingProducts() {
    return _col
        .where('inStock', isEqualTo: true)
        .orderBy('salesCount', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Increment sales count for a list of product IDs
  Future<void> incrementSalesCount(List<String> productIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final id in productIds) {
      batch.update(_col.doc(id), {
        'salesCount': FieldValue.increment(1),
      });
    }
    await batch.commit();
  }

  /// Add a new product
  Future<void> addProduct(ProductModel product) async {
    await _col.add(product.toMap());
  }

  /// Update an existing product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _col.doc(id).delete();
  }

  /// Toggle in-stock status
  Future<void> toggleStock(String id, bool inStock) async {
    await _col.doc(id).update({'inStock': inStock});
  }

  /// Toggle exclusive status
  Future<void> toggleExclusive(String id, bool isExclusive) async {
    await _col.doc(id).update({'isExclusive': isExclusive});
  }

  /// Stream carousel products (admin-flagged)
  Stream<List<ProductModel>> getCarouselProducts() {
    return _col
        .where('isCarousel', isEqualTo: true)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Stream featured products (admin-flagged)
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _col
        .where('isFeatured', isEqualTo: true)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Toggle carousel status
  Future<void> toggleCarousel(String id, bool isCarousel) async {
    await _col.doc(id).update({'isCarousel': isCarousel});
  }

  /// Toggle featured status
  Future<void> toggleFeatured(String id, bool isFeatured) async {
    await _col.doc(id).update({'isFeatured': isFeatured});
  }

  /// Get product count
  Future<int> getProductCount() async {
    final snap = await _col.count().get();
    return snap.count ?? 0;
  }
}
