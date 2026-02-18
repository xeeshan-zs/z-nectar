import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/order_service.dart';
import 'package:grocery_app/core/services/product_service.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  Map<String, int> _orderCounts = {};
  double _revenue = 0;
  int _productCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final counts = await OrderService.instance.getOrderCounts();
    final revenue = await OrderService.instance.getTotalRevenue();
    final productCount = await ProductService.instance.getProductCount();
    if (mounted) {
      setState(() {
        _orderCounts = counts;
        _revenue = revenue;
        _productCount = productCount;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalOrders = _orderCounts.values.fold(0, (a, b) => a + b);
    final pending = _orderCounts['pending'] ?? 0;
    final delivered = _orderCounts['delivered'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  icon: Icons.receipt_long,
                  label: 'Total Orders',
                  value: totalOrders.toString(),
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Revenue',
                  value: '\$${_revenue.toStringAsFixed(2)}',
                  color: AppColors.primaryGreen,
                ),
                _buildStatCard(
                  icon: Icons.pending_actions,
                  label: 'Pending',
                  value: pending.toString(),
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: Icons.inventory_2,
                  label: 'Products',
                  value: _productCount.toString(),
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Order Distribution
            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Pending', pending, Colors.orange),
            _buildStatusRow('Payment Verified',
                _orderCounts['payment_verified'] ?? 0, Colors.blue),
            _buildStatusRow('Ready for Delivery',
                _orderCounts['ready_for_delivery'] ?? 0, Colors.teal),
            _buildStatusRow('Delivered', delivered, AppColors.primaryGreen),
            _buildStatusRow(
                'Cancelled', _orderCounts['cancelled'] ?? 0, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
