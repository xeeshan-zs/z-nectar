import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/features/cart/checkout_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // We keep track of items the user has EXPLICITLY unselected.
  // By default, assuming all new items are selected.
  final Set<String> _unselectedItemIds = {};
  late Stream<List<CartItem>> _cartStream;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _cartStream = CartService.instance.getCartItems(_currentUser!.uid);
    } else {
      _cartStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(
        child: Text('Please log in to view your cart',
            style: TextStyle(fontSize: 16, color: AppColors.greyText)),
      );
    }

    return SafeArea(
      child: StreamBuilder<List<CartItem>>(
        stream: _cartStream,
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

          // Selected = not explicitly unselected AND in stock
          final selectedItems = items
              .where((item) =>
                  !_unselectedItemIds.contains(item.id) && item.inStock)
              .toList();

          final totalCost = selectedItems.fold<double>(
              0, (sum, item) => sum + item.totalPrice);

          final isAllSelected = items.every((item) => !_unselectedItemIds.contains(item.id));
          final hasOutOfStockSelected = items.any(
              (item) => !_unselectedItemIds.contains(item.id) && !item.inStock);

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Cart',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText),
                    ),
                    if (items.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (isAllSelected) {
                              // Unselect all
                              _unselectedItemIds.addAll(items.map((e) => e.id));
                            } else {
                              // Select all
                              _unselectedItemIds.clear();
                            }
                          });
                        },
                        child: Text(
                          isAllSelected ? 'Deselect All' : 'Select All',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildCartItemTile(context, items[index], _currentUser!.uid);
                  },
                ),
              ),
              // Checkout Section
              Container(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.horizontalPadding,
                    15,
                    AppConstants.horizontalPadding,
                    25),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: selectedItems.isEmpty
                      ? GreenButton(
                          text: hasOutOfStockSelected
                              ? 'Remove out-of-stock items to checkout'
                              : 'Select items to checkout',
                          onPressed: () {},
                        )
                      : InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => CheckoutBottomSheet(
                                totalCost: totalCost,
                                cartItems: selectedItems,
                              ),
                            );
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Go to Checkout',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Rs ${totalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildCartItemTile(
      BuildContext context, CartItem item, String userId) {
    final isSelected = !_unselectedItemIds.contains(item.id);
    final isOos = !item.inStock;

    return Opacity(
      opacity: isOos ? 0.65 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox (disabled for OOS)
            GestureDetector(
              onTap: isOos
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          _unselectedItemIds.add(item.id);
                        } else {
                          _unselectedItemIds.remove(item.id);
                        }
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOos
                        ? Colors.red.withValues(alpha: 0.4)
                        : isSelected
                            ? AppColors.primaryGreen
                            : AppColors.greyText.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  color: isOos
                      ? Colors.transparent
                      : isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                ),
                child: isSelected && !isOos
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            // Product Image with OOS overlay
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    width: 70, height: 70, color: AppColors.lightGrey),
                  errorWidget: (_, __, ___) => Container(
                    width: 70, height: 70, color: AppColors.lightGrey,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.greyText, size: 28)),
                ),
                if (isOos)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.red.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: const Text(
                        'Out of Stock',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
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
                      // Quantity Controls (disabled for OOS)
                      IgnorePointer(
                        ignoring: isOos,
                        child: Row(
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
                      ),
                      // Price
                      Text(
                        'Rs ${item.totalPrice.toStringAsFixed(2)}',
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
