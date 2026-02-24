import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/features/auth/create_password_screen.dart';
import 'package:grocery_app/features/auth/signup_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/services/providers.dart';
import 'package:grocery_app/core/utils/snackbar_service.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String contactValue;
  final ContactMethod method;

  const OtpScreen({
    super.key,
    required this.contactValue,
    required this.method,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

  // Resend countdown
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _timer?.cancel();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < _otpLength) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.method == ContactMethod.email) {
        final valid = ref.read(authServiceProvider).verifyEmailOtp(_otp);
        if (!valid) {
          setState(() => _errorMessage = 'Incorrect OTP. Please try again.');
          return;
        }
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreatePasswordScreen(
              email: widget.contactValue,
            ),
          ),
        );
      } else {
        // Phone OTP via Firebase
        final credential = await ref.read(authServiceProvider).verifyPhoneOtp(_otp);
        if (credential == null) {
          setState(() => _errorMessage = 'Verification failed. Try again.');
          return;
        }
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreatePasswordScreen(
              email: widget.contactValue,
              isPhone: true,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Invalid OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendOtp() {
    if (_secondsLeft > 0) return;
    if (widget.method == ContactMethod.email) {
      final otp = ref.read(authServiceProvider).sendEmailOtp(widget.contactValue);
      SnackbarService.showSuccess(context, 'Dev: New OTP is $otp');
    }
    _startCountdown();
    setState(() => _errorMessage = null);
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final maskedContact = _maskContact(widget.contactValue);

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── Header ────────────────────────────────────────────────
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: maskedContact,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── OTP Boxes ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) => _buildOtpBox(i)),
              ),

              const SizedBox(height: 20),

              // ── Error ─────────────────────────────────────────────────
              if (_errorMessage != null)
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

              const SizedBox(height: 30),

              // ── Verify Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 67,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
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
                          'Verify',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Resend ────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _resendOtp,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14),
                      children: [
                        const TextSpan(
                          text: "Didn't receive the code? ",
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: _secondsLeft > 0
                              ? 'Resend in ${_secondsLeft}s'
                              : 'Resend',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _secondsLeft > 0
                                ? AppColors.greyText
                                : AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.lightGrey,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
          onChanged: (val) {
            if (val.isNotEmpty && index < _otpLength - 1) {
              _focusNodes[index + 1].requestFocus();
            } else if (val.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            setState(() => _errorMessage = null);
          },
        ),
      ),
    );
  }

  String _maskContact(String contact) {
    if (contact.contains('@')) {
      final parts = contact.split('@');
      final name = parts[0];
      final masked = name.length > 3
          ? '${name.substring(0, 3)}***@${parts[1]}'
          : '***@${parts[1]}';
      return masked;
    }
    // Phone
    if (contact.length > 6) {
      return '${contact.substring(0, 4)}****${contact.substring(contact.length - 3)}';
    }
    return contact;
  }
}
