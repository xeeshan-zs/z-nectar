import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/data/dummy_data.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/features/product_detail/product_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favourites = DummyData.beverages;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Favourites',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          // Favourites List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 5),
              itemCount: favourites.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return _FavouriteItemTile(product: favourites[index]);
              },
            ),
          ),
          // Add All To Cart Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding, 10, AppConstants.horizontalPadding, 20),
            child: GreenButton(
              text: 'Add All To Cart',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All items added to cart!'),
                    backgroundColor: AppColors.primaryGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteItemTile extends StatelessWidget {
  final ProductModel product;

  const _FavouriteItemTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding, vertical: 12),
        child: Row(
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 55,
              height: 55,
              fit: BoxFit.contain,
              placeholder: (_, __) => Container(
                width: 55,
                height: 55,
                color: AppColors.lightGrey,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 55,
                height: 55,
                color: AppColors.lightGrey,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.greyText, size: 24),
              ),
            ),
            const SizedBox(width: 20),
            // Name & Unit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.unit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Price & Chevron
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.darkText, size: 22),
          ],
        ),
      ),
    );
  }
}
