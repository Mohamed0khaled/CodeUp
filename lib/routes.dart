import 'package:codeup/controllers/auth/authController.dart';
import 'package:codeup/screens/auth/login.dart';
import 'package:codeup/screens/dashboard/dashboard.dart';
import 'package:codeup/screens/splash/splash.dart';
import 'package:codeup/services/firebaseOption.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String home = '/home'; // For future use

  // Initial route
  static const String initial = splash;

  // Route pages
  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const DashBoard(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}

// Controllers for each screen
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeFirebaseAndNavigate();
  }

  /// Initialize Firebase and handle user authentication routing
  void _initializeFirebaseAndNavigate() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Wait for splash animations to complete (minimum 2 seconds for branding)
      await Future.delayed(const Duration(seconds: 2));

      // Check if user is currently signed in
      await _checkUserAuthenticationStatus();

    } catch (e) {
      // Handle Firebase initialization error
      debugPrint('Firebase initialization error: $e');
      // Still navigate to login even if Firebase fails
      await Future.delayed(const Duration(seconds: 2));
      Get.offNamed(AppRoutes.login);
    }
  }

  /// Check current user authentication status and navigate accordingly
  Future<void> _checkUserAuthenticationStatus() async {
    try {
      // Get current user from Firebase Auth
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // User is signed in - check if email is verified (optional security check)
        if (currentUser.emailVerified || currentUser.providerData.isNotEmpty) {
          // Navigate to dashboard for authenticated users
          Get.offNamed(AppRoutes.dashboard);
        } else {
          // User exists but email not verified - could implement email verification flow
          // For now, redirect to login for re-authentication
          Get.offNamed(AppRoutes.login);
        }
      } else {
        // No user signed in - navigate to login
        Get.offNamed(AppRoutes.login);
      }
    } catch (e) {
      // Handle authentication check error
      debugPrint('Authentication check error: $e');
      // Default to login screen on error
      Get.offNamed(AppRoutes.login);
    }
  }
}

// Bindings for dependency injection
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

// Route helper class for easier navigation
class RouteHelper {
  /// Navigate to splash screen
  static void goToSplash() {
    Get.toNamed(AppRoutes.splash);
  }

  /// Navigate to login screen
  static void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  /// Navigate to dashboard screen
  static void goToDashboard() {
    Get.toNamed(AppRoutes.dashboard);
  }

  /// Navigate to login and clear entire navigation stack
  static void goToLoginAndClearStack() {
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navigate to dashboard and clear entire navigation stack
  static void goToDashboardAndClearStack() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  /// Go back to previous screen
  static void goBack() {
    Get.back();
  }

  /// Check if navigation can go back
  static bool canGoBack() {
    return Get.key.currentState?.canPop() ?? false;
  }

  /// Sign out user and navigate to login
  static void signOutAndGoToLogin() {
    // Clear any cached user data
    Get.offAllNamed(AppRoutes.login);
  }
}

// App configuration for main.dart
class AppConfig {
  static GetMaterialApp getApp() {
    return GetMaterialApp(
      title: 'DevSpace',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Add your preferred font
      ),
      // Global error handling
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(
            child: Text('Page Not Found', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}

// Alternative: Firebase initialization helper class
class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      rethrow;
    }
  }
}

