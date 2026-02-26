import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/category_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:grocery_app/core/services/cloudinary_service.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';

class AdminCategoriesTab extends StatefulWidget {
  const AdminCategoriesTab({super.key});

  @override
  State<AdminCategoriesTab> createState() => _AdminCategoriesTabState();
}

class _AdminCategoriesTabState extends State<AdminCategoriesTab> {
  final _service = CategoryService.instance;

  // Cache product counts per category
  Map<String, int> _productCounts = {};
  bool _countsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProductCounts();
  }

  Future<void> _loadProductCounts() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .get();
      final counts = <String, int>{};
      for (final doc in snap.docs) {
        final catId = (doc.data()['categoryId'] as String?) ?? '';
        counts[catId] = (counts[catId] ?? 0) + 1;
      }
      if (mounted) {
        setState(() {
          _productCounts = counts;
          _countsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _countsLoaded = true);
    }
  }

  Color _parseColor(String colorStr, Color fallback) {
    try {
      final str = colorStr.trim().toLowerCase();
      
      // Handle RGB formatting: rgb(238, 247, 241)
      if (str.startsWith('rgb(') && str.endsWith(')')) {
        final content = str.substring(4, str.length - 1);
        final parts = content.split(',').map((e) => e.trim()).toList();
        if (parts.length == 3) {
          return Color.fromRGBO(
            int.parse(parts[0]), 
            int.parse(parts[1]), 
            int.parse(parts[2]), 
            1.0
          );
        }
      }
      
      // Handle HSL formatting: hsl(140, 36%, 95%)
      if (str.startsWith('hsl(') && str.endsWith(')')) {
        final content = str.substring(4, str.length - 1);
        final parts = content.split(',').map((e) => e.trim()).toList();
        if (parts.length == 3) {
          final h = double.parse(parts[0]);
          final s = double.parse(parts[1].replaceAll('%', '')) / 100.0;
          final l = double.parse(parts[2].replaceAll('%', '')) / 100.0;
          return HSLColor.fromAHSL(1.0, h, s, l).toColor();
        }
      }

      // Handle HEX formatting
      final cleaned = str.replaceAll('#', '');
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  void _showAddEditDialog({String? id, Map<String, dynamic>? data}) {
    bool _isImageUploading = false;
    final nameCtrl = TextEditingController(text: data?['name'] ?? '');
    final imageCtrl = TextEditingController(text: data?['imageUrl'] ?? '');
    final bgColorCtrl =
        TextEditingController(text: data?['bgColor'] ?? '#F3F5E9');
    final borderColorCtrl =
        TextEditingController(text: data?['borderColor'] ?? '#E2E7D5');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final bgPreview = _parseColor(bgColorCtrl.text, const Color(0xFFF3F5E9));
          final borderPreview =
              _parseColor(borderColorCtrl.text, const Color(0xFFE2E7D5));

          return AlertDialog(
            backgroundColor: AppColors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              id == null ? 'Add Category' : 'Edit Category',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl, 'Name', Icons.label_outline),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField(imageCtrl, 'Image URL', Icons.image_outlined),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _isImageUploading ? null : () async {
                              setDialogState(() => _isImageUploading = true);
                              final url = await CloudinaryService.instance.pickAndUploadImage();
                              if (url != null) {
                                setDialogState(() => imageCtrl.text = url);
                                if (ctx.mounted) SnackbarService.showSuccess(ctx, 'Image uploaded!');
                              } else {
                                if (ctx.mounted) SnackbarService.showError(ctx, 'Upload failed/canceled');
                              }
                              setDialogState(() => _isImageUploading = false);
                          },
                          icon: _isImageUploading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                : const Icon(Icons.upload_file),
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // BG Color Picker
                  _colorPickerRow(
                    'Background Color',
                    bgPreview,
                    bgColorCtrl,
                    setDialogState,
                  ),
                  const SizedBox(height: 12),
                  // Border Color Picker
                  _colorPickerRow(
                    'Border Color',
                    borderPreview,
                    borderColorCtrl,
                    setDialogState,
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.borderGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final imageUrl = imageCtrl.text.trim();
                        if (name.isEmpty) return;

                        if (id == null) {
                          await _service.addCategory(
                            name: name,
                            imageUrl: imageUrl,
                            bgColor: bgColorCtrl.text.trim(),
                            borderColor: borderColorCtrl.text.trim(),
                          );
                        } else {
                          final oldImageUrl = data?['imageUrl'] as String? ?? '';
                          if (oldImageUrl != imageUrl && oldImageUrl.isNotEmpty) {
                            await CloudinaryService.instance.deleteImageByUrl(oldImageUrl);
                          }
                          await _service.updateCategory(id, {
                            'name': name,
                            'imageUrl': imageUrl,
                            'bgColor': bgColorCtrl.text.trim(),
                            'borderColor': borderColorCtrl.text.trim(),
                          });
                        }
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        _loadProductCounts(); // Refresh counts
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        id == null ? 'Add' : 'Save',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
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
    );
  }

  Widget _colorPickerRow(
    String label,
    Color currentColor,
    TextEditingController controller,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                decoration: InputDecoration(
                  hintText: 'HEX, rgb(), or hsl()',
                  hintStyle: TextStyle(
                    color: AppColors.greyText.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryGreen, width: 1.5),
                  ),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: currentColor,
                        onColorChanged: (c) {
                          setDialogState(() {
                            controller.text =
                                '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                          });
                        },
                        portraitOnly: true,
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Done',
                            style: TextStyle(color: AppColors.primaryGreen)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGrey, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addCategory',
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined,
                      size: 64,
                      color: AppColors.greyText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No categories yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add your first category',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.greyText),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Count badge
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${docs.length} categor${docs.length == 1 ? 'y' : 'ies'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildCategoryCard(doc.id, data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(String id, Map<String, dynamic> data) {
    final name = data['name'] as String? ?? '';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final bgColor = _parseColor(
        data['bgColor'] as String? ?? '#F3F5E9', const Color(0xFFF3F5E9));
    final borderColor = _parseColor(
        data['borderColor'] as String? ?? '#E2E7D5',
        const Color(0xFFE2E7D5));
    final productCount = _productCounts[id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Category color preview
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.category, color: AppColors.greyText),
                    ),
                  )
                : const Icon(Icons.category, color: AppColors.greyText),
          ),
          const SizedBox(width: 14),
          // Name + product count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _countsLoaded
                            ? '$productCount product${productCount == 1 ? '' : 's'}'
                            : '...',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Color preview dots
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderGrey, width: 1),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderGrey, width: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.primaryGreen, size: 20),
            onPressed: () => _showAddEditDialog(id: id, data: data),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Delete Category?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  content: Text('Delete "$name"? This cannot be undone.', style: const TextStyle(fontSize: 16, color: AppColors.greyText)),
                  actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.borderGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF35B5B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                if (imageUrl.isNotEmpty) {
                  await CloudinaryService.instance.deleteImageByUrl(imageUrl);
                }
                await _service.deleteCategory(id);
                _loadProductCounts();
              }
            },
          ),
        ],
      ),
    );
  }
}
