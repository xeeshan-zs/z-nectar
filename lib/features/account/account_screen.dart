import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/features/auth/auth_service.dart';
import 'package:grocery_app/features/auth/splash_screen.dart';
import 'package:grocery_app/features/location/location_selection_screen.dart';
import 'package:grocery_app/features/order/order_history_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'my_details_screen.dart';
import 'payment_methods_screen.dart';
import 'promo_code_screen.dart';
import 'notifications_settings_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final displayName = user?.displayName ?? 'Grocery User';
    final contactInfo = user?.email ?? user?.phoneNumber ?? 'Not available';

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
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user!.photoURL!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: AppColors.primaryGreen,
                                  size: 35),
                            ),
                          )
                        : const Icon(Icons.person,
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
                            Flexible(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showEditNameDialog(context),
                              child: const Icon(Icons.edit_outlined,
                                  color: AppColors.primaryGreen, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contactInfo,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
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
            _buildOrdersMenuItem(context),
            _buildMenuItem(context, Icons.badge_outlined, 'My Details', const MyDetailsScreen()),
            _buildLocationMenuItem(context), // Special case for location
            _buildMenuItem(
                context, Icons.payment_outlined, 'Payment Methods', const PaymentMethodsScreen()),
            _buildMenuItem(
                context, Icons.local_offer_outlined, 'Promo Code', const PromoCodeScreen()),
            _buildMenuItem(
                context, Icons.notifications_outlined, 'Notifications', const NotificationsSettingsScreen()),
            _buildMenuItem(context, Icons.help_outline, 'Help', const HelpScreen()),
            _buildMenuItem(context, Icons.info_outline, 'About', const AboutScreen()),
            const SizedBox(height: 30),
            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
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
                    side:
                        const BorderSide(color: AppColors.lightGrey, width: 1),
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

  Widget _buildLocationMenuItem(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LocationSelectionScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding, vertical: 16),
            child: Row(
              children: [
                 Icon(Icons.location_on_outlined, color: AppColors.darkText, size: 24),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Delivery Address',
                    style: TextStyle(
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
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildOrdersMenuItem(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OrderHistoryScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.darkText, size: 24),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Orders',
                    style: TextStyle(
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
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget targetScreen) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => targetScreen,
              ),
            );
          },
          child: Padding(
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
        ),
        const Divider(),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: AuthService.instance.currentUser?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Name',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(
              color: AppColors.lightGreyText,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.lightGrey,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      await AuthService.instance.currentUser
                          ?.updateDisplayName(name);
                      // Reload to pick up the change
                      await AuthService.instance.currentUser?.reload();
                    }
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    // Force a rebuild of the parent to show the new name
                    if (context.mounted) {
                      (context as Element).markNeedsBuild();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.greyText,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService.instance.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (_) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF35B5B), // Soft Red
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
