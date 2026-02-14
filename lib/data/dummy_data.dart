import 'package:grocery_app/core/theme/app_colors.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';

class DummyData {
  DummyData._();

  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'fruits',
      name: 'Fresh Fruits\n& Vegetable',
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300',
      bgColor: AppColors.fruitsBg,
      borderColor: AppColors.fruitsBorder,
    ),
    CategoryModel(
      id: 'oil',
      name: 'Cooking Oil\n& Ghee',
      imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=300',
      bgColor: AppColors.oilBg,
      borderColor: AppColors.oilBorder,
    ),
    CategoryModel(
      id: 'meat',
      name: 'Meat & Fish',
      imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300',
      bgColor: AppColors.meatBg,
      borderColor: AppColors.meatBorder,
    ),
    CategoryModel(
      id: 'bakery',
      name: 'Bakery & Snacks',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300',
      bgColor: AppColors.bakeryBg,
      borderColor: AppColors.bakeryBorder,
    ),
    CategoryModel(
      id: 'dairy',
      name: 'Dairy & Eggs',
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=300',
      bgColor: AppColors.dairyBg,
      borderColor: AppColors.dairyBorder,
    ),
    CategoryModel(
      id: 'beverages',
      name: 'Beverages',
      imageUrl: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=300',
      bgColor: AppColors.beveragesBg,
      borderColor: AppColors.beveragesBorder,
    ),
  ];

  static const List<ProductModel> exclusiveOffers = [
    ProductModel(
      id: 'p1',
      name: 'Organic Bananas',
      description: 'Organic Bananas are a great source of potassium and dietary fiber. They are naturally sweet and make for a perfect snack or addition to smoothies.',
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300',
      price: 4.99,
      unit: '7pcs, Priceg',
      categoryId: 'fruits',
    ),
    ProductModel(
      id: 'p2',
      name: 'Red Apple',
      description: 'Apples Are Nutritious. Apples May Be Good For Weight Loss. Apples May Be Good For Your Heart. As Part Of A Healthful And Varied Diet.',
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=300',
      price: 4.99,
      unit: '1kg, Priceg',
      categoryId: 'fruits',
    ),
    ProductModel(
      id: 'p3',
      name: 'Ginger',
      description: 'Fresh ginger root, perfect for cooking and tea. Known for its anti-inflammatory properties.',
      imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=300',
      price: 2.99,
      unit: '250gm, Price',
      categoryId: 'fruits',
    ),
  ];

  static const List<ProductModel> bestSelling = [
    ProductModel(
      id: 'p4',
      name: 'Bell Pepper Red',
      description: 'Red bell peppers are a great source of vitamin C. They are sweet and crunchy, perfect for salads and stir-fries.',
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=300',
      price: 4.99,
      unit: '1kg, Price',
      categoryId: 'fruits',
    ),
    ProductModel(
      id: 'p5',
      name: 'Ginger',
      description: 'Fresh ginger root with a strong flavor. Great for Asian cooking, teas, and remedies.',
      imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=300',
      price: 2.99,
      unit: '250gm, Price',
      categoryId: 'fruits',
    ),
    ProductModel(
      id: 'p6',
      name: 'Organic Bananas',
      description: 'Organic fair-trade bananas. Rich in potassium and perfect as a quick healthy snack.',
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300',
      price: 3.00,
      unit: '12kg, Price',
      categoryId: 'fruits',
    ),
  ];

  static const List<ProductModel> beverages = [
    ProductModel(
      id: 'b1',
      name: 'Diet Coke',
      description: 'Refreshing diet cola with zero calories.',
      imageUrl: 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=300',
      price: 1.99,
      unit: '355ml, Price',
      categoryId: 'beverages',
    ),
    ProductModel(
      id: 'b2',
      name: 'Sprite Can',
      description: 'Crisp lemon-lime flavored soda.',
      imageUrl: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=300',
      price: 1.50,
      unit: '325ml, Price',
      categoryId: 'beverages',
    ),
    ProductModel(
      id: 'b3',
      name: 'Apple & Grape Juice',
      description: 'Natural fruit juice blend.',
      imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=300',
      price: 15.99,
      unit: '2L, Price',
      categoryId: 'beverages',
    ),
    ProductModel(
      id: 'b4',
      name: 'Orange Juice',
      description: 'Freshly squeezed orange juice.',
      imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=300',
      price: 15.99,
      unit: '2L, Price',
      categoryId: 'beverages',
    ),
    ProductModel(
      id: 'b5',
      name: 'Coca Cola Can',
      description: 'Classic cola taste.',
      imageUrl: 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=300',
      price: 4.99,
      unit: '325ml, Price',
      categoryId: 'beverages',
    ),
    ProductModel(
      id: 'b6',
      name: 'Pepsi Can',
      description: 'Bold cola flavor.',
      imageUrl: 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=300',
      price: 4.99,
      unit: '330ml, Price',
      categoryId: 'beverages',
    ),
  ];

  static const List<ProductModel> eggs = [
    ProductModel(
      id: 'e1',
      name: 'Egg Chicken Red',
      description: 'Farm fresh red eggs.',
      imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=300',
      price: 1.99,
      unit: '4pcs, Price',
      categoryId: 'dairy',
    ),
    ProductModel(
      id: 'e2',
      name: 'Egg Chicken White',
      description: 'Farm fresh white eggs.',
      imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=300',
      price: 1.50,
      unit: '180g, Price',
      categoryId: 'dairy',
    ),
    ProductModel(
      id: 'e3',
      name: 'Egg Pasta',
      description: 'Premium egg pasta.',
      imageUrl: 'https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=300',
      price: 15.99,
      unit: '30gm, Price',
      categoryId: 'dairy',
    ),
    ProductModel(
      id: 'e4',
      name: 'Egg Noodles',
      description: 'Classic egg noodles.',
      imageUrl: 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=300',
      price: 15.99,
      unit: '2L, Price',
      categoryId: 'dairy',
    ),
  ];

  static List<ProductModel> get allProducts =>
      [...exclusiveOffers, ...bestSelling, ...beverages, ...eggs];

  static List<ProductModel> getProductsByCategory(String categoryId) {
    return allProducts.where((p) => p.categoryId == categoryId).toList();
  }
}
