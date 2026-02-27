import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/review_model.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final _col = FirebaseFirestore.instance.collection('reviews');

  /// Submit a review (one per user per product)
  Future<void> submitReview(ReviewModel review) async {
    // Use productId_userId as doc ID to enforce one-review-per-product-per-user
    final docId = '${review.productId}_${review.userId}';
    await _col.doc(docId).set(review.toMap());
  }

  /// One-shot fetch of every review (admin use)
  Future<List<ReviewModel>> getAllReviews() async {
    final snap = await _col.get();
    final list =
        snap.docs.map((d) => ReviewModel.fromMap(d.id, d.data())).toList();
    list.sort((a, b) {
      final aMs = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bMs = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bMs.compareTo(aMs);
    });
    return list;
  }

  /// Stream all reviews for a product
  Stream<List<ReviewModel>> getReviewsForProduct(String productId) {
    return _col
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ReviewModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final aMs = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bMs = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bMs.compareTo(aMs);
      });
      return list;
    });
  }

  /// One-shot fetch of reviews for a product
  Future<List<ReviewModel>> getReviewsForProductOnce(String productId) async {
    final snap =
        await _col.where('productId', isEqualTo: productId).get();
    final list = snap.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) {
      final aMs = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bMs = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bMs.compareTo(aMs);
    });
    return list;
  }

  /// Check whether the current user has already reviewed a product
  Future<bool> hasUserReviewed(String productId, String userId) async {
    final docId = '${productId}_$userId';
    final doc = await _col.doc(docId).get();
    return doc.exists;
  }

  /// Get existing review by user for a product (nullable)
  Future<ReviewModel?> getUserReview(String productId, String userId) async {
    final docId = '${productId}_$userId';
    final doc = await _col.doc(docId).get();
    if (!doc.exists) return null;
    return ReviewModel.fromMap(doc.id, doc.data()!);
  }
}
