import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritesService {
  FavouritesService._();
  static final FavouritesService instance = FavouritesService._();

  final _firestore = FirebaseFirestore.instance;

  /// Get the favourites sub-collection for a user
  CollectionReference _favCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('favourites');

  /// Stream all favourite product IDs
  Stream<Set<String>> getFavouriteIds(String userId) {
    return _favCol(userId).snapshots().map((snap) {
      return snap.docs.map((d) => d.id).toSet();
    });
  }

  /// Check if a product is favourited
  Future<bool> isFavourite(String userId, String productId) async {
    final doc = await _favCol(userId).doc(productId).get();
    return doc.exists;
  }

  /// Toggle favourite status — returns new state (true = now favourited)
  Future<bool> toggleFavourite(String userId, String productId) async {
    final docRef = _favCol(userId).doc(productId);
    final snap = await docRef.get();

    if (snap.exists) {
      await docRef.delete();
      return false;
    } else {
      await docRef.set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  /// Remove a favourite
  Future<void> removeFavourite(String userId, String productId) async {
    await _favCol(userId).doc(productId).delete();
  }
}
