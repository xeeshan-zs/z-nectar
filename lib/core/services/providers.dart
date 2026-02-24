import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/auth_service.dart';
import 'user_role_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  // We can still return the singleton instance, but accessing it via Riverpod
  // allows us to easily mock it in tests.
  return AuthService.instance;
});

/// StreamProvider to listen to Firebase Auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for UserRoleService
final userRoleServiceProvider = Provider<UserRoleService>((ref) {
  return UserRoleService.instance;
});
