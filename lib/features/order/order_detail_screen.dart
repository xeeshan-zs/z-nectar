import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/order_service.dart';
import 'package:grocery_app/core/services/review_service.dart';
import 'package:grocery_app/data/models/order_model.dart';
import 'package:grocery_app/data/models/review_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';
import 'package:grocery_app/core/services/support_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<OrderModel?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = OrderService.instance.getOrderByIdOnce(widget.orderId);
  }

  void _refresh() {
    setState(() {
      _orderFuture = OrderService.instance.getOrderByIdOnce(widget.orderId);
    });
  }

  static const List<Map<String, dynamic>> _steps = [
    {
      'status': 'pending',
      'label': 'Order Accepted',
      'desc': 'Your order has been received and is being reviewed.',
      'icon': Icons.receipt_long_outlined,
    },
    {
      'status': 'payment_verified',
      'label': 'Payment Verified',
      'desc': 'Your payment has been confirmed.',
      'icon': Icons.verified_outlined,
    },
    {
      'status': 'ready_for_delivery',
      'label': 'Ready for Delivery',
      'desc': 'Your order is packed and handed to delivery.',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'status': 'delivered',
      'label': 'Delivered',
      'desc': 'Your order has been delivered. Enjoy!',
      'icon': Icons.check_circle_outline,
    },
  ];

  static const _statusOrder = [
    'pending',
    'payment_verified',
    'ready_for_delivery',
    'delivered',
  ];

  int _currentIndex(String status) {
    final idx = _statusOrder.indexOf(status);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Order',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<OrderModel?>(
        future: _orderFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found.'));
          }

          final isCancelled = order.status == 'cancelled';
          final isDelivered = order.status == 'delivered';
          final currentIdx = isCancelled ? -1 : _currentIndex(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Order summary card ──────────────────────────
                _SummaryCard(order: order),
                const SizedBox(height: 28),

                // ── Cancelled banner ────────────────────────────
                if (isCancelled)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Order Cancelled',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'This order has been cancelled.',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.greyText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Progress timeline ───────────────────────────
                if (!isCancelled) ...[
                  Text(
                    'Order Progress  (${currentIdx + 1} / ${_steps.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    final isDone = idx <= currentIdx;
                    final isActive = idx == currentIdx;
                    final isLastStep = idx == _steps.length - 1;

                    return _StepTile(
                      icon: step['icon'] as IconData,
                      label: step['label'] as String,
                      desc: step['desc'] as String,
                      isDone: isDone,
                      isActive: isActive,
                      showConnector: !isLastStep,
                    );
                  }),
                ],

                const SizedBox(height: 28),

                // ── Items ───────────────────────────────────────
                const Text(
                  'Items Ordered',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 10),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.qty}x ${item.name}',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.darkText),
                          ),
                          Text(
                            'Rs ${(item.price * item.qty).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.greyText)),
                    Text(
                      'Rs ${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _reorder(context, order),
                    icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                    label: const Text('Reorder Items', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                // ── Review section (only for delivered orders) ──
                if (isDelivered) ...[
                  const SizedBox(height: 24),
                  
                  // Report Issue Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showSupportBottomSheet(context, order.id),
                      icon: const Icon(Icons.help_outline, color: AppColors.darkText),
                      label: const Text('Report an Issue', style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Rate Your Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your reviews help other customers make better choices.',
                    style: TextStyle(fontSize: 12, color: AppColors.greyText),
                  ),
                  const SizedBox(height: 16),
                  ...order.items.map((item) => _ReviewCard(
                        productId: item.productId,
                        productName: item.name,
                      )),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _reorder(BuildContext context, OrderModel order) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
    );

    try {
      for (final item in order.items) {
        final doc = await FirebaseFirestore.instance.collection('products').doc(item.productId).get();
        if (doc.exists) {
           final product = ProductModel.fromMap(doc.id, doc.data()!);
           await CartService.instance.addToCart(currentUser.uid, product, qty: item.qty);
        }
      }
      if (context.mounted) {
        Navigator.pop(context); // close dialog
        SnackbarService.showSuccess(context, 'Items added to cart!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close dialog
        SnackbarService.showError(context, 'Failed to reorder');
      }
    }
  }

  void _showSupportBottomSheet(BuildContext context, String orderId) {
    final msgCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool submitting = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Report an Issue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  const SizedBox(height: 8),
                  const Text('Describe the problem with your order. We will look into it and get back to you soon.', style: TextStyle(fontSize: 14, color: AppColors.greyText)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: msgCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'E.g., Missing items, damaged goods, etc.',
                      hintStyle: const TextStyle(fontSize: 14, color: AppColors.greyText),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : () async {
                        if (msgCtrl.text.trim().isEmpty) return;
                        setState(() => submitting = true);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await SupportService.instance.submitTicket(
                              orderId: orderId,
                              userId: user.uid,
                              message: msgCtrl.text.trim(),
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              SnackbarService.showSuccess(ctx, 'Ticket submitted successfully');
                            }
                          }
                        } finally {
                          if (ctx.mounted) {
                            setState(() => submitting = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: submitting 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Summary card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final OrderModel order;
  const _SummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr = order.createdAt != null
        ? DateFormat('MMM dd, yyyy – hh:mm a').format(order.createdAt!.toDate())
        : 'N/A';

    Color statusColor;
    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'payment_verified':
        statusColor = Colors.blue;
        break;
      case 'ready_for_delivery':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = AppColors.primaryGreen;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.greyText;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
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
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.greyText),
              const SizedBox(width: 5),
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.greyText)),
            ],
          ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.greyText),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.greyText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Single step tile ──────────────────────────────────────────────────────────
class _StepTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool isDone;
  final bool isActive;
  final bool showConnector;

  const _StepTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.isDone,
    required this.isActive,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor =
        isDone ? AppColors.primaryGreen : AppColors.borderGrey;
    final Color iconColor = isDone ? AppColors.white : AppColors.greyText;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    border: isDone
                        ? null
                        : Border.all(color: AppColors.borderGrey, width: 2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: isDone
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primaryGreen,
                                  Color(0xFFD0EDD4)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: isDone ? null : AppColors.borderGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Right column
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 8, bottom: showConnector ? 20 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          isDone ? AppColors.darkText : AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
          ),
          if (isDone)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                Icons.check_circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.8),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Per-product review card ───────────────────────────────────────────────────
class _ReviewCard extends StatefulWidget {
  final String productId;
  final String productName;

  const _ReviewCard({required this.productId, required this.productName});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;
  bool? _alreadyReviewed; // null = loading

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _alreadyReviewed = false);
      return;
    }
    final reviewed = await ReviewService.instance
        .hasUserReviewed(widget.productId, user.uid);
    if (mounted) setState(() => _alreadyReviewed = reviewed);
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _rating == 0) return;

    setState(() => _submitting = true);
    try {
      await ReviewService.instance.submitReview(ReviewModel(
        id: '',
        productId: widget.productId,
        productName: widget.productName,
        userId: user.uid,
        userEmail: user.email ?? '',
        rating: _rating.toDouble(),
        comment: _commentCtrl.text.trim(),
      ));
      if (mounted) setState(() => _alreadyReviewed = true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.productName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),

          // Already reviewed
          if (_alreadyReviewed == null)
            const SizedBox(
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryGreen)),

          if (_alreadyReviewed == true) ...[
            Row(children: [
              const Icon(Icons.check_circle,
                  color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 6),
              const Text('Review submitted – thank you!',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.primaryGreen)),
            ]),
          ],

          // Review form
          if (_alreadyReviewed == false) ...[
            // Star row
            Row(
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: i < _rating
                        ? Colors.amber
                        : AppColors.greyText,
                    size: 30,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            // Comment
            TextField(
              controller: _commentCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Write a comment (optional)',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.greyText),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.borderGrey),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_rating == 0 || _submitting) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor:
                      AppColors.primaryGreen.withValues(alpha: 0.4),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
