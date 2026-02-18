import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/banner_model.dart';

class BannerService {
  BannerService._();
  static final BannerService instance = BannerService._();

  final _col = FirebaseFirestore.instance.collection('banners');

  /// Stream all banners ordered by display order
  Stream<List<BannerModel>> getBanners() {
    return _col.orderBy('order').snapshots().map((snap) {
      return snap.docs
          .map((d) => BannerModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  /// Add a new banner
  Future<void> addBanner(BannerModel banner) async {
    await _col.add(banner.toMap());
  }

  /// Update an existing banner
  Future<void> updateBanner(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  /// Delete a banner
  Future<void> deleteBanner(String id) async {
    await _col.doc(id).delete();
  }

  /// Get banner count
  Future<int> getBannerCount() async {
    final snap = await _col.count().get();
    return snap.count ?? 0;
  }
}
