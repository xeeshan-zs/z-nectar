import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightGrey,
                      border: Border.all(color: AppColors.borderGrey, width: 1),
                    ),
                    child: const Icon(Icons.person,
                        color: AppColors.primaryGreen, size: 35),
                  ),
                  const SizedBox(width: 18),
                  // Name & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Afsar Hossen',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit_outlined,
                                color: AppColors.primaryGreen, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Imshuvo97@gmail.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            // Menu Items
            _buildMenuItem(Icons.shopping_bag_outlined, 'Orders'),
            _buildMenuItem(Icons.badge_outlined, 'My Details'),
            _buildMenuItem(Icons.location_on_outlined, 'Delivery Address'),
            _buildMenuItem(Icons.payment_outlined, 'Payment Methods'),
            _buildMenuItem(Icons.local_offer_outlined, 'Promo Code'),
            _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
            _buildMenuItem(Icons.help_outline, 'Help'),
            _buildMenuItem(Icons.info_outline, 'About'),
            const SizedBox(height: 30),
            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout,
                      color: AppColors.primaryGreen, size: 22),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.lightGrey, width: 1),
                    backgroundColor: AppColors.lightGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.darkText, size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.darkText, size: 24),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
