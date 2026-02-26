import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/banner_service.dart';
import 'package:grocery_app/data/models/banner_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_app/core/services/cloudinary_service.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';

class AdminBannersTab extends StatefulWidget {
  const AdminBannersTab({super.key});

  @override
  State<AdminBannersTab> createState() => _AdminBannersTabState();
}

class _AdminBannersTabState extends State<AdminBannersTab> {
  final _service = BannerService.instance;

  void _showAddEditDialog({BannerModel? banner}) {
    bool _isImageUploading = false;
    final titleCtrl = TextEditingController(text: banner?.title ?? '');
    final subtitleCtrl = TextEditingController(text: banner?.subtitle ?? '');
    final imageCtrl = TextEditingController(text: banner?.imageUrl ?? '');
    final orderCtrl =
        TextEditingController(text: banner?.order.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          banner == null ? 'Add Banner' : 'Edit Banner',
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
              _dialogField(titleCtrl, 'Title', Icons.title),
              const SizedBox(height: 12),
              _dialogField(subtitleCtrl, 'Subtitle', Icons.subtitles),
              const SizedBox(height: 12),
              StatefulBuilder(builder: (ctx, setDialogState) {
                return Row(
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
                );
              }),
              const SizedBox(height: 12),
              _dialogField(orderCtrl, 'Display Order', Icons.sort,
                  isNumber: true),
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
                    final title = titleCtrl.text.trim();
                    final subtitle = subtitleCtrl.text.trim();
                    final imageUrl = imageCtrl.text.trim();
                    final order = int.tryParse(orderCtrl.text.trim()) ?? 0;

                    if (title.isEmpty || imageUrl.isEmpty) return;

                    final newBanner = BannerModel(
                      id: banner?.id ?? '',
                      title: title,
                      subtitle: subtitle,
                      imageUrl: imageUrl,
                      order: order,
                    );

                    if (banner == null) {
                      await _service.addBanner(newBanner);
                    } else {
                      if (banner.imageUrl != newBanner.imageUrl && banner.imageUrl.isNotEmpty) {
                        await CloudinaryService.instance.deleteImageByUrl(banner.imageUrl);
                      }
                      await _service.updateBanner(banner.id, newBanner.toMap());
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
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
                    banner == null ? 'Add' : 'Save',
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
      ),
    );
  }

  Widget _dialogField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder<List<BannerModel>>(
        stream: _service.getBanners(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final banners = snapshot.data!;

          if (banners.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_carousel_outlined,
                      size: 64,
                      color: AppColors.greyText.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No banners yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add banners to appear on the home carousel',
                    style: TextStyle(fontSize: 14, color: AppColors.greyText),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: banners.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _buildBannerCard(banner);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBanner',
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner) {
    return Container(
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
          // Banner image preview
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 100,
                color: AppColors.lightGrey,
                child: const Center(
                  child: Icon(Icons.broken_image,
                      color: AppColors.greyText, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.greyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order: ${banner.order}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightGreyText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primaryGreen),
                  onPressed: () => _showAddEditDialog(banner: banner),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Banner?',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        content: Text('Delete "${banner.title}"?', style: const TextStyle(fontSize: 16, color: AppColors.greyText)),
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
                      if (banner.imageUrl.isNotEmpty) {
                        await CloudinaryService.instance.deleteImageByUrl(banner.imageUrl);
                      }
                      await _service.deleteBanner(banner.id);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
