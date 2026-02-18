import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleService {
  UserRoleService._();
  static final UserRoleService instance = UserRoleService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the role of a user. Returns 'customer' if not found.
  Future<String> getRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return 'customer';
    return (doc.data()?['role'] as String?) ?? 'customer';
  }

  /// Create user document if it doesn't exist.
  /// Called after sign-up or first login.
  Future<void> ensureUserDoc({
    required String uid,
    required String email,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': email,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Set a user's role (admin use only)
  Future<void> setRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  /// Get stream of all customers
  Stream<QuerySnapshot> getCustomers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .snapshots();
  }

  /// Get all users
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }
}
