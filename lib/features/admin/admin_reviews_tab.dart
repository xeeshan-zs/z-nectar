import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/review_service.dart';
import 'package:grocery_app/data/models/review_model.dart';
import 'package:intl/intl.dart';

class AdminReviewsTab extends StatefulWidget {
  const AdminReviewsTab({super.key});

  @override
  State<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends State<AdminReviewsTab> {
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService.instance.getAllReviews();
  }

  void _refresh() =>
      setState(() => _reviewsFuture = ReviewService.instance.getAllReviews());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 72,
                    color: AppColors.greyText.withValues(alpha: 0.35)),
                const SizedBox(height: 16),
                const Text('No reviews yet',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText)),
                const SizedBox(height: 6),
                const Text('Customer reviews will appear here',
                    style: TextStyle(fontSize: 14, color: AppColors.greyText)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          );
        }

        // Summary stats
        final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length;
        final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        for (final r in reviews) {
          dist[r.rating.round()] = (dist[r.rating.round()] ?? 0) + 1;
        }

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          color: AppColors.primaryGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Stats header ──────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Average
                      Column(
                        children: [
                          Text(
                            avg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.greyText),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      const VerticalDivider(width: 1),
                      const SizedBox(width: 24),
                      // Distribution
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = dist[star] ?? 0;
                            final frac =
                                reviews.isEmpty ? 0.0 : count / reviews.length;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('$star',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.greyText)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star,
                                      size: 12, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: frac,
                                        minHeight: 6,
                                        backgroundColor: AppColors.borderGrey,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                Colors.amber),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 20,
                                    child: Text('$count',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.greyText)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Review list ───────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ReviewCard(review: reviews[i]),
                    childCount: reviews.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final initials = review.userEmail.isNotEmpty
        ? review.userEmail[0].toUpperCase()
        : '?';
    final dateStr = review.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(review.createdAt!.toDate())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User + date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.userEmail.split('@').first,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(dateStr,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.greyText)),
                  ],
                ),
                const SizedBox(height: 2),
                // Product name
                Text(
                  review.productName.isNotEmpty
                      ? review.productName
                      : 'Product ID: ${review.productId.substring(0, review.productId.length.clamp(0, 12))}…',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                // Stars
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
                            size: 16,
                          )),
                ),
                // Comment
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${review.comment}"',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.greyText,
                      fontStyle: FontStyle.italic,
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
