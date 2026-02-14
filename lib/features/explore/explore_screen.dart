import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/data/dummy_data.dart';
import 'package:grocery_app/data/models/category_model.dart';
import 'package:grocery_app/features/explore/category_products_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Find Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
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
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: AppColors.darkText, size: 22),
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
          // Category Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: DummyData.categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(category: DummyData.categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.bgColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: category.borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    Icons.category_outlined,
                    color: category.borderColor,
                    size: 50,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
