import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/services/category_service.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/core/widgets/product_card.dart';
import 'package:grocery_app/data/models/category_model.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/features/explore/category_products_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Find Products',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 15),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText),
              decoration: InputDecoration(
                hintText: 'Search Store',
                hintStyle: const TextStyle(
                    color: AppColors.greyText, fontWeight: FontWeight.w500),
                prefixIcon: const Icon(Icons.search, color: AppColors.darkText),
                filled: true,
                fillColor: AppColors.lightGrey,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Content
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  /// Search results — queries products from Firestore by name
  Widget _buildSearchResults() {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService.instance.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final allProducts = snapshot.data ?? [];
        final filtered = allProducts
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 64,
                    color: AppColors.greyText.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  'No results for "$_searchQuery"',
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.greyText),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding:
              const EdgeInsets.all(AppConstants.horizontalPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return ProductCard(product: filtered[index]);
          },
        );
      },
    );
  }

  /// Category grid — from Firestore
  Widget _buildCategoryGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: CategoryService.instance.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No categories yet',
              style: TextStyle(fontSize: 16, color: AppColors.greyText),
            ),
          );
        }

        final categories = docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return CategoryModel(
            id: d.id,
            name: data['name'] as String? ?? '',
            imageUrl: data['imageUrl'] as String? ?? '',
            bgColor: _parseColor(data['bgColor'] as String? ?? '#F3F5E9'),
            borderColor:
                _parseColor(data['borderColor'] as String? ?? '#E2E7D5'),
          );
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _CategoryCard(category: categories[index]);
          },
        );
      },
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: category.borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: category.imageUrl,
              width: 100,
              height: 80,
              fit: BoxFit.contain,
              placeholder: (_, __) => const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryGreen),
              ),
              errorWidget: (_, __, ___) => const Icon(
                  Icons.category_outlined,
                  size: 50,
                  color: AppColors.greyText),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category.name.replaceAll('\n', ' '),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
