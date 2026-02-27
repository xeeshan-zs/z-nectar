class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String unit;
  final String nutritionWeight;
  final double rating;
  final String categoryId;
  final bool inStock;
  final bool isExclusive;
  final bool isCarousel;
  final bool isFeatured;
  final int salesCount;
  final int stockCount;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.unit,
    this.nutritionWeight = '100gr',
    this.rating = 5.0,
    required this.categoryId,
    this.inStock = true,
    this.isExclusive = false,
    this.isCarousel = false,
    this.isFeatured = false,
    this.salesCount = 0,
    this.stockCount = 999,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      nutritionWeight: map['nutritionWeight'] as String? ?? '100gr',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      categoryId: map['categoryId'] as String? ?? '',
      inStock: map['inStock'] == null ? true : map['inStock'] as bool,
      isExclusive: map['isExclusive'] == null ? false : map['isExclusive'] as bool,
      isCarousel: map['isCarousel'] == null ? false : map['isCarousel'] as bool,
      isFeatured: map['isFeatured'] == null ? false : map['isFeatured'] as bool,
      salesCount: (map['salesCount'] as num?)?.toInt() ?? 0,
      stockCount: (map['stockCount'] as num?)?.toInt() ?? 999,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'unit': unit,
      'nutritionWeight': nutritionWeight,
      'rating': rating,
      'categoryId': categoryId,
      'inStock': inStock,
      'isExclusive': isExclusive,
      'isCarousel': isCarousel,
      'isFeatured': isFeatured,
      'salesCount': salesCount,
      'stockCount': stockCount,
    };
  }
}
