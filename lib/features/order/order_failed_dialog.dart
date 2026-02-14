import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/widgets/green_button.dart';

class OrderFailedDialog extends StatelessWidget {
  const OrderFailedDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const OrderFailedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: AppColors.darkText, size: 24),
              ),
            ),
            const SizedBox(height: 10),
            // Bag illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 100,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 25),
            // Title
            const Text(
              'Oops! Order Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            const Text(
              'Something went terribly wrong.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 25),
            // Try Again Button
            GreenButton(
              text: 'Please Try Again',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 15),
            // Back to home
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Back to home',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
