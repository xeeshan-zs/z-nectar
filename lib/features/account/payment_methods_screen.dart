import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Dummy payment methods list
  final List<Map<String, dynamic>> _methods = [
    {
      'id': '1',
      'brand': 'visa',
      'last4': '4242',
      'name': 'Personal Card',
      'isDefault': true,
    },
    {
      'id': '2',
      'brand': 'mastercard',
      'last4': '8888',
      'name': 'Business Card',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: _methods.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              itemCount: _methods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final method = _methods[index];
                return _buildPaymentCard(method);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adding payment method (Coming soon)'),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add Card', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_outlined,
              size: 80, color: AppColors.greyText.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No Payment Methods',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText)),
          const SizedBox(height: 8),
          const Text('Add a credit or debit card for faster checkout',
              style: TextStyle(fontSize: 14, color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> method) {
    IconData brandIcon;
    Color brandColor;

    if (method['brand'] == 'visa') {
      brandIcon = Icons.credit_card;
      brandColor = Colors.blue.shade700;
    } else {
      brandIcon = Icons.payment;
      brandColor = Colors.orange.shade800;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method['isDefault'] ? AppColors.primaryGreen : Colors.transparent,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(brandIcon, color: brandColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '**** **** **** ${method['last4']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.greyText,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (method['isDefault'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
