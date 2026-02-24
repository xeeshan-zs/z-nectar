import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';

class SnackbarService {
  SnackbarService._();

  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      icon: Icons.check_circle_outline,
      backgroundColor: AppColors.primaryGreen,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      icon: Icons.error_outline,
      backgroundColor: Colors.redAccent,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      icon: Icons.info_outline,
      backgroundColor: const Color(0xFF2E3E5C), // Dark blue/grey
    );
  }

  static void _showSnackbar(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color backgroundColor,
  }) {
    if (!context.mounted) return;
    
    // Hide current if any
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      duration: const Duration(seconds: 3),
      elevation: 4,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
