import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/core/services/favourites_service.dart';
import 'package:grocery_app/core/services/review_service.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/data/models/review_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavourite = false;
  bool _isAddingToCart = false;
  bool _detailExpanded = true;
  final int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
  }

  Future<void> _checkFavourite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final fav = await FavouritesService.instance
        .isFavourite(user.uid, widget.product.id);
    if (mounted) setState(() => _isFavourite = fav);
  }

  Future<void> _toggleFavourite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final newState = await FavouritesService.instance
        .toggleFavourite(user.uid, widget.product.id);
    if (mounted) setState(() => _isFavourite = newState);
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isAddingToCart = true);
    await CartService.instance
        .addToCart(user.uid, widget.product, qty: _quantity);
    if (!mounted) return;
    setState(() => _isAddingToCart = false);
    SnackbarService.showSuccess(context, '${widget.product.name} added to cart!');
  }

  void _shareProduct() {
    // Cross-platform friendly share fallback
    // In a real app, you'd use the share_plus package.
    final productId = Uri.encodeComponent(widget.product.id);
    final productName = Uri.encodeComponent(widget.product.name);
    final url = 'https://nectar.app/product?id=$productId&name=$productName';

    // Fallback: copy to clipboard
    Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      SnackbarService.showSuccess(context, 'Product link copied to clipboard!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Area
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: widget.product.imageUrl,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 2,
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: 80,
                              color: AppColors.greyText,
                            ),
                          ),
                        ),
                      ),
                      // Back & Share buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: AppConstants.horizontalPadding,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios,
                              color: AppColors.darkText, size: 22),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: AppConstants.horizontalPadding,
                        child: GestureDetector(
                          onTap: _shareProduct,
                          child: const Icon(Icons.ios_share,
                              color: AppColors.darkText, size: 22),
                        ),
                      ),
                    ],
                  ),
                  // Image Dots
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _imageIndex == index ? 10 : 7,
                        height: _imageIndex == index ? 10 : 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _imageIndex == index
                              ? AppColors.primaryGreen
                              : AppColors.borderGrey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Title & Favourite
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleFavourite,
                          child: Icon(
                            _isFavourite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: _isFavourite
                                ? Colors.red
                                : AppColors.greyText,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Low stock warning
                  if (widget.product.stockCount <= 10 &&
                      widget.product.stockCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: AppConstants.horizontalPadding,
                          top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 15, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Only ${widget.product.stockCount} item${widget.product.stockCount == 1 ? '' : 's'} left!',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Quantity Stepper & Price
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stepper
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                      color: AppColors.borderGrey, width: 1),
                                ),
                                child: const Icon(Icons.remove,
                                    color: AppColors.greyText, size: 22),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                    color: AppColors.borderGrey, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                      color: AppColors.borderGrey, width: 1),
                                ),
                                child: const Icon(Icons.add,
                                    color: AppColors.primaryGreen, size: 22),
                              ),
                            ),
                          ],
                        ),
                        // Price
                        Text(
                          'Rs ${(widget.product.price * _quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  // Product Detail Expandable
                  _buildExpandableSection(
                    title: 'Product Detail',
                    isExpanded: _detailExpanded,
                    onTap: () =>
                        setState(() => _detailExpanded = !_detailExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.greyText,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  // Nutritions Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.horizontalPadding,
                        vertical: 15),
                    child: Row(
                      children: [
                        const Text(
                          'Nutritions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.product.nutritionWeight,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.darkText, size: 24),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Reviews section — live from Firestore
                  _ReviewsSection(productId: widget.product.id),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Add To Basket Button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding, 0, AppConstants.horizontalPadding, 20),
            child: !widget.product.inStock
                ? Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Out of Stock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _isAddingToCart
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen))
                    : GreenButton(
                        text: 'Add To Basket',
                        onPressed: _addToCart,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                    color: AppColors.darkText,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }
}

// ── Live reviews section ──────────────────────────────────────────────────────
class _ReviewsSection extends StatefulWidget {
  final String productId;
  const _ReviewsSection({required this.productId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture =
        ReviewService.instance.getReviewsForProductOnce(widget.productId);
  }

  void _refresh() {
    setState(() {
      _reviewsFuture =
          ReviewService.instance.getReviewsForProductOnce(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];

        final avg = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    if (reviews.isNotEmpty) ...[
                      ...List.generate(
                          5,
                          (i) => Icon(
                                i < avg.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: i < avg.round()
                                    ? Colors.amber
                                    : AppColors.borderGrey,
                                size: 18,
                              )),
                      const SizedBox(width: 6),
                      Text(
                        '${avg.toStringAsFixed(1)} (${reviews.length})',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (reviews.isEmpty && snapshot.connectionState == ConnectionState.done)
                      const Text('No reviews yet',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.greyText)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _refresh,
                      child: const Icon(Icons.refresh,
                          color: AppColors.greyText, size: 18),
                    ),
                  ],
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primaryGreen),
                )),
              ...reviews.map((r) => _ReviewTile(review: r)),
              if (reviews.isNotEmpty) const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}


class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final initials = review.userEmail.isNotEmpty
        ? review.userEmail[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                AppColors.primaryGreen.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.userEmail.split('@').first,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                                i < review.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: i < review.rating.round()
                                    ? Colors.amber
                                    : AppColors.borderGrey,
                                size: 14,
                              )),
                    ),
                  ],
                ),
                if (review.comment.isNotEmpty) ...[  
                  const SizedBox(height: 3),
                  Text(
                    review.comment,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.greyText,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
