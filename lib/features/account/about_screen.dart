import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: CachedNetworkImage(
                  imageUrl: 'https://img.icons8.com/emoji/96/carrot-emoji.png',
                  width: 80,
                  height: 80,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.eco,
                    color: AppColors.primaryGreen,
                    size: 80,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nectar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),

            _buildListTile('Terms of Service', () {}),
            const Divider(),
            _buildListTile('Privacy Policy', () {}),
            const Divider(),
            _buildListTile('Open Source Licenses', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.darkText),
    );
  }
}
