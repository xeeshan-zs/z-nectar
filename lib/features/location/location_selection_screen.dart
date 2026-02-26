import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/location_service.dart';
import 'package:grocery_app/data/models/location_model.dart';
import 'package:grocery_app/features/auth/auth_service.dart';
import 'package:grocery_app/features/location/manual_address_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final _service = LocationService.instance;
  late final Stream<QuerySnapshot> _locationsStream;

  @override
  void initState() {
    super.initState();
    _locationsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService.instance.currentUser!.uid)
        .collection('locations')
        .orderBy('isSelected', descending: true)
        .snapshots();
  }

  Future<void> _openManualAddress() async {
    final address = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ManualAddressScreen()),
    );
    if (address != null && address.isNotEmpty) {
      await _service.addLocation(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.instance.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to manage locations')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _locationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.location_off_outlined,
                      size: 64, color: AppColors.greyText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openManualAddress,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // Convert to models
          final locations = docs.map((doc) {
            return LocationModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: locations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    return _buildLocationCard(loc);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _openManualAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add New Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationCard(LocationModel loc) {
    return GestureDetector(
      onTap: () => _service.selectLocation(loc.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: loc.isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                loc.isSelected ? AppColors.primaryGreen : AppColors.borderGrey,
            width: loc.isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              loc.isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: loc.isSelected
                  ? AppColors.primaryGreen
                  : AppColors.greyText,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                loc.address,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      loc.isSelected ? AppColors.darkText : AppColors.greyText,
                ),
              ),
            ),
            if (!loc.isSelected)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _service.deleteLocation(loc.id),
              ),
          ],
        ),
      ),
    );
  }
}
