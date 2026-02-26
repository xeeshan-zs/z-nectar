import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/promo_model.dart';
import 'package:flutter/foundation.dart';

class PromoService {
  PromoService._();
  static final PromoService instance = PromoService._();

  final _db = FirebaseFirestore.instance;

  // Ensure an account has the 3 welcome promos and fetch all available promos
  Future<List<PromoModel>> getAvailablePromos(String userId) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    
    // 1. Generate welcome promos if missing
    if (!doc.exists || doc.data()?['welcome_promos_generated'] != true) {
      final batch = _db.batch();
      batch.set(userRef, {'welcome_promos_generated': true}, SetOptions(merge: true));
      
      batch.set(userRef.collection('my_promos').doc('welcome30'), {
        'code': 'WELCOME30',
        'title': '30% Off First Order',
        'description': 'Enjoy 30% off your very first order.',
        'discountPercent': 30,
        'used': false,
      });
      batch.set(userRef.collection('my_promos').doc('save5'), {
        'code': 'SAVE5',
        'title': '5% Off Groceries',
        'description': 'Take 5% off this order.',
        'discountPercent': 5,
        'used': false,
      });
      batch.set(userRef.collection('my_promos').doc('bonus5'), {
        'code': 'BONUS5',
        'title': '5% Off Groceries',
        'description': 'Take 5% off this order.',
        'discountPercent': 5,
        'used': false,
      });
      await batch.commit();
    }
    
    // 2. Fetch unused personal promos
    final myPromosSnap = await userRef.collection('my_promos').where('used', isEqualTo: false).get();
    final myPromos = myPromosSnap.docs.map((d) => PromoModel.fromMap(d.id, d.data(), isGlobal: false)).toList();
    
    // 3. Fetch global promos mapped to usage (to hide used ones)
    final usedGlobals = List<String>.from(doc.data()?['used_global_promos'] ?? []);
    final globalSnap = await _db.collection('promos').get();
    final globalPromos = globalSnap.docs
        .map((d) => PromoModel.fromMap(d.id, d.data(), isGlobal: true))
        .where((p) => !usedGlobals.contains(p.id))
        .toList();
        
    return [...myPromos, ...globalPromos];
  }

  // Validate a typed promo code string against global and personal promos
  Future<PromoModel?> validateCode(String userId, String code) async {
    code = code.toUpperCase().trim();
    final allPromos = await getAvailablePromos(userId);
    try {
      return allPromos.firstWhere((p) => p.code == code);
    } catch (_) {
      return null;
    }
  }

  // Mark a promo as used after a successful order
  Future<void> markPromoUsed(String userId, PromoModel promo) async {
    final userRef = _db.collection('users').doc(userId);
    if (promo.isGlobal) {
      await userRef.set({
        'used_global_promos': FieldValue.arrayUnion([promo.id])
      }, SetOptions(merge: true));
    } else {
      await userRef.collection('my_promos').doc(promo.id).update({'used': true});
    }
  }

  // Admin Methods
  Stream<List<PromoModel>> getGlobalPromosStream() {
    return _db.collection('promos').snapshots().map((snap) => 
        snap.docs.map((d) => PromoModel.fromMap(d.id, d.data(), isGlobal: true)).toList());
  }

  Future<void> addGlobalPromo(PromoModel promo) async {
    await _db.collection('promos').add(promo.toMap());
  }

  Future<void> deleteGlobalPromo(String id) async {
    await _db.collection('promos').doc(id).delete();
  }
}
