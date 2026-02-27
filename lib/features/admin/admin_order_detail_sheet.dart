import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/order_service.dart';
import 'package:grocery_app/data/models/order_model.dart';
import 'package:intl/intl.dart';

/// Call this to open the admin order detail bottom sheet.
Future<bool> showAdminOrderDetail(
    BuildContext context, OrderModel order) async {
  final advanced = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AdminOrderDetailSheet(order: order),
  );
  return advanced == true;
}

class _AdminOrderDetailSheet extends StatefulWidget {
  final OrderModel order;
  const _AdminOrderDetailSheet({required this.order});

  @override
  State<_AdminOrderDetailSheet> createState() => _AdminOrderDetailSheetState();
}

class _AdminOrderDetailSheetState extends State<_AdminOrderDetailSheet> {
  bool _advancing = false;

  static const _statusOrder = [
    'pending',
    'payment_verified',
    'ready_for_delivery',
    'delivered',
  ];

  static const _statusLabels = {
    'pending': 'Order Accepted',
    'payment_verified': 'Payment Verified',
    'ready_for_delivery': 'Ready for Delivery',
    'delivered': 'Delivered',
  };

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'payment_verified':
        return Colors.blue;
      case 'ready_for_delivery':
        return Colors.purple;
      case 'delivered':
        return AppColors.primaryGreen;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.greyText;
    }
  }

  Future<void> _advance() async {
    final next = widget.order.nextStatus;
    if (next == null) return;
    setState(() => _advancing = true);
    try {
      await OrderService.instance.updateStatus(widget.order.id, next);
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusColor = _statusColor(order.status);
    final dateStr = order.createdAt != null
        ? DateFormat('MMM dd, yyyy – hh:mm a').format(order.createdAt!.toDate())
        : 'N/A';
    final currentIdx = _statusOrder.indexOf(order.status);
    final isCancelled = order.status == 'cancelled';
    final isDelivered = order.status == 'delivered';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6F6F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(dateStr,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.greyText)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Progress timeline ──────────────────────────
                  if (!isCancelled) ...[
                    const Text(
                      'Order Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimeline(currentIdx),
                    const SizedBox(height: 20),
                  ],

                  if (isCancelled)
                    _buildCancelledBanner(),

                  // ── Address ────────────────────────────────────
                  if (order.address.isNotEmpty) ...[
                    _sectionCard(
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Address',
                      child: Text(order.address,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.greyText)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Items ──────────────────────────────────────
                  _sectionCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Items Ordered',
                    child: Column(
                      children: [
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('${item.qty}×',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.greyText)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(item.name,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.darkText)),
                                  ),
                                  Text(
                                    'Rs ${(item.price * item.qty).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText)),
                            Text(
                              'Rs ${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Advance button ─────────────────────────────────
            if (!isCancelled && !isDelivered && order.nextStatus != null)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _advancing ? null : _advance,
                      icon: _advancing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white),
                      label: Text(
                        _advancing
                            ? 'Updating…'
                            : 'Advance to "${_statusLabels[order.nextStatus] ?? order.nextStatus}"',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(int currentIdx) {
    final steps = [
      'Order Accepted',
      'Payment Verified',
      'Ready for Delivery',
      'Delivered',
    ];
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final isDone = i <= currentIdx;
        final isActive = i == currentIdx;
        final isLast = i == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isDone ? AppColors.primaryGreen : AppColors.borderGrey,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle_outlined,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: isDone
                        ? AppColors.primaryGreen.withValues(alpha: 0.4)
                        : AppColors.borderGrey,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 20),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? AppColors.darkText : AppColors.greyText,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCancelledBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
          SizedBox(width: 10),
          Text('This order has been cancelled.',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required IconData icon,
      required String title,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
