import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/features/cart/checkout_bottom_sheet.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text('Please log in to view your cart',
            style: TextStyle(fontSize: 16, color: AppColors.greyText)),
      );
    }

    return SafeArea(
      child: StreamBuilder<List<CartItem>>(
        stream: CartService.instance.getCartItems(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.greyText.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText)),
                  const SizedBox(height: 8),
                  const Text('Add items from the shop to get started',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.greyText)),
                ],
              ),
            );
          }

          final totalCost =
              items.fold<double>(0, (sum, item) => sum + item.totalPrice);

          return Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'My Cart',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    return _buildCartItemTile(context, items[index], user.uid);
                  },
                ),
              ),
              // Checkout Button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.horizontalPadding,
                    10,
                    AppConstants.horizontalPadding,
                    20),
                child: GreenButton(
                  text: 'Go to Checkout',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF489E67),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '\$${totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CheckoutBottomSheet(
                        totalCost: totalCost,
                        cartItems: items,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, CartItem item, String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding, vertical: 10),
      child: Row(
        children: [
          // Product Image
          CachedNetworkImage(
            imageUrl: item.imageUrl,
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
                  color: AppColors.greyText, size: 28),
            ),
          ),
          const SizedBox(width: 20),
          // Details & Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        CartService.instance.removeFromCart(userId, item.id);
                      },
                      child: const Icon(Icons.close,
                          color: AppColors.greyText, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.unit,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Row(
                      children: [
                        _buildQtyButton(
                          Icons.remove,
                          () {
                            CartService.instance
                                .updateQty(userId, item.id, item.qty - 1);
                          },
                        ),
                        Container(
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.lightGrey, width: 1),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 6),
                          child: Text(
                            '${item.qty}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText),
                          ),
                        ),
                        _buildQtyButton(
                          Icons.add,
                          () {
                            CartService.instance
                                .updateQty(userId, item.id, item.qty + 1);
                          },
                        ),
                      ],
                    ),
                    // Price
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText),
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

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey, width: 1),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 22),
      ),
    );
  }
}
