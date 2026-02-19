import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/data/models/product_model.dart';

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
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _nutritionCtrl;
  late bool _inStock;
  late bool _isExclusive;
  late bool _isCarousel;
  late bool _isFeatured;
  bool _loading = false;

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
    _categoryCtrl = TextEditingController(text: p?.categoryId ?? '');
    _nutritionCtrl =
        TextEditingController(text: p?.nutritionWeight ?? '100gr');
    _inStock = p?.inStock ?? true;
    _isExclusive = p?.isExclusive ?? false;
    _isCarousel = p?.isCarousel ?? false;
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    _nutritionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      unit: _unitCtrl.text.trim(),
      categoryId: _categoryCtrl.text.trim(),
      nutritionWeight: _nutritionCtrl.text.trim(),
      inStock: _inStock,
      isExclusive: _isExclusive,
      isCarousel: _isCarousel,
      isFeatured: _isFeatured,
      salesCount: widget.product?.salesCount ?? 0,
    );

    try {
      if (_isEdit) {
        await ProductService.instance
            .updateProduct(product.id, product.toMap());
      } else {
        await ProductService.instance.addProduct(product);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
            children: [
              _buildField(_nameCtrl, 'Product Name', Icons.label_outline),
              const SizedBox(height: 16),
              _buildField(
                  _descCtrl, 'Description', Icons.description_outlined,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildField(
                  _imageCtrl, 'Image URL', Icons.image_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                        _priceCtrl, 'Price', Icons.attach_money,
                        isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        _buildField(_unitCtrl, 'Unit', Icons.straighten),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_categoryCtrl, 'Category ID',
                  Icons.category_outlined),
              const SizedBox(height: 16),
              _buildField(_nutritionCtrl, 'Nutrition Weight',
                  Icons.restaurant_menu),
              const SizedBox(height: 16),
              // In Stock Toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('In Stock',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText)),
                    Switch(
                      value: _inStock,
                      activeTrackColor: AppColors.primaryGreen,
                      onChanged: (v) => setState(() => _inStock = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Exclusive Offer Toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exclusive Offer',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText)),
                    Switch(
                      value: _isExclusive,
                      activeTrackColor: Colors.orange,
                      onChanged: (v) => setState(() => _isExclusive = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Show in Carousel Toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Show in Carousel',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText)),
                    Switch(
                      value: _isCarousel,
                      activeTrackColor: Colors.blue,
                      onChanged: (v) => setState(() => _isCarousel = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Featured Product Toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Featured Product',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText)),
                    Switch(
                      value: _isFeatured,
                      activeTrackColor: Colors.purple,
                      onChanged: (v) => setState(() => _isFeatured = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Save Button
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
            ],
          ),
        ),
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
