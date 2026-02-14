import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? trailing;
  final double? width;

  const GreenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.trailing,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 67,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          elevation: 0,
        ),
        child: trailing != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: trailing!,
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}
