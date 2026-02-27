import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _openPage(BuildContext context, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _TextPage(title: title, content: content),
      ),
    );
  }

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
                decoration: const BoxDecoration(
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

            _buildListTile('Terms of Service', () {
              _openPage(context, 'Terms of Service', _kTerms);
            }),
            const Divider(),
            _buildListTile('Privacy Policy', () {
              _openPage(context, 'Privacy Policy', _kPrivacy);
            }),
            const Divider(),
            _buildListTile('Open Source Licenses', () {
              showLicensePage(
                context: context,
                applicationName: 'Nectar',
                applicationVersion: '1.0.0',
                applicationIcon: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('🥕', style: TextStyle(fontSize: 40)),
                ),
              );
            }),
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

// ── Simple text detail page ───────────────────────────────────────────────────

class _TextPage extends StatelessWidget {
  final String title;
  final String content;

  const _TextPage({required this.title, required this.content});

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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.greyText,
            height: 1.7,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

const _kTerms = '''
Last updated: February 2026

Welcome to Nectar. By using our app, you agree to the following terms.

1. Use of Service
Nectar provides an online grocery shopping platform. You must be at least 18 years old to use this service. You agree to provide accurate information and to use the app only for lawful purposes.

2. Orders & Payments
All orders are subject to product availability. Prices are displayed in PKR and may change without notice. Payment is processed securely at checkout.

3. Delivery
We aim to deliver orders within one hour in supported areas. Delivery times may vary based on location and demand. Nectar is not liable for delays caused by factors beyond our control.

4. Returns & Refunds
If you receive a damaged or incorrect item, contact our support within 24 hours of delivery. Eligible refunds will be processed within 5-7 business days.

5. Account
You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately of any unauthorized use.

6. Changes to Terms
We reserve the right to update these terms at any time. Continued use of the app after changes constitutes your acceptance of the new terms.

7. Contact
For any questions, reach us at support@nectarapp.com.
''';

const _kPrivacy = '''
Last updated: February 2026

Nectar is committed to protecting your privacy. This policy explains how we collect, use, and protect your information.

1. Information We Collect
• Account information: name, email address, and profile photo.
• Order information: delivery address, cart items, and payment method (we do not store card numbers).
• Usage data: app interactions to improve our service.

2. How We Use Your Information
• To process and deliver your orders.
• To send order confirmations and delivery updates.
• To improve our app and personalize your experience.
• To comply with legal obligations.

3. Sharing Your Information
We do not sell your personal data. We may share it with:
• Delivery partners to fulfill orders.
• Payment processors to handle transactions.
• Firebase (Google) for authentication and database services.

4. Data Security
We use industry-standard encryption and Firebase security rules to protect your data.

5. Your Rights
You may request access to, correction of, or deletion of your personal data at any time by contacting support@nectarapp.com.

6. Cookies & Analytics
We use Firebase Analytics to understand app usage. You can opt out in your device settings.

7. Changes to This Policy
We may update this policy periodically. We will notify you of significant changes via the app.

8. Contact
Questions? Email us at support@nectarapp.com.
''';
