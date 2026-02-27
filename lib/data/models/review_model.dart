import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String userId;
  final String userEmail;
  final double rating; // 1–5
  final String comment;
  final Timestamp? createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'userId': userId,
        'userEmail': userEmail,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
