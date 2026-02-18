class LocationModel {
  final String id;
  final String address;
  final bool isSelected;

  const LocationModel({
    required this.id,
    required this.address,
    this.isSelected = false,
  });

  factory LocationModel.fromMap(String id, Map<String, dynamic> map) {
    return LocationModel(
      id: id,
      address: map['address'] as String? ?? 'Unknown Address',
      isSelected: map['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'isSelected': isSelected,
    };
  }
}
