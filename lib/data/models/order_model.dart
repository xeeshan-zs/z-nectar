import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int qty;
  final double price;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      qty: (map['qty'] as num?)?.toInt() ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'qty': qty,
      'price': price,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final double total;
  final String status; // pending, payment_verified, ready_for_delivery, delivered, cancelled
  final String paymentMethod;
  final String address;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.total,
    this.status = 'pending',
    this.paymentMethod = 'cod',
    this.address = '',
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      items: (map['items'] as List<dynamic>?)?.map((e) {
        if (e is Map) {
          return OrderItem.fromMap(Map<String, dynamic>.from(e));
        }
        return const OrderItem(productId: '', name: 'Unknown', qty: 1, price: 0);
      }).toList() ?? [],
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'pending',
      paymentMethod: map['paymentMethod'] as String? ?? 'cod',
      address: map['address'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp 
          ? map['createdAt'] as Timestamp 
          : (map['createdAt'] != null && map['createdAt'].toString().isNotEmpty)
              ? Timestamp.fromDate((map['createdAt'] as dynamic).toDate())
              : null,
      updatedAt: map['updatedAt'] is Timestamp 
          ? map['updatedAt'] as Timestamp 
          : (map['updatedAt'] != null && map['updatedAt'].toString().isNotEmpty)
              ? Timestamp.fromDate((map['updatedAt'] as dynamic).toDate())
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'address': address,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'payment_verified':
        return 'Payment Verified';
      case 'ready_for_delivery':
        return 'Ready for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String? get nextStatus {
    switch (status) {
      case 'pending':
        return 'payment_verified';
      case 'payment_verified':
        return 'ready_for_delivery';
      case 'ready_for_delivery':
        return 'delivered';
      default:
        return null;
    }
  }
}
