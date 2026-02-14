import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/data/dummy_data.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/features/cart/checkout_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<_CartItem> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = [
      _CartItem(product: DummyData.bestSelling[0], quantity: 1),
      _CartItem(product: DummyData.eggs[0], quantity: 1),
      _CartItem(product: DummyData.exclusiveOffers[0], quantity: 1),
      _CartItem(product: DummyData.exclusiveOffers[2], quantity: 1),
    ];
  }

  double get _totalPrice {
    return _cartItems.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          // Cart Items
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.greyText,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItemTile(item, index);
                    },
                  ),
          ),
          // Go to Checkout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding, 10, AppConstants.horizontalPadding, 20),
            child: GreenButton(
              text: 'Go to Checkout',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CheckoutBottomSheet(
                    totalCost: _totalPrice,
                  ),
                );
              },
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF489E67),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(_CartItem item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: item.product.imageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.contain,
            placeholder: (_, __) => Container(
              width: 70,
              height: 70,
              color: AppColors.lightGrey,
            ),
            errorWidget: (_, __, ___) => Container(
              width: 70,
              height: 70,
              color: AppColors.lightGrey,
              child: const Icon(Icons.image_not_supported_outlined,
                  color: AppColors.greyText),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _cartItems.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.close,
                          color: AppColors.greyText, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // Stepper & Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (item.quantity > 1) {
                              setState(() => item.quantity--);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                  color: AppColors.borderGrey, width: 1),
                            ),
                            child: const Icon(Icons.remove,
                                color: AppColors.greyText, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => item.quantity++),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                  color: AppColors.borderGrey, width: 1),
                            ),
                            child: const Icon(Icons.add,
                                color: AppColors.primaryGreen, size: 20),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem {
  final ProductModel product;
  int quantity;

  _CartItem({required this.product, this.quantity = 1});
}
