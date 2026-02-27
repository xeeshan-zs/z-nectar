import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/product_card.dart';
import 'package:grocery_app/data/models/product_model.dart';

class AllProductsScreen extends StatefulWidget {
  final String title;
  final Stream<List<ProductModel>> Function() streamProvider;

  const AllProductsScreen({
    super.key,
    required this.title,
    required this.streamProvider,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: widget.streamProvider(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load products:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Skeleton loading ────────────────────────────────────────────
          if (!snapshot.hasData) {
            return AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, _) {
                final opacity =
                    0.3 + _shimmerController.value * 0.4; // 0.3 → 0.7
                return GridView.builder(
                  padding:
                      const EdgeInsets.all(AppConstants.horizontalPadding),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => _SkeletonCard(opacity: opacity),
                );
              },
            );
          }

          final products = snapshot.data!;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket_outlined,
                      size: 64,
                      color: AppColors.greyText.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No products in "${widget.title}" yet',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Once we have data, animate them in staggeringly
          return _StaggeredGrid(products: products);
        },
      ),
    );
  }
}

class _StaggeredGrid extends StatefulWidget {
  final List<ProductModel> products;
  const _StaggeredGrid({required this.products});

  @override
  State<_StaggeredGrid> createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<_StaggeredGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Start animation as soon as data is ready!
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.72,
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        // Calculate a staggered delay based on the index.
        // E.g. index 0 starts at 0.0, index 1 starts at 0.1, etc.
        final start = (index * 0.1).clamp(0.0, 1.0);
        final end = (start + 0.4).clamp(0.0, 1.0);

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - animation.value)),
                child: child,
              ),
            );
          },
          child: ProductCard(product: widget.products[index]),
        );
      },
    );
  }
}

// ── Skeleton card ─────────────────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  final double opacity;
  const _SkeletonCard({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: Center(
              child: _Bone(
                opacity: opacity,
                width: double.infinity,
                height: double.infinity,
                radius: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Name
          _Bone(opacity: opacity, width: double.infinity, height: 12, radius: 6),
          const SizedBox(height: 6),
          // Stars
          _Bone(opacity: opacity, width: 80, height: 10, radius: 5),
          const SizedBox(height: 10),
          // Price + button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Bone(opacity: opacity, width: 60, height: 14, radius: 6),
              _Bone(opacity: opacity, width: 36, height: 36, radius: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double opacity;
  final double width;
  final double height;
  final double radius;

  const _Bone({
    required this.opacity,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

