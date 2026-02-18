import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  CategoryService._();
  static final CategoryService instance = CategoryService._();

  final _col = FirebaseFirestore.instance.collection('categories');

  /// Stream all categories
  Stream<QuerySnapshot> getCategories() {
    return _col.orderBy('name').snapshots();
  }

  /// Add a category
  Future<void> addCategory({
    required String name,
    required String imageUrl,
    String bgColor = '#F3F5E9',
    String borderColor = '#E2E7D5',
  }) async {
    await _col.add({
      'name': name,
      'imageUrl': imageUrl,
      'bgColor': bgColor,
      'borderColor': borderColor,
    });
  }

  /// Update a category
  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  /// Delete a category
  Future<void> deleteCategory(String id) async {
    await _col.doc(id).delete();
  }
}
