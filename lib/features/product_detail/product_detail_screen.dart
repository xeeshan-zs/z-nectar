import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/core/services/favourites_service.dart';
import 'package:grocery_app/data/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavourite = false;
  bool _isAddingToCart = false;
  bool _detailExpanded = true;
  final int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
  }

  Future<void> _checkFavourite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final fav = await FavouritesService.instance
        .isFavourite(user.uid, widget.product.id);
    if (mounted) setState(() => _isFavourite = fav);
  }

  Future<void> _toggleFavourite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final newState = await FavouritesService.instance
        .toggleFavourite(user.uid, widget.product.id);
    if (mounted) setState(() => _isFavourite = newState);
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isAddingToCart = true);
    await CartService.instance
        .addToCart(user.uid, widget.product, qty: _quantity);
    if (!mounted) return;
    setState(() => _isAddingToCart = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart!'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Area
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imageUrl,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 2,
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: 80,
                              color: AppColors.greyText,
                            ),
                          ),
                        ),
                      ),
                      // Back & Share buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: AppConstants.horizontalPadding,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios,
                              color: AppColors.darkText, size: 22),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: AppConstants.horizontalPadding,
                        child: const Icon(Icons.ios_share,
                            color: AppColors.darkText, size: 22),
                      ),
                    ],
                  ),
                  // Image Dots
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _imageIndex == index ? 10 : 7,
                        height: _imageIndex == index ? 10 : 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _imageIndex == index
                              ? AppColors.primaryGreen
                              : AppColors.borderGrey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Title & Favourite
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleFavourite,
                          child: Icon(
                            _isFavourite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: _isFavourite
                                ? Colors.red
                                : AppColors.greyText,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Unit
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    child: Text(
                      widget.product.unit,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Quantity Stepper & Price
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stepper
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                      color: AppColors.borderGrey, width: 1),
                                ),
                                child: const Icon(Icons.remove,
                                    color: AppColors.greyText, size: 22),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                    color: AppColors.borderGrey, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                      color: AppColors.borderGrey, width: 1),
                                ),
                                child: const Icon(Icons.add,
                                    color: AppColors.primaryGreen, size: 22),
                              ),
                            ),
                          ],
                        ),
                        // Price
                        Text(
                          '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  // Product Detail Expandable
                  _buildExpandableSection(
                    title: 'Product Detail',
                    isExpanded: _detailExpanded,
                    onTap: () =>
                        setState(() => _detailExpanded = !_detailExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.greyText,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  // Nutritions Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding,
                        vertical: 15),
                    child: Row(
                      children: [
                        const Text(
                          'Nutritions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.product.nutritionWeight,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.darkText, size: 24),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Review Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding,
                        vertical: 15),
                    child: Row(
                      children: [
                        const Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < widget.product.rating.floor()
                                  ? AppColors.starOrange
                                  : AppColors.borderGrey,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.darkText, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Add To Basket Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding, 0, AppConstants.horizontalPadding, 20),
            child: _isAddingToCart
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen))
                : GreenButton(
                    text: 'Add To Basket',
                    onPressed: _addToCart,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                    color: AppColors.darkText,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }
}
