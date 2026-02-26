import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/features/admin/add_edit_product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProductsTab extends StatefulWidget {
  const AdminProductsTab({super.key});

  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addProduct',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(
                    color: AppColors.greyText, fontWeight: FontWeight.w400),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.greyText, size: 22),
                filled: true,
                fillColor: AppColors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.borderGrey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Products list
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: ProductService.instance.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  );
                }

                var products = snapshot.data ?? [];

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  products = products
                      .where((p) => p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color:
                                AppColors.greyText.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No products match "$_searchQuery"'
                              : 'No products yet',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyText),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Count badge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${products.length} product${products.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(20, 4, 20, 80),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return Dismissible(
                            key: ValueKey(p.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) =>
                                _confirmDelete(context, p),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.red, size: 28),
                            ),
                            child: _buildProductCard(context, p),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                color: AppColors.lightGrey,
                child: const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primaryGreen),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: AppColors.lightGrey,
                child:
                    const Icon(Icons.image, color: AppColors.greyText),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Rs ${product.price.toStringAsFixed(2)} • ${product.unit}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.greyText),
                ),
                const SizedBox(height: 6),
                // Badge chips
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _chip(
                      product.inStock ? 'In Stock' : 'Out of Stock',
                      product.inStock
                          ? AppColors.primaryGreen
                          : Colors.red,
                    ),
                    if (product.isExclusive)
                      _chip('Exclusive', Colors.orange),
                    if (product.isCarousel)
                      _chip('Carousel', Colors.blue),
                    if (product.isFeatured)
                      _chip('Featured', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.greyText, size: 22),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditProductScreen(product: product),
                    ),
                  );
                  break;
                case 'toggle':
                  ProductService.instance
                      .toggleStock(product.id, !product.inStock);
                  break;
                case 'carousel':
                  ProductService.instance
                      .toggleCarousel(product.id, !product.isCarousel);
                  break;
                case 'featured':
                  ProductService.instance
                      .toggleFeatured(product.id, !product.isFeatured);
                  break;
                case 'exclusive':
                  ProductService.instance
                      .toggleExclusive(product.id, !product.isExclusive);
                  break;
                case 'delete':
                  _confirmDelete(context, product);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(product.inStock
                    ? 'Mark Out of Stock'
                    : 'Mark In Stock'),
              ),
              PopupMenuItem(
                value: 'exclusive',
                child: Text(product.isExclusive
                    ? 'Remove Exclusive'
                    : 'Mark Exclusive'),
              ),
              PopupMenuItem(
                value: 'carousel',
                child: Text(product.isCarousel
                    ? 'Remove from Carousel'
                    : 'Add to Carousel'),
              ),
              PopupMenuItem(
                value: 'featured',
                child: Text(product.isFeatured
                    ? 'Remove from Featured'
                    : 'Add to Featured'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
      BuildContext context, ProductModel product) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Text('Delete "${product.name}"? This cannot be undone.', style: const TextStyle(fontSize: 16, color: AppColors.greyText)),
        actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ProductService.instance.deleteProduct(product.id);
                    Navigator.of(ctx).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF35B5B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
