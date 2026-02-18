import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/location_model.dart';
import 'package:grocery_app/features/auth/auth_service.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => AuthService.instance.currentUser?.uid;

  CollectionReference get _locationsRef {
    if (_uid == null) {
      throw Exception('User must be logged in to manage locations');
    }
    return _firestore.collection('users').doc(_uid).collection('locations');
  }

  /// Get stream of user locations
  Stream<List<LocationModel>> getLocations() {
    if (_uid == null) return const Stream.empty();
    return _locationsRef.orderBy('isSelected', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return LocationModel.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList();
      },
    );
  }

  /// Get the currently selected location
  Stream<LocationModel?> getCurrentLocation() {
    if (_uid == null) return const Stream.empty();
    return _locationsRef
        .where('isSelected', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return LocationModel.fromMap(
        snapshot.docs.first.id,
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    });
  }

  /// Add a new location
  Future<void> addLocation(String address) async {
    final snapshot = await _locationsRef.get();
    final isFirst = snapshot.docs.isEmpty;

    await _locationsRef.add({
      'address': address,
      'isSelected': isFirst, // Auto-select if first address
    });
  }

  /// Select a location as current
  Future<void> selectLocation(String id) async {
    // 1. Get all selected docs (there should ideally be only one)
    final selectedDocs =
        await _locationsRef.where('isSelected', isEqualTo: true).get();

    final batch = _firestore.batch();

    // 2. Deselect currently selected
    for (var doc in selectedDocs.docs) {
      if (doc.id != id) {
        batch.update(doc.reference, {'isSelected': false});
      }
    }

    // 3. Select new one
    batch.update(_locationsRef.doc(id), {'isSelected': true});

    await batch.commit();
  }

  /// Delete a location
  Future<void> deleteLocation(String id) async {
    await _locationsRef.doc(id).delete();
    
    // If we deleted the selected one, select another one if available
    final selected = await _locationsRef.where('isSelected', isEqualTo: true).get();
    if (selected.docs.isEmpty) {
        final any = await _locationsRef.limit(1).get();
        if (any.docs.isNotEmpty) {
            await selectLocation(any.docs.first.id);
        }
    }
  }
}
