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
import 'package:grocery_app/core/services/location_service.dart';
import 'package:grocery_app/features/account/promo_code_screen.dart';
import 'package:grocery_app/features/location/location_selection_screen.dart';
import 'package:grocery_app/data/models/location_model.dart';
import 'package:grocery_app/data/models/promo_model.dart';
import 'package:grocery_app/core/services/promo_service.dart';
import 'package:grocery_app/core/services/product_service.dart';

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
  PromoModel? _appliedPromo;
  late Stream<LocationModel?> _locationStream;

  @override
  void initState() {
    super.initState();
    _locationStream = LocationService.instance.getCurrentLocation();
  }

  final List<String> _deliveryOptions = ['Delivery', 'Pickup'];
  final Map<String, String> _paymentOptions = {
    'cod': 'Cash on Delivery',
  };

  double get _subtotal {
    if (_appliedPromo != null) {
      return widget.totalCost * (1 - (_appliedPromo!.discountPercent / 100));
    }
    return widget.totalCost;
  }

  double get _deliveryFee {
    return _deliveryMethod == 'Delivery' ? 50.0 : 0.0;
  }

  double get _finalCost {
    return _subtotal + _deliveryFee;
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isPlacingOrder = true);

    try {
      // 1. Pre-Checkout Validation: Check if requested stock is still available
      final requestedQty = {
        for (final c in widget.cartItems) c.productId: c.qty
      };
      final insufficientStock =
          await ProductService.instance.checkStockAvailability(requestedQty);

      if (insufficientStock.isNotEmpty) {
        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        // Find names of out-of-stock items for a friendly message
        final oosNames = widget.cartItems
            .where((c) => insufficientStock.containsKey(c.productId))
            .map((c) => c.name)
            .join(', ');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Sorry, the following items are out of stock or have insufficient quantity: $oosNames'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return; // Halt checkout
      }

      // 2. Address & Minimum Validation: Ensure user has selected an address for Delivery
      String finalAddress = 'Store Pickup';
      if (_deliveryMethod == 'Delivery') {
        if (_subtotal < 200) {
          if (!mounted) return;
          setState(() => _isPlacingOrder = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Minimum order amount for delivery is Rs 200.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        final loc = await LocationService.instance.getCurrentLocation().first;
        if (loc == null || loc.address.isEmpty) {
          if (!mounted) return;
          setState(() => _isPlacingOrder = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a delivery address first.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return; // Halt checkout
        }
        finalAddress = loc.address;
      }

      // 3. Safe to proceed — create order
      final order = OrderModel(
        id: '',
        userId: user.uid,
        userEmail: user.email ?? '',
        userName: user.displayName ?? 'Customer',
        items: widget.cartItems
            .map((c) => OrderItem(
                  productId: c.productId,
                  name: c.name,
                  qty: c.qty,
                  price: c.price,
                ))
            .toList(),
        total: _finalCost,
        paymentMethod: _paymentMethod,
        address: finalAddress,
      );

      await OrderService.instance.placeOrder(order);

      // Decrement stock & increment sales for each ordered item
      final productIdToQty = {
        for (final c in widget.cartItems) c.productId: c.qty
      };
      await ProductService.instance.decrementStockCount(productIdToQty);
      await ProductService.instance
          .incrementSalesCount(widget.cartItems.map((e) => e.productId).toList());

      // Remove only the purchased items from the cart safely using a batch
      final productIds = widget.cartItems.map((e) => e.productId).toList();
      await CartService.instance.removeItemsFromCartBatch(user.uid, productIds);
      
      if (_appliedPromo != null) {
        await PromoService.instance.markPromoUsed(user.uid, _appliedPromo!);
      }

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

  Future<String> _getSelectedAddress() async {
    try {
      final loc = await LocationService.instance.getCurrentLocation().first;
      return loc?.address ?? 'No address selected';
    } catch (_) {
      return 'Address fetch error';
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
            
            // Address Row (Show only if Delivery)
            if (_deliveryMethod == 'Delivery') ...[
              StreamBuilder<LocationModel?>(
                stream: _locationStream,
                builder: (context, snapshot) {
                  final loc = snapshot.data;
                  final addressText = loc != null ? loc.address : 'Select Address';
                  return _buildCheckoutRow(
                    'Address',
                    addressText,
                    trailing: const Icon(Icons.chevron_right, color: AppColors.darkText, size: 22),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
                      );
                    },
                  );
                },
              ),
              const Divider(),
            ],

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

            // Promo Code
            _buildCheckoutRow(
              'Promo Code',
              _appliedPromo != null ? _appliedPromo!.code : 'Apply Promo',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.darkText, size: 22),
              onTap: () async {
                final promo = await Navigator.push<PromoModel?>(
                  context,
                  MaterialPageRoute(builder: (_) => const PromoCodeScreen(isSelectionMode: true)),
                );
                if (promo != null) {
                  setState(() => _appliedPromo = promo);
                }
              },
            ),
            const Divider(),

            // Total Cost calculations
            if (_appliedPromo != null)
              _buildCheckoutRow(
                'Discount',
                '-${_appliedPromo!.discountPercent.toInt()}%',
              ),
            if (_deliveryMethod == 'Delivery')
              _buildCheckoutRow(
                'Delivery Fee',
                'Rs ${_deliveryFee.toStringAsFixed(2)}',
              ),
            _buildCheckoutRow(
              'Total Cost',
              'Rs ${_finalCost.toStringAsFixed(2)}',
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
              leading: const Icon(Icons.money, color: AppColors.primaryGreen),
              title: Text(
                entry.value,
                style: const TextStyle(color: AppColors.darkText),
              ),
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
