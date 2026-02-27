import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/features/order/order_history_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Checkmark Circle with decorations
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative shapes
                    ..._buildConfettiDots(),
                    // Outer ring
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    // Inner circle with checkmark
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Title
              const Text(
                'Your Order has been\naccepted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 15),
              // Subtitle
              const Text(
                'Your items has been placed and is on\nit\'s way to being processed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.greyText,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Track Order Button
              GreenButton(
                text: 'Track Order',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OrderHistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),
              // Back to home
              GestureDetector(
                onTap: () {
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfettiDots() {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.purple,
      AppColors.primaryGreen,
    ];

    return List.generate(8, (index) {
      final angle = (index / 8) * 2 * pi;
      final radius = 100.0 + (index % 3) * 15;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      final size = 8.0 + (index % 3) * 4;
      final color = colors[index % colors.length];

      return Positioned(
        left: 125 + x - size / 2,
        top: 125 + y - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
            color: index % 3 == 0 ? color : Colors.transparent,
            border: index % 3 != 0
                ? Border.all(color: color, width: 2)
                : null,
            borderRadius: index % 2 != 0
                ? BorderRadius.circular(2)
                : null,
          ),
        ),
      );
    });
  }
}
