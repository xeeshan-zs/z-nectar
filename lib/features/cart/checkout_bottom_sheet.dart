import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/core/services/order_service.dart';
import 'package:grocery_app/data/models/order_model.dart';
import 'package:grocery_app/features/order/order_success_screen.dart';
import 'package:grocery_app/features/order/order_failed_dialog.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final double totalCost;
  final List<CartItem> cartItems;

  const CheckoutBottomSheet({
    super.key,
    required this.totalCost,
    required this.cartItems,
  });

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  String _deliveryMethod = 'Delivery';
  String _paymentMethod = 'cod';
  bool _isPlacingOrder = false;

  final List<String> _deliveryOptions = ['Delivery', 'Pickup'];
  final Map<String, String> _paymentOptions = {
    'cod': 'Cash on Delivery',
    'card': 'Credit / Debit Card',
    'jazzcash': 'JazzCash',
    'easypaisa': 'EasyPaisa',
  };

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isPlacingOrder = true);

    try {
      final order = OrderModel(
        id: '',
        userId: user.uid,
        userEmail: user.email ?? '',
        items: widget.cartItems
            .map((c) => OrderItem(
                  productId: c.productId,
                  name: c.name,
                  qty: c.qty,
                  price: c.price,
                ))
            .toList(),
        total: widget.totalCost,
        paymentMethod: _paymentMethod,
        address: _deliveryMethod == 'Pickup' ? 'Store Pickup' : '',
      );

      await OrderService.instance.placeOrder(order);
      await CartService.instance.clearCart(user.uid);

      if (!mounted) return;
      Navigator.pop(context); // close bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close bottom sheet
      showDialog(
        context: context,
        builder: (_) => const OrderFailedDialog(),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppConstants.horizontalPadding, 30, AppConstants.horizontalPadding, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: AppColors.darkText, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),

            // Delivery method
            _buildCheckoutRow(
              'Delivery',
              _deliveryMethod,
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.darkText, size: 22),
              onTap: () => _showDeliveryPicker(),
            ),
            const Divider(),

            // Payment method
            _buildCheckoutRow(
              'Payment',
              _paymentOptions[_paymentMethod] ?? 'Cash on Delivery',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _paymentMethod == 'cod'
                        ? Icons.money
                        : _paymentMethod == 'card'
                            ? Icons.credit_card
                            : Icons.phone_android,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: AppColors.darkText, size: 22),
                ],
              ),
              onTap: () => _showPaymentPicker(),
            ),
            const Divider(),

            // Total Cost
            _buildCheckoutRow(
              'Total Cost',
              '\$${widget.totalCost.toStringAsFixed(2)}',
            ),
            const Divider(),

            // Items summary
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${widget.cartItems.length} item(s) in cart',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.greyText,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Terms
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyText,
                ),
                children: [
                  const TextSpan(text: 'By placing an order you agree to our\n'),
                  TextSpan(
                    text: 'Terms',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const TextSpan(text: ' And '),
                  TextSpan(
                    text: 'Conditions',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Place Order Button
            _isPlacingOrder
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen))
                : GreenButton(
                    text: 'Place Order',
                    onPressed: _placeOrder,
                  ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _deliveryOptions.map((option) {
            return ListTile(
              leading: Icon(
                option == 'Delivery' ? Icons.delivery_dining : Icons.store,
                color: AppColors.primaryGreen,
              ),
              title: Text(option),
              trailing: _deliveryMethod == option
                  ? const Icon(Icons.check, color: AppColors.primaryGreen)
                  : null,
              onTap: () {
                setState(() => _deliveryMethod = option);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _paymentOptions.entries.map((entry) {
            return ListTile(
              leading: Icon(
                entry.key == 'cod'
                    ? Icons.money
                    : entry.key == 'card'
                        ? Icons.credit_card
                        : Icons.phone_android,
                color: AppColors.primaryGreen,
              ),
              title: Text(entry.value),
              trailing: _paymentMethod == entry.key
                  ? const Icon(Icons.check, color: AppColors.primaryGreen)
                  : null,
              onTap: () {
                setState(() => _paymentMethod = entry.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCheckoutRow(String label, String value,
      {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.greyText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value.isNotEmpty)
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (trailing != null) ...[
                    const SizedBox(width: 5),
                    trailing,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
