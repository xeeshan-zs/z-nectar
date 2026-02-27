import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/product_model.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final _col = FirebaseFirestore.instance.collection('products');
  
  // In-memory cache for search to prevent excessive reads
  List<ProductModel>? _searchCache;
  DateTime? _lastCacheTime;

  /// Stream all products
  Stream<List<ProductModel>> getProducts() {
    return _col.orderBy('name').snapshots().map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .toList();
    }).asBroadcastStream();
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
    }).asBroadcastStream();
  }

  /// Stream exclusive products (admin-flagged)
  Stream<List<ProductModel>> getExclusiveProducts() {
    return _col
        .where('isExclusive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .where((p) => p.inStock)
          .toList();
    }).asBroadcastStream();
  }

  /// Stream best-selling products (top 10 by salesCount)
  Stream<List<ProductModel>> getBestSellingProducts() {
    return _col
        .orderBy('salesCount', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .where((p) => p.inStock)
          .toList();
    }).asBroadcastStream();
  }

  /// Check if multiple products have sufficient stock (used right before checkout)
  /// Returns a map of { productId : (availableStock) } for items that do NOT have enough stock.
  /// If the map is empty, all requested quantities are available.
  Future<Map<String, int>> checkStockAvailability(Map<String, int> requestedQty) async {
    final insufficientStock = <String, int>{};
    for (final entry in requestedQty.entries) {
      final snap = await _col.doc(entry.key).get();
      if (!snap.exists) {
        insufficientStock[entry.key] = 0; // deleted product
        continue;
      }
      final data = snap.data() as Map<String, dynamic>;
      final currentStock = (data['stockCount'] as num?)?.toInt() ?? 0;
      final inStock = data['inStock'] as bool? ?? true;
      if (!inStock || currentStock < entry.value) {
        insufficientStock[entry.key] = currentStock;
      }
    }
    return insufficientStock;
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

  /// Decrement stockCount for each ordered item; set inStock=false when stock hits 0
  Future<void> decrementStockCount(
      Map<String, int> productIdToQty) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final entry in productIdToQty.entries) {
      final snap = await _col.doc(entry.key).get();
      if (!snap.exists) continue;
      final data = snap.data() as Map<String, dynamic>;
      final currentStock = (data['stockCount'] as num?)?.toInt() ?? 0;
      if (currentStock <= 0) continue; // already 0, skip
      final newStock = (currentStock - entry.value).clamp(0, currentStock);
      batch.update(_col.doc(entry.key), {
        'stockCount': newStock,
        if (newStock == 0) 'inStock': false,
      });
    }
    await batch.commit();
  }

  /// Restore stockCount when an order is cancelled
  Future<void> restoreStockCount(List<dynamic> items) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final item in items) {
      final productId = item.productId as String?;
      final qty = item.qty as int?;
      if (productId == null || productId.isEmpty || qty == null || qty <= 0) continue;
      batch.update(_col.doc(productId), {
        'stockCount': FieldValue.increment(qty),
        'inStock': true,
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
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .where((p) => p.inStock)
          .toList();
    }).asBroadcastStream();
  }

  /// Stream featured products (admin-flagged)
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _col
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ProductModel.fromMap(d.id, d.data()))
          .where((p) => p.inStock)
          .toList();
    }).asBroadcastStream();
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

  /// Fetch all products once (for search suggestions)
  Future<List<ProductModel>> getAllProductsOnce() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList();
  }

  /// Search products by name (client-side, case-insensitive)
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    // Refresh cache if it's older than 5 minutes or null
    final now = DateTime.now();
    if (_searchCache == null || 
        _lastCacheTime == null || 
        now.difference(_lastCacheTime!).inMinutes > 5) {
      _searchCache = await getAllProductsOnce();
      _lastCacheTime = now;
    }

    final lower = query.toLowerCase();
    return _searchCache!
        .where((p) => p.name.toLowerCase().contains(lower) || 
                      p.description.toLowerCase().contains(lower))
        .toList();
  }
}
