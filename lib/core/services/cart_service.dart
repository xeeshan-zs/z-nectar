import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/product_model.dart';

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final _firestore = FirebaseFirestore.instance;

  /// Get the cart sub-collection for a user
  CollectionReference _cartCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('cart');

  /// Stream all cart items for the current user
  Stream<List<CartItem>> getCartItems(String userId) {
    return _cartCol(userId).snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return CartItem.fromMap(d.id, data);
      }).toList();
    });
  }

  /// Add a product to cart (or increment qty if already exists)
  Future<void> addToCart(String userId, ProductModel product, {int qty = 1}) async {
    final docRef = _cartCol(userId).doc(product.id);
    final snap = await docRef.get();

    if (snap.exists) {
      // Increment quantity
      final current = (snap.data() as Map<String, dynamic>)['qty'] as int? ?? 1;
      await docRef.update({'qty': current + qty});
    } else {
      await docRef.set({
        'productId': product.id,
        'name': product.name,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'unit': product.unit,
        'qty': qty,
      });
    }
  }

  /// Update item quantity
  Future<void> updateQty(String userId, String productId, int newQty) async {
    if (newQty <= 0) {
      await removeFromCart(userId, productId);
    } else {
      await _cartCol(userId).doc(productId).update({'qty': newQty});
    }
  }

  /// Remove an item from cart
  Future<void> removeFromCart(String userId, String productId) async {
    await _cartCol(userId).doc(productId).delete();
  }

  /// Safely remove multiple items from the cart via batch
  Future<void> removeItemsFromCartBatch(String userId, List<String> productIds) async {
    final batch = _firestore.batch();
    for (final productId in productIds) {
      batch.delete(_cartCol(userId).doc(productId));
    }
    await batch.commit();
  }

  /// Clear the entire cart
  Future<void> clearCart(String userId) async {
    final snap = await _cartCol(userId).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Get cart item count (for badge)
  Stream<int> getCartItemCount(String userId) {
    return _cartCol(userId).snapshots().map((snap) => snap.docs.length);
  }
}

/// Model for a cart item
class CartItem {
  final String id; // same as productId
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final String unit;
  int qty;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.qty,
  });

  factory CartItem.fromMap(String id, Map<String, dynamic> map) {
    return CartItem(
      id: id,
      productId: map['productId'] as String? ?? id,
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      qty: (map['qty'] as num?)?.toInt() ?? 1,
    );
  }

  double get totalPrice => price * qty;
}
