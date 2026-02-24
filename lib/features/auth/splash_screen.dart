import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/features/admin/admin_dashboard_screen.dart';
import 'package:grocery_app/features/auth/login_screen.dart';
import 'package:grocery_app/features/dashboard/dashboard_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/services/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Check if already logged in and route by role
    Future.delayed(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        final role = await ref.read(userRoleServiceProvider).getRole(user.uid);
        if (!mounted) return;
        final destination = role == 'admin'
            ? const AdminDashboardScreen()
            : const DashboardScreen();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Logo & Branding ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        children: [
                          // Carrot icon in a green circle
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🥕',
                                style: TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Z-Nectar',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Online Grocery Store',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Illustration area ────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5E9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circles
                          Positioned(
                            left: -20,
                            top: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          // Emoji grocery items
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🥦', style: TextStyle(fontSize: 44)),
                                    SizedBox(width: 12),
                                    Text('🍎', style: TextStyle(fontSize: 52)),
                                    SizedBox(width: 12),
                                    Text('🥕', style: TextStyle(fontSize: 44)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🥛', style: TextStyle(fontSize: 40)),
                                    SizedBox(width: 12),
                                    Text('🍞', style: TextStyle(fontSize: 40)),
                                    SizedBox(width: 12),
                                    Text('🧀', style: TextStyle(fontSize: 40)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Tagline ──────────────────────────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: const Column(
                        children: [
                          Text(
                            'Fresh groceries,\ndelivered to your door.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Order fresh produce, dairy, bakery & more\nfrom the comfort of your home.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.greyText,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Get Started Button ───────────────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SizedBox(
                        width: double.infinity,
                        height: 67,
                        child: ElevatedButton(
                          onPressed: _onGetStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
