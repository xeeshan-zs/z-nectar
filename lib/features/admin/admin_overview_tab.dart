import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/order_service.dart';
import 'package:grocery_app/core/services/product_service.dart';

import 'package:grocery_app/data/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  Map<String, int> _orderCounts = {};
  double _revenue = 0;
  int _productCount = 0;
  int _categoryCount = 0;
  int _customerCount = 0;
  List<OrderModel> _recentOrders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final counts = await OrderService.instance.getOrderCounts();
      final revenue = await OrderService.instance.getTotalRevenue();
      final productCount = await ProductService.instance.getProductCount();

      // Category count
      final catSnap = await FirebaseFirestore.instance
          .collection('categories')
          .count()
          .get();
      final catCount = catSnap.count ?? 0;

      // Customer count
      final custSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .count()
          .get();
      final custCount = custSnap.count ?? 0;

      // Recent 5 orders
      final recentSnap = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      final recentOrders = recentSnap.docs
          .map((d) => OrderModel.fromMap(d.id, d.data()))
          .toList();

      if (mounted) {
        setState(() {
          _orderCounts = counts;
          _revenue = revenue;
          _productCount = productCount;
          _categoryCount = catCount;
          _customerCount = custCount;
          _recentOrders = recentOrders;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    final totalOrders = _orderCounts.values.fold(0, (a, b) => a + b);
    final pending = _orderCounts['pending'] ?? 0;
    final delivered = _orderCounts['delivered'] ?? 0;
    final cancelled = _orderCounts['cancelled'] ?? 0;

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Revenue Hero Card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.trending_up_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$delivered delivered',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${_revenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stat Cards Grid ────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.5,
              children: [
                _buildGradientStatCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Total Orders',
                  value: totalOrders.toString(),
                  gradient: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                _buildGradientStatCard(
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'Pending',
                  value: pending.toString(),
                  gradient: const [Color(0xFFE65100), Color(0xFFFF9800)],
                ),
                _buildGradientStatCard(
                  icon: Icons.inventory_2_rounded,
                  label: 'Products',
                  value: _productCount.toString(),
                  gradient: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                ),
                _buildGradientStatCard(
                  icon: Icons.people_rounded,
                  label: 'Customers',
                  value: _customerCount.toString(),
                  gradient: const [Color(0xFF00695C), Color(0xFF26A69A)],
                ),
                _buildGradientStatCard(
                  icon: Icons.category_rounded,
                  label: 'Categories',
                  value: _categoryCount.toString(),
                  gradient: const [Color(0xFF4E342E), Color(0xFF8D6E63)],
                ),
                _buildGradientStatCard(
                  icon: Icons.cancel_rounded,
                  label: 'Cancelled',
                  value: cancelled.toString(),
                  gradient: const [Color(0xFFC62828), Color(0xFFEF5350)],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Order Status Breakdown ─────────────────────────────
            const Text(
              'Order Pipeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatusProgress(
                      'Pending', pending, totalOrders, Colors.orange),
                  const SizedBox(height: 12),
                  _buildStatusProgress('Payment Verified',
                      _orderCounts['payment_verified'] ?? 0, totalOrders, Colors.blue),
                  const SizedBox(height: 12),
                  _buildStatusProgress('Ready for Delivery',
                      _orderCounts['ready_for_delivery'] ?? 0, totalOrders, Colors.teal),
                  const SizedBox(height: 12),
                  _buildStatusProgress(
                      'Delivered', delivered, totalOrders, AppColors.primaryGreen),
                  const SizedBox(height: 12),
                  _buildStatusProgress(
                      'Cancelled', cancelled, totalOrders, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Recent Orders ──────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_recentOrders.length} latest',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_recentOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('No orders yet',
                      style: TextStyle(color: AppColors.greyText)),
                ),
              )
            else
              ...List.generate(_recentOrders.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(bottom: i < _recentOrders.length - 1 ? 10 : 0),
                  child: _buildRecentOrderCard(_recentOrders[i]),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgress(String label, int count, int total, Color color) {
    final fraction = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            count.toString(),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrderCard(OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final dateStr = order.createdAt != null
        ? DateFormat('MMM dd, hh:mm a').format(order.createdAt!.toDate())
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Order info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} item(s) • $dateStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          // Total
          Text(
            'Rs ${order.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(width: 10),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          // Quick advance button
          if (order.nextStatus != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                OrderService.instance
                    .updateStatus(order.id, order.nextStatus!);
                _loadStats();
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primaryGreen, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'payment_verified':
        return Colors.blue;
      case 'ready_for_delivery':
        return Colors.teal;
      case 'delivered':
        return AppColors.primaryGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.greyText;
    }
  }
}
