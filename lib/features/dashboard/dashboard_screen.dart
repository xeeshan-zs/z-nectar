import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/features/home/home_screen.dart';
import 'package:grocery_app/features/explore/explore_screen.dart';
import 'package:grocery_app/features/cart/cart_screen.dart';
import 'package:grocery_app/features/favourites/favourites_screen.dart';
import 'package:grocery_app/features/account/account_screen.dart';
import 'package:grocery_app/core/services/cart_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final Stream<int> _cartCountStream;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _cartCountStream = CartService.instance.getCartItemCount(_currentUser!.uid);
    } else {
      _cartCountStream = const Stream.empty();
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(),
    FavouritesScreen(),
    AccountScreen(),
  ];

  Widget _buildCartIcon({required bool isActive}) {
    final user = FirebaseAuth.instance.currentUser;
    final iconWidget = Icon(
      isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
    );

    if (_currentUser == null) return iconWidget;

    return StreamBuilder<int>(
      stream: _cartCountStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) return iconWidget;

        return Badge(
          label: Text(count.toString()),
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          child: iconWidget,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.darkText,
          backgroundColor: AppColors.white,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.manage_search_outlined),
              activeIcon: Icon(Icons.manage_search),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: _buildCartIcon(isActive: false),
              activeIcon: _buildCartIcon(isActive: true),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favourite',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
