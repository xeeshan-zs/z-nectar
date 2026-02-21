import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/constants/app_constants.dart';
import 'package:grocery_app/core/widgets/green_button.dart';
import 'package:grocery_app/features/auth/auth_service.dart';

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
    _emailCtrl.text = user?.email ?? '';
    _phoneCtrl.text = user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
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
          'My Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField('Name', _nameCtrl, Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField('Email', _emailCtrl, Icons.email_outlined,
                enabled: false), // Email usually can't be easily changed without re-auth
            const SizedBox(height: 20),
            _buildTextField('Phone Number', _phoneCtrl, Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 40),
            GreenButton(
              text: 'Save Modifications',
              onPressed: () async {
                final user = AuthService.instance.currentUser;
                if (user != null) {
                  await user.updateDisplayName(_nameCtrl.text.trim());
                  await user.reload();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Details updated!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool enabled = true, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: enabled ? AppColors.darkText : AppColors.greyText,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.greyText),
        prefixIcon: Icon(icon, color: AppColors.greyText, size: 22),
        filled: true,
        fillColor: enabled ? AppColors.lightGrey : AppColors.lightGrey.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}
