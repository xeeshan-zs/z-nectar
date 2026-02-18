import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure the admin user doc exists with role = admin
  await FirebaseFirestore.instance
      .collection('users')
      .doc('h7DU0aypGVaMLMBfBQxMRHgBQIv1')
      .set({
    'email': 'xeeshan303.3.2@gmail.com',
    'role': 'admin',
    'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  runApp(const ProviderScope(child: ZNectarApp()));
}

class ZNectarApp extends StatelessWidget {
  const ZNectarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Z-Nectar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
