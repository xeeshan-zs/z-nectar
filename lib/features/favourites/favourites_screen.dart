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

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  User? _currentUser;
  late final Stream<Set<String>> _favIdsStream;
  late final Stream<List<ProductModel>> _productsStream;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _favIdsStream = FavouritesService.instance.getFavouriteIds(_currentUser!.uid);
    } else {
      _favIdsStream = const Stream.empty();
    }
    _productsStream = ProductService.instance.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
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
              stream: _favIdsStream,
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
                  stream: _productsStream,
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
                                userId: _currentUser!.uid,
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
                              final inStockFavs = favourites
                                  .where((p) => p.inStock)
                                  .toList();
                              for (final p in inStockFavs) {
                                await CartService.instance
                                    .addToCart(_currentUser!.uid, p);
                              }
                              if (context.mounted) {
                                final skipped =
                                    favourites.length - inStockFavs.length;
                                final msg = skipped > 0
                                    ? 'Added ${inStockFavs.length} item(s) to cart ($skipped out of stock)'
                                    : 'All favourites added to cart!';
                                SnackbarService.showSuccess(context, msg);
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
            // Image with OOS overlay
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    width: 60, height: 60, color: AppColors.lightGrey),
                  errorWidget: (_, __, ___) => Container(
                    width: 60, height: 60, color: AppColors.lightGrey,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppColors.greyText)),
                ),
                if (!product.inStock)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      color: Colors.red.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: const Text(
                        'Out of Stock',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
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
                ],
              ),
            ),
            Text(
              'Rs ${product.price.toStringAsFixed(2)}',
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
