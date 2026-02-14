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
  });
}
