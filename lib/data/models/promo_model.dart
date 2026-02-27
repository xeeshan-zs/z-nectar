import 'package:cloud_firestore/cloud_firestore.dart';

class PromoModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final bool used; // For user-specific promos
  final bool isGlobal; // To distinguish between global or user-specific
  final Timestamp? expiryDate;

  PromoModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.used = false,
    this.isGlobal = false,
    this.expiryDate,
  });

  factory PromoModel.fromMap(String id, Map<String, dynamic> map, {bool isGlobal = false}) {
    return PromoModel(
      id: id,
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercent: (map['discountPercent'] ?? 0).toDouble(),
      used: map['used'] ?? false,
      isGlobal: isGlobal,
      expiryDate: map['expiryDate'] is Timestamp 
          ? map['expiryDate'] as Timestamp 
          : (map['expiryDate'] != null && map['expiryDate'].toString().isNotEmpty)
              ? Timestamp.fromDate((map['expiryDate'] as dynamic).toDate())
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase(),
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'used': used,
      if (expiryDate != null) 'expiryDate': expiryDate,
    };
  }
}
