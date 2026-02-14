import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/features/order/order_success_screen.dart';

class CheckoutBottomSheet extends StatelessWidget {
  final double totalCost;

  const CheckoutBottomSheet({super.key, required this.totalCost});

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
            // Delivery
            _buildCheckoutRow(
              'Delivery',
              'Select Method',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.darkText, size: 22),
            ),
            const Divider(),
            // Payment
            _buildCheckoutRow(
              'Payment',
              '',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Icon(Icons.credit_card,
                          color: AppColors.white, size: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: AppColors.darkText, size: 22),
                ],
              ),
            ),
            const Divider(),
            // Promo Code
            _buildCheckoutRow(
              'Promo Code',
              'Pick discount',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.darkText, size: 22),
            ),
            const Divider(),
            // Total Cost
            _buildCheckoutRow(
              'Total Cost',
              '\$${totalCost.toStringAsFixed(2)}',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.darkText, size: 22),
            ),
            const Divider(),
            const SizedBox(height: 15),
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
            GreenButton(
              text: 'Place Order',
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderSuccessScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutRow(String label, String value, {Widget? trailing}) {
    return Padding(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              if (trailing != null) ...[
                const SizedBox(width: 5),
                trailing,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
