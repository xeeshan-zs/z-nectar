import 'package:cloud_firestore/cloud_firestore.dart';

class SupportService {
  SupportService._();
  static final SupportService instance = SupportService._();

  final _firestore = FirebaseFirestore.instance;

  Future<void> submitTicket({
    required String orderId,
    required String userId,
    required String message,
  }) async {
    await _firestore.collection('support_tickets').add({
      'orderId': orderId,
      'userId': userId,
      'message': message,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
