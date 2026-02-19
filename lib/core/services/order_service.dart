import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/order_model.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final _col = FirebaseFirestore.instance.collection('orders');

  /// Stream all orders (newest first)
  Stream<List<OrderModel>> getAllOrders() {
    return _col.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => OrderModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime); // newest first
      });
      return list;
    });
  }

  /// Stream orders by status
  Stream<List<OrderModel>> getOrdersByStatus(String status) {
    return _col
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => OrderModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime); // newest first
      });
      return list;
    });
  }

  /// Stream orders for a specific user
  Stream<List<OrderModel>> getOrdersByUser(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => OrderModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime); // newest first
      });
      return list;
    });
  }

  /// Update order status
  Future<void> updateStatus(String orderId, String newStatus) async {
    await _col.doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    await updateStatus(orderId, 'cancelled');
  }

  /// Place a new order
  Future<String> placeOrder(OrderModel order) async {
    final doc = await _col.add(order.toMap());
    return doc.id;
  }

  /// Get order counts by status
  Future<Map<String, int>> getOrderCounts() async {
    final snap = await _col.get();
    final counts = <String, int>{
      'pending': 0,
      'payment_verified': 0,
      'ready_for_delivery': 0,
      'delivered': 0,
      'cancelled': 0,
    };
    for (final doc in snap.docs) {
      final status = doc.data()['status'] as String? ?? 'pending';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Get total revenue from delivered orders
  Future<double> getTotalRevenue() async {
    final snap =
        await _col.where('status', isEqualTo: 'delivered').get();
    double total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['total'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }
}
