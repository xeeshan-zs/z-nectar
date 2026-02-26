import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';
import 'package:grocery_app/core/services/cloudinary_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // null = add mode

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _nutritionCtrl;
  late bool _inStock;
  late bool _isExclusive;
  late bool _isCarousel;
  late bool _isFeatured;
  bool _loading = false;

  // Category dropdown
  String? _selectedCategoryId;
  List<Map<String, String>> _categories = []; // [{id, name}]
  bool _catsLoading = true;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _priceCtrl =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _unitCtrl = TextEditingController(text: p?.unit ?? '');
    _nutritionCtrl =
        TextEditingController(text: p?.nutritionWeight ?? '100gr');
    _inStock = p?.inStock ?? true;
    _isExclusive = p?.isExclusive ?? false;
    _isCarousel = p?.isCarousel ?? false;
    _isFeatured = p?.isFeatured ?? false;
    _selectedCategoryId = p?.categoryId;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snap = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .get();
    final cats = snap.docs
        .map((d) => {
              'id': d.id,
              'name': (d.data()['name'] as String?) ?? '',
            })
        .toList();
    if (mounted) {
      setState(() {
        _categories = cats;
        _catsLoading = false;
        // Verify selected category still exists
        if (_selectedCategoryId != null &&
            !cats.any((c) => c['id'] == _selectedCategoryId)) {
          _selectedCategoryId = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _nutritionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _loading = true);

    try {
      final url = await CloudinaryService.instance.pickAndUploadImage();
      
      if (url != null) {
        setState(() {
          _imageCtrl.text = url;
        });
        if (mounted) SnackbarService.showSuccess(context, 'Image uploaded successfully!');
      }
    } catch (e) {
      if (mounted) SnackbarService.showError(context, 'Error uploading image: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      SnackbarService.showError(context, 'Please select a category');
      return;
    }
    setState(() => _loading = true);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      unit: _unitCtrl.text.trim(),
      categoryId: _selectedCategoryId!,
      nutritionWeight: _nutritionCtrl.text.trim(),
      inStock: _inStock,
      isExclusive: _isExclusive,
      isCarousel: _isCarousel,
      isFeatured: _isFeatured,
      salesCount: widget.product?.salesCount ?? 0,
    );

    try {
      if (_isEdit) {
        if (widget.product!.imageUrl != product.imageUrl && widget.product!.imageUrl.isNotEmpty) {
           await CloudinaryService.instance.deleteImageByUrl(widget.product!.imageUrl);
        }
        await ProductService.instance
            .updateProduct(product.id, product.toMap());
      } else {
        await ProductService.instance.addProduct(product);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic Info Card ──────────────────────────────
              _sectionCard(
                title: 'Basic Info',
                icon: Icons.info_outline_rounded,
                children: [
                  _buildField(_nameCtrl, 'Product Name', Icons.label_outline),
                  const SizedBox(height: 14),
                  _buildField(
                      _descCtrl, 'Description', Icons.description_outlined,
                      maxLines: 3),
                ],
              ),
              const SizedBox(height: 16),

              // ── Image Card ──────────────────────────────────
              _sectionCard(
                title: 'Image',
                icon: Icons.image_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                            _imageCtrl, 'Image URL', Icons.link_rounded),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _loading ? null : _pickAndUploadImage,
                          icon: const Icon(Icons.upload_file),
                          color: AppColors.primaryGreen,
                          tooltip: 'Upload from Gallery',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Image preview
                  Builder(builder: (_) {
                    final url = _imageCtrl.text.trim();
                    if (url.isEmpty) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Enter URL to see preview',
                              style: TextStyle(
                                  color: AppColors.greyText, fontSize: 13)),
                        ),
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Invalid URL',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh Preview',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Pricing & Details Card ──────────────────────
              _sectionCard(
                title: 'Pricing & Details',
                icon: Icons.attach_money_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                            _priceCtrl, 'Price', Icons.attach_money,
                            isNumber: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                            _unitCtrl, 'Unit', Icons.straighten),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildField(_nutritionCtrl, 'Nutrition Weight',
                      Icons.restaurant_menu),
                  const SizedBox(height: 14),
                  // Category dropdown
                  _catsLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle:
                                const TextStyle(color: AppColors.greyText),
                            prefixIcon: const Icon(
                                Icons.category_outlined,
                                color: AppColors.greyText,
                                size: 20),
                            filled: true,
                            fillColor: AppColors.lightGrey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 1.5),
                            ),
                          ),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                    value: c['id'],
                                    child: Text(c['name']!,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkText)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategoryId = v),
                          validator: (v) =>
                              v == null ? 'Select a category' : null,
                        ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Toggles Card ────────────────────────────────
              _sectionCard(
                title: 'Visibility & Flags',
                icon: Icons.toggle_on_outlined,
                children: [
                  _buildToggle('In Stock', _inStock,
                      AppColors.primaryGreen, (v) => _inStock = v),
                  _buildToggle('Exclusive Offer', _isExclusive,
                      Colors.orange, (v) => _isExclusive = v),
                  _buildToggle('Show in Carousel', _isCarousel,
                      Colors.blue, (v) => _isCarousel = v),
                  _buildToggle('Featured Product', _isFeatured,
                      Colors.purple, (v) => _isFeatured = v),
                ],
              ),
              const SizedBox(height: 30),

              // ── Save Button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: AppColors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          _isEdit ? 'Save Changes' : 'Add Product',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle(
      String label, bool value, Color activeColor, ValueChanged<bool> setter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: value ? AppColors.darkText : AppColors.greyText)),
          Switch(
            value: value,
            activeTrackColor: activeColor,
            onChanged: (v) => setState(() => setter(v)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.greyText),
        prefixIcon: Icon(icon, color: AppColors.greyText, size: 20),
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return '$label is required';
        }
        if (isNumber && double.tryParse(val.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }
}
