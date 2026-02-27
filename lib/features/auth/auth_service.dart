import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Phone Auth ───────────────────────────────────────────────────────────

  String? _verificationId;

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String error) onError,
    required void Function() onCodeSent,
  }) async {
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.windows) {
      // Bypass for Windows development
      _verificationId = 'windows-dummy-verification-id';
      onCodeSent();
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval on Android
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential?> verifyPhoneOtp(String otp) async {
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.windows) {
      // Simulate login on Windows (e.g., Anonymous) to get a valid User
      return await _auth.signInAnonymously();
    }

    if (_verificationId == null) return null;
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ─── Email OTP (simulated) ────────────────────────────────────────────────

  String? _emailOtp;
  String? _pendingEmail;

  /// Generates a 6-digit OTP and stores it in memory.
  /// In production, send this via your backend / email service.
  String sendEmailOtp(String email) {
    _pendingEmail = email;
    _emailOtp = (100000 + Random().nextInt(900000)).toString();
    // TODO: integrate a real email-sending service here
    return _emailOtp!; // returned so the caller can display it during dev
  }

  bool verifyEmailOtp(String otp) {
    return _emailOtp != null && otp == _emailOtp;
  }

  // ─── Account Creation ─────────────────────────────────────────────────────

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  String? get pendingEmail => _pendingEmail;

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        return await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─── Facebook Sign-In ─────────────────────────────────────────────────────

  Future<UserCredential?> signInWithFacebook() async {
    try {
      if (kIsWeb) {
        final provider = FacebookAuthProvider();
        return await _auth.signInWithPopup(provider);
      }
      // On mobile, a proper Facebook SDK integration is needed.
      // For now, surface a clear error on non-web.
      throw UnsupportedError('Facebook login on mobile requires the facebook_auth package.');
    } catch (e) {
      rethrow;
    }
  }
}
