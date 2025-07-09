import 'package:codeup/controllers/auth/authErrorHandler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:codeup/services/user_service.dart';

/// Custom Auth Exception
class AuthException implements Exception {
  final String code;
  final String message;
  final DateTime timestamp;

  AuthException(this.code, this.message) : timestamp = DateTime.now();

  @override
  String toString() => 'AuthException($code): $message';
}

/// Auth Result wrapper
class AuthResult {
  final User? user;
  final bool isNewUser;
  final String? additionalInfo;

  AuthResult({this.user, this.isNewUser = false, this.additionalInfo});
}

/// Auth Controller (Authentication Only)
class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  
  /// Get UserService lazily to avoid initialization issues
  UserService get userService => Get.find<UserService>();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Email/Password Sign In
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Check if user exists
      final userExists = await userService.checkUserExists(email: email);
      if (!userExists) {
        AuthErrorHandler.showError(context, 'user-not-found', 'User not found. Please sign up first.');
        return AuthResult(additionalInfo: 'user-not-found');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      AuthErrorHandler.showSuccess(context, 'Welcome back!');
      return AuthResult(user: credential.user);
    } on FirebaseAuthException catch (e) {
      _logError('signInWithEmailPassword', e);
      AuthErrorHandler.showError(context, e.code, e.message ?? 'Sign in failed');
      return AuthResult(additionalInfo: e.code);
    } catch (e) {
      _logError('signInWithEmailPassword', e);
      AuthErrorHandler.showError(context, 'unknown', 'An error occurred');
      return AuthResult(additionalInfo: 'unknown');
    }
  }

  /// Email/Password Sign Up
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Check if user already exists in Firestore
      final userExists = await userService.checkUserExists(email: email.trim());
      if (userExists) {
        AuthErrorHandler.showError(context, 'email-already-in-use', 'An account with this email already exists. Please sign in instead.');
        return AuthResult(additionalInfo: 'email-already-in-use');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Initialize new user in Firestore
      if (credential.user != null) {
        await userService.initializeNewUser(
          email: credential.user!.email!,
          displayName: credential.user!.displayName, // Will be null for email/password signup
        );
      }

      AuthErrorHandler.showSuccess(context, 'Account created successfully!');
      return AuthResult(user: credential.user, isNewUser: true);
    } on FirebaseAuthException catch (e) {
      _logError('signUpWithEmailPassword', e);
      AuthErrorHandler.showError(context, e.code, e.message ?? 'Sign up failed');
      return AuthResult(additionalInfo: e.code);
    } catch (e) {
      _logError('signUpWithEmailPassword', e);
      AuthErrorHandler.showError(context, 'unknown', 'An error occurred');
      return AuthResult(additionalInfo: 'unknown');
    }
  }

  /// Google Sign In
  Future<AuthResult> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(additionalInfo: 'sign-in-cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists
      final email = userCredential.user?.email;
      if (email != null && !(await userService.checkUserExists(email: email))) {
        // Initialize new user
        await userService.initializeNewUser(
          email: email,
          displayName: googleUser.displayName,
        );
        AuthErrorHandler.showSuccess(context, 'Account created via Google!');
        return AuthResult(user: userCredential.user, isNewUser: true);
      }

      AuthErrorHandler.showSuccess(context, 'Google sign in successful!');
      return AuthResult(
        user: userCredential.user,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      _logError('signInWithGoogle', e);
      AuthErrorHandler.showError(context, e.code, 'Google sign in failed');
      return AuthResult(additionalInfo: e.code);
    } catch (e) {
      _logError('signInWithGoogle', e);
      AuthErrorHandler.showError(context, 'google-error', 'Google sign in failed');
      return AuthResult(additionalInfo: 'google-error');
    }
  }

  /// GitHub Sign In
  Future<AuthResult> signInWithGitHub({required BuildContext context}) async {
    try {
      final githubProvider = GithubAuthProvider()
        ..addScope('user:email')
        ..addScope('read:user');

      final userCredential = kIsWeb
          ? await _auth.signInWithPopup(githubProvider)
          : await _auth.signInWithProvider(githubProvider);

      // Check if user exists
      final email = userCredential.user?.email;
      if (email != null && !(await userService.checkUserExists(email: email))) {
        // Initialize new user
        await userService.initializeNewUser(
          email: email,
          displayName: userCredential.user?.displayName,
        );
        AuthErrorHandler.showSuccess(context, 'Account created via GitHub!');
        return AuthResult(user: userCredential.user, isNewUser: true);
      }

      AuthErrorHandler.showSuccess(context, 'GitHub sign in successful!');
      return AuthResult(
        user: userCredential.user,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      _logError('signInWithGitHub', e);
      AuthErrorHandler.showError(context, e.code, 'GitHub sign in failed');
      return AuthResult(additionalInfo: e.code);
    } catch (e) {
      _logError('signInWithGitHub', e);
      AuthErrorHandler.showError(context, 'github-error', 'GitHub sign in failed');
      return AuthResult(additionalInfo: 'github-error');
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AuthErrorHandler.showSuccess(context, 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _logError('sendPasswordResetEmail', e);
      AuthErrorHandler.showError(context, e.code, e.message ?? 'Failed to send reset email');
    }
  }

  /// Sign Out
  Future<void> signOut({BuildContext? context}) async {
    try {
      // Sign out from Google if available (best effort)
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore Google sign-out errors as they're not critical
        _logger.w('Google sign-out failed: $e');
      }
      
      // Sign out from Firebase
      await _auth.signOut();
      
      if (context != null) {
        AuthErrorHandler.showSuccess(context, 'Signed out successfully');
      }
    } catch (e) {
      _logError('signOut', e);
      if (context != null) {
        AuthErrorHandler.showError(context, 'sign-out-error', 'Failed to sign out');
      }
    }
  }

  /// Delete Account
  Future<void> deleteAccount({required BuildContext context}) async {
    final user = _auth.currentUser;
    if (user == null) {
      AuthErrorHandler.showError(context, 'no-user', 'No user signed in');
      return;
    }

    try {
      await user.delete();
      AuthErrorHandler.showSuccess(context, 'Account deleted');
    } on FirebaseAuthException catch (e) {
      _logError('deleteAccount', e);
      AuthErrorHandler.showError(context, e.code, e.message ?? 'Failed to delete account');
    }
  }

  /// Error logging
  void _logError(String method, Object error) {
    _logger.e('AuthController.$method', error: error, stackTrace: StackTrace.current);
  }
}