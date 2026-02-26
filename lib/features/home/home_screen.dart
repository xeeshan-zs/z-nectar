import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/services/location_service.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/core/services/banner_service.dart';
import 'package:grocery_app/data/models/location_model.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/data/models/banner_model.dart';
import 'package:grocery_app/features/location/location_selection_screen.dart';
import 'package:grocery_app/core/widgets/product_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  
  late final Stream<LocationModel?> _locationStream;
  late final Stream<List<BannerModel>> _bannersStream;
  late final Stream<List<ProductModel>> _carouselProductsStream;
  late final Stream<List<ProductModel>> _featuredProductsStream;
  late final Stream<List<ProductModel>> _exclusiveProductsStream;
  late final Stream<List<ProductModel>> _bestSellingProductsStream;

  @override
  void initState() {
    super.initState();
    _locationStream = LocationService.instance.getCurrentLocation();
    _bannersStream = BannerService.instance.getBanners();
    _carouselProductsStream = ProductService.instance.getCarouselProducts();
    _featuredProductsStream = ProductService.instance.getFeaturedProducts();
    _exclusiveProductsStream = ProductService.instance.getExclusiveProducts();
    _bestSellingProductsStream = ProductService.instance.getBestSellingProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Carrot Icon
            CachedNetworkImage(
              imageUrl: 'https://img.icons8.com/emoji/96/carrot-emoji.png',
              width: 35,
              height: 35,
              placeholder: (context, url) => const SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.eco,
                color: AppColors.primaryGreen,
                size: 35,
              ),
            ),
            const SizedBox(height: 8),
            // Location Row
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LocationSelectionScreen(),
                  ),
                );
              },
              child: StreamBuilder<LocationModel?>(
                stream: _locationStream,
                builder: (context, snapshot) {
                  final location = snapshot.data?.address ?? 'Select Location';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.darkText, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.searchBarBg,
                  borderRadius:
                      BorderRadius.circular(AppConstants.searchBarRadius),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: AppColors.darkText, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Search Store',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Banner Carousel (from Firestore) ─────────────────────────
            _buildBannerCarousel(),
            const SizedBox(height: 25),

            // ── Product Carousel (admin-flagged carousel products) ────────
            _buildProductCarousel(),
            const SizedBox(height: 25),

            // ── Featured Products Section ─────────────────────────────────
            _buildSectionHeader('Featured Products'),
            const SizedBox(height: 16),
            StreamBuilder<List<ProductModel>>(
              stream: _featuredProductsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: Text('No featured products yet',
                          style: TextStyle(color: AppColors.greyText)),
                    ),
                  );
                }
                final products = snapshot.data!;
                return SizedBox(
                  height: AppConstants.productCardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // ── Exclusive Offer Section (from Firestore) ─────────────────
            _buildSectionHeader('Exclusive Offer'),
            const SizedBox(height: 16),
            StreamBuilder<List<ProductModel>>(
              stream: _exclusiveProductsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: Text('No exclusive offers yet',
                          style: TextStyle(color: AppColors.greyText)),
                    ),
                  );
                }
                final products = snapshot.data!;
                return SizedBox(
                  height: AppConstants.productCardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // ── Best Selling Section (from Firestore) ────────────────────
            _buildSectionHeader('Best Selling'),
            const SizedBox(height: 16),
            StreamBuilder<List<ProductModel>>(
              stream: _bestSellingProductsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: Text('No best sellers yet',
                          style: TextStyle(color: AppColors.greyText)),
                    ),
                  );
                }
                final products = snapshot.data!;
                return SizedBox(
                  height: AppConstants.productCardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ── Banner Carousel from Firestore ────────────────────────────────────
  Widget _buildBannerCarousel() {
    return StreamBuilder<List<BannerModel>>(
      stream: _bannersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Fallback: show static banners if none in DB
          return _buildStaticBanners();
        }
        final banners = snapshot.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 115,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  onPageChanged: (index, _) =>
                      setState(() => _bannerIndex = index),
                ),
                items: banners
                    .map((b) => _buildBanner(b.title, b.subtitle, b.imageUrl))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _bannerIndex == index ? 10 : 8,
                  height: _bannerIndex == index ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bannerIndex == index
                        ? AppColors.primaryGreen
                        : AppColors.borderGrey,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStaticBanners() {
    final staticBanners = [
      ('Fresh Vegetables', 'Get Up To 40% OFF',
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400'),
      ('Organic Fruits', 'Save Up To 30%',
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400'),
      ('Dairy Products', 'Fresh & Healthy',
          'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400'),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 115,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, _) =>
                  setState(() => _bannerIndex = index),
            ),
            items: staticBanners
                .map((b) => _buildBanner(b.$1, b.$2, b.$3))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(staticBanners.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _bannerIndex == index ? 10 : 8,
              height: _bannerIndex == index ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _bannerIndex == index
                    ? AppColors.primaryGreen
                    : AppColors.borderGrey,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Product Carousel (Carousel-flagged products) ──────────────────────
  Widget _buildProductCarousel() {
    return StreamBuilder<List<ProductModel>>(
      stream: _carouselProductsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final products = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Top Picks'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  viewportFraction: 0.85,
                  enlargeCenterPage: true,
                  autoPlay: products.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: products.map((product) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to product detail if needed
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              width: 140,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 140,
                                height: 180,
                                color: AppColors.lightGrey,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 140,
                                height: 180,
                                color: AppColors.lightGrey,
                                child: const Icon(Icons.image,
                                    color: AppColors.greyText, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    product.unit,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.greyText,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Rs ${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String title, String subtitle, String imageUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFF3F5E9),
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 110,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 110,
                height: 100,
                color: AppColors.lightGrey,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 110,
                height: 100,
                color: AppColors.lightGrey,
                child: const Icon(Icons.image,
                    color: AppColors.greyText, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
