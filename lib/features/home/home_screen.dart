import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/product_card.dart';
import 'package:grocery_app/data/dummy_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            // Carrot Icon
            Image.network(
              'https://img.icons8.com/emoji/96/carrot-emoji.png',
              width: 35,
              height: 35,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.eco,
                color: AppColors.primaryGreen,
                size: 35,
              ),
            ),
            const SizedBox(height: 8),
            // Location Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: AppColors.darkText, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Dhaka, Banassre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
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
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search, color: AppColors.darkText, size: 22),
                    const SizedBox(width: 10),
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
            // Banner Carousel
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
                items: [
                  _buildBanner(
                    'Fresh Vegetables',
                    'Get Up To 40% OFF',
                    'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
                  ),
                  _buildBanner(
                    'Organic Fruits',
                    'Save Up To 30%',
                    'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
                  ),
                  _buildBanner(
                    'Dairy Products',
                    'Fresh & Healthy',
                    'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Banner Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
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
            const SizedBox(height: 25),
            // Exclusive Offer Section
            _buildSectionHeader('Exclusive Offer'),
            const SizedBox(height: 16),
            SizedBox(
              height: AppConstants.productCardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding),
                itemCount: DummyData.exclusiveOffers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return ProductCard(
                      product: DummyData.exclusiveOffers[index]);
                },
              ),
            ),
            const SizedBox(height: 25),
            // Best Selling Section
            _buildSectionHeader('Best Selling'),
            const SizedBox(height: 16),
            SizedBox(
              height: AppConstants.productCardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding),
                itemCount: DummyData.bestSelling.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return ProductCard(product: DummyData.bestSelling[index]);
                },
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
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
            child: Image.network(
              imageUrl,
              width: 110,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
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
