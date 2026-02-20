import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/features/auth/auth_service.dart';
import 'package:grocery_app/features/auth/otp_screen.dart';

enum ContactMethod { email, phone }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();
  ContactMethod _method = ContactMethod.email;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_method == ContactMethod.email) {
        final email = _contactCtrl.text.trim();
        final otp = AuthService.instance.sendEmailOtp(email);
        if (!mounted) return;
        // In dev mode, show the OTP in a snackbar so you can test it
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dev: Your OTP is $otp'),
            duration: const Duration(seconds: 8),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              contactValue: email,
              method: _method,
            ),
          ),
        );
      } else {
        // Phone OTP via Firebase
        String phone = _contactCtrl.text.trim();
        if (!phone.startsWith('+')) phone = '+92$phone'; // default country code
        await AuthService.instance.sendPhoneOtp(
          phoneNumber: phone,
          onError: (err) {
            setState(() => _errorMessage = err);
          },
          onCodeSent: () {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  contactValue: phone,
                  method: _method,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to send OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Carrot Logo ───────────────────────────────────────
                Center(
                  child: Image.network(
                    'https://img.icons8.com/emoji/96/carrot-emoji.png',
                    width: 50,
                    height: 50,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.eco,
                      color: AppColors.primaryGreen,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Header ────────────────────────────────────────────────
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email or phone number',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Toggle Email / Phone ──────────────────────────────────
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildToggleTab('Email', ContactMethod.email),
                      _buildToggleTab('Phone', ContactMethod.phone),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Input Field ───────────────────────────────────────────
                Text(
                  _method == ContactMethod.email ? 'Email Address' : 'Phone Number',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactCtrl,
                  keyboardType: _method == ContactMethod.email
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                  decoration: InputDecoration(
                    hintText: _method == ContactMethod.email
                        ? 'example@email.com'
                        : '03XX XXXXXXX',
                    hintStyle: const TextStyle(
                      color: AppColors.lightGreyText,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      _method == ContactMethod.email
                          ? Icons.email_outlined
                          : Icons.phone_outlined,
                      color: AppColors.greyText,
                      size: 20,
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderGrey, width: 1),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderGrey, width: 1),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return _method == ContactMethod.email
                          ? 'Email is required'
                          : 'Phone number is required';
                    }
                    if (_method == ContactMethod.email && !v.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    if (_method == ContactMethod.phone && v.trim().length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Info note ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _method == ContactMethod.email
                              ? 'We\'ll send a 6-digit OTP to your email.'
                              : 'We\'ll send a 6-digit OTP via SMS.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── Error ─────────────────────────────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Send OTP Button ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 67,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // ── Already have account ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab(String label, ContactMethod method) {
    final isSelected = _method == method;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _method = method;
            _contactCtrl.clear();
            _errorMessage = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryGreen : AppColors.greyText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
