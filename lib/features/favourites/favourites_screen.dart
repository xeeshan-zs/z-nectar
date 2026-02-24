import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/core/services/favourites_service.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/features/product_detail/product_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text('Please log in to see your favourites',
            style: TextStyle(fontSize: 16, color: AppColors.greyText)),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Favourites',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 5),
          const Divider(),
          Expanded(
            child: StreamBuilder<Set<String>>(
              stream: FavouritesService.instance.getFavouriteIds(user.uid),
              builder: (context, favSnapshot) {
                if (favSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  );
                }

                final favIds = favSnapshot.data ?? {};

                if (favIds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_outline,
                            size: 80,
                            color:
                                AppColors.greyText.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No favourites yet',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText)),
                        const SizedBox(height: 8),
                        const Text(
                            'Tap the heart icon on products to add them',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.greyText)),
                      ],
                    ),
                  );
                }

                // Stream all products, filter to favourites
                return StreamBuilder<List<ProductModel>>(
                  stream: ProductService.instance.getProducts(),
                  builder: (context, prodSnapshot) {
                    if (prodSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      );
                    }

                    final allProducts = prodSnapshot.data ?? [];
                    final favourites = allProducts
                        .where((p) => favIds.contains(p.id))
                        .toList();

                    if (favourites.isEmpty) {
                      return const Center(
                        child: Text('Your favourited products were removed',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.greyText)),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: favourites.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              return _FavouriteItemTile(
                                product: favourites[index],
                                userId: user.uid,
                              );
                            },
                          ),
                        ),
                        // Add All To Cart
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppConstants.horizontalPadding,
                              10,
                              AppConstants.horizontalPadding,
                              20),
                          child: GreenButton(
                            text: 'Add All To Cart',
                            onPressed: () async {
                              for (final p in favourites) {
                                await CartService.instance
                                    .addToCart(user.uid, p);
                              }
                              if (context.mounted) {
                                SnackbarService.showSuccess(context, 'All favourites added to cart!');
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
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
  final String userId;

  const _FavouriteItemTile({required this.product, required this.userId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            horizontal: AppConstants.horizontalPadding, vertical: 10),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              placeholder: (_, __) => Container(
                width: 60,
                height: 60,
                color: AppColors.lightGrey,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: AppColors.lightGrey,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.greyText),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unit,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right,
                color: AppColors.darkText, size: 24),
          ],
        ),
      ),
    );
  }
}
