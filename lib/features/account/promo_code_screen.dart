import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/services/providers.dart';
import 'package:grocery_app/data/models/promo_model.dart';
import 'package:intl/intl.dart';

class PromoCodeScreen extends ConsumerStatefulWidget {
  final bool isSelectionMode;
  const PromoCodeScreen({super.key, this.isSelectionMode = false});

  @override
  ConsumerState<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends ConsumerState<PromoCodeScreen> {
  final _codeCtrl = TextEditingController();
  late Future<List<PromoModel>> _promosFuture;

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  void _loadPromos() {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      _promosFuture = ref.read(promoServiceProvider).getAvailablePromos(user.uid);
    } else {
      _promosFuture = Future.value([]);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCode(String code) async {
    if (code.isEmpty) return;
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
    );

    final validPromo = await ref.read(promoServiceProvider).validateCode(user.uid, code);
    if (!mounted) return;

    Navigator.pop(context); // close dialog

    if (validPromo != null) {
      if (widget.isSelectionMode) {
        Navigator.pop(context, validPromo); // Return the promo model specifically here
      } else {
        SnackbarService.showSuccess(context, 'Promo code ${validPromo.code} is valid!');
        _codeCtrl.clear();
      }
    } else {
      SnackbarService.showError(context, 'Invalid, expired, or already used promo code');
    }
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
        title: const Text(
          'Promo Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Input Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Enter Promo Code',
                      hintStyle: const TextStyle(
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => _applyCode(_codeCtrl.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(80, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Apply',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Available Vouchers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<PromoModel>>(
                future: _promosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading promos:\n${snapshot.error}'));
                  }

                  final promos = snapshot.data ?? [];

                  if (promos.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No active vouchers found.', style: TextStyle(color: AppColors.greyText)),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: promos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      return _buildVoucherCard(promos[index]);
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(PromoModel promo) {
    // Dynamic color based on percent
    final color = promo.discountPercent > 10 ? const Color(0xFFFFE0B2) : const Color(0xFFC8E6C9);
    final iconColor = promo.discountPercent > 10 ? Colors.orange : AppColors.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Icon(Icons.confirmation_num,
                color: iconColor, size: 40),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.darkText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        promo.expiryDate != null 
                            ? 'Expires ${DateFormat('MMM dd, yyyy').format(promo.expiryDate!.toDate())}' 
                            : 'No Expiry', 
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _codeCtrl.text = promo.code;
                          if (widget.isSelectionMode) {
                            // Don't call _applyCode here because the USE CODE button 
                            // already signifies a valid promo from the list anyway. We 
                            // can just return it immediately.
                            Navigator.pop(context, promo);
                          } else {
                            // Just check it for user confirmation
                            _applyCode(promo.code);
                          }
                        },
                        child: Text(
                          'USE CODE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
