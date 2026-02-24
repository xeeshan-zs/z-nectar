import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/order_service.dart';
import 'package:grocery_app/data/models/order_model.dart';
import 'package:intl/intl.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = const [
    {'key': 'all', 'label': 'All'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'payment_verified', 'label': 'Verified'},
    {'key': 'ready_for_delivery', 'label': 'Ready'},
    {'key': 'delivered', 'label': 'Delivered'},
    {'key': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  Widget build(BuildContext context) {
    final stream = _selectedFilter == 'all'
        ? OrderService.instance.getAllOrders()
        : OrderService.instance.getOrdersByStatus(_selectedFilter);

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final f = _filters[index];
              final isActive = _selectedFilter == f['key'];
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = f['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primaryGreen
                          : AppColors.borderGrey,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.white : AppColors.greyText,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Orders list
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                );
              }
              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.greyText.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text('No orders found',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyText)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildOrderCard(context, orders[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final dateStr = order.createdAt != null
        ? DateFormat('MMM dd, yyyy  hh:mm a')
            .format(order.createdAt!.toDate())
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Customer
          Text(
            order.userEmail,
            style: const TextStyle(fontSize: 13, color: AppColors.greyText),
          ),
          const SizedBox(height: 6),
          // Date + details row
          Row(
            children: [
              // Items & total
              Text(
                '${order.items.length} item(s) • \$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              // Delivery method badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.paymentMethod == 'cod'
                          ? Icons.payments_outlined
                          : Icons.credit_card,
                      size: 13,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.paymentMethod.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Date row
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 13, color: AppColors.greyText),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
              ],
            ),
          ],
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.greyText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.greyText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              // View details
              OutlinedButton.icon(
                onPressed: () => _showOrderDetail(context, order),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Details', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkText,
                  side: const BorderSide(color: AppColors.borderGrey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
              const SizedBox(width: 8),
              // Advance status
              if (order.nextStatus != null)
                TextButton.icon(
                  onPressed: () => OrderService.instance
                      .updateStatus(order.id, order.nextStatus!),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(_nextActionLabel(order.status),
                      style: const TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              const Spacer(),
              // Cancel
              if (order.status != 'delivered' &&
                  order.status != 'cancelled')
                IconButton(
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.red, size: 22),
                  tooltip: 'Cancel Order',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Cancel Order'),
                        content: const Text(
                            'Are you sure you want to cancel this order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('No',
                                style:
                                    TextStyle(color: AppColors.greyText)),
                          ),
                          TextButton(
                            onPressed: () {
                              OrderService.instance
                                  .cancelOrder(order.id);
                              Navigator.of(ctx).pop();
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12))),
                            child: const Text('Cancel Order'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    final dateStr = order.createdAt != null
        ? DateFormat('MMM dd, yyyy  hh:mm a')
            .format(order.createdAt!.toDate())
        : 'N/A';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Order header
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // ── Status Timeline ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Timeline',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText)),
                    const SizedBox(height: 12),
                    _buildTimelineStep(
                      'Order Placed',
                      _isStatusReached(order.status, 'pending'),
                      Colors.orange,
                      isFirst: true,
                    ),
                    _buildTimelineStep(
                      'Payment Verified',
                      _isStatusReached(
                          order.status, 'payment_verified'),
                      Colors.blue,
                    ),
                    _buildTimelineStep(
                      'Ready for Delivery',
                      _isStatusReached(
                          order.status, 'ready_for_delivery'),
                      Colors.teal,
                    ),
                    _buildTimelineStep(
                      'Delivered',
                      _isStatusReached(order.status, 'delivered'),
                      AppColors.primaryGreen,
                      isLast: true,
                    ),
                    if (order.status == 'cancelled')
                      _buildTimelineStep(
                        'Cancelled',
                        true,
                        Colors.red,
                        isLast: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Info Section ────────────────────────────────
              _detailRow(Icons.person_outline, 'Customer', order.userEmail),
              _detailRow(Icons.schedule, 'Placed on', dateStr),
              _detailRow(Icons.payment, 'Payment',
                  order.paymentMethod.toUpperCase()),
              if (order.address.isNotEmpty)
                _detailRow(Icons.location_on_outlined, 'Address', order.address),
              const SizedBox(height: 18),

              // ── Items ───────────────────────────────────────
              const Text('Items',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...order.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text('Qty: ${item.qty}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyText)),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(item.price * item.qty).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.greyText),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.greyText),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String label,
    bool reached,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        SizedBox(
          width: 24,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 12,
                  color: reached
                      ? color
                      : AppColors.borderGrey,
                ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reached ? color : AppColors.white,
                  border: Border.all(
                    color: reached ? color : AppColors.borderGrey,
                    width: 2,
                  ),
                ),
                child: reached
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 12,
                  color: reached
                      ? color.withValues(alpha: 0.3)
                      : AppColors.borderGrey,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Label
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
              color: reached ? color : AppColors.greyText,
            ),
          ),
        ),
      ],
    );
  }

  bool _isStatusReached(String currentStatus, String checkStatus) {
    const pipeline = [
      'pending',
      'payment_verified',
      'ready_for_delivery',
      'delivered',
    ];
    final currentIdx = pipeline.indexOf(currentStatus);
    final checkIdx = pipeline.indexOf(checkStatus);
    if (currentIdx < 0 || checkIdx < 0) return false;
    return currentIdx >= checkIdx;
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

  String _nextActionLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Verify Payment';
      case 'payment_verified':
        return 'Mark Ready';
      case 'ready_for_delivery':
        return 'Mark Delivered';
      default:
        return '';
    }
  }
}
