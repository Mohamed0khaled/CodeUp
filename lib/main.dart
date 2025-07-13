import 'package:codeup/routes.dart';
import 'package:codeup/services/firebaseOption.dart';
import 'package:codeup/services/user_service.dart';
import 'package:codeup/services/tournament_service.dart';
import 'package:codeup/controllers/auth/authController.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'dart:async';


void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };
  
  // Handle async errors
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize GetX services
    await _initializeServices();
    
    runApp(AppConfig.getApp());
  }, (error, stack) {
    debugPrint('Zone Error: $error');
    debugPrint('Stack trace: $stack');
  });
}

/// Initialize all GetX services
Future<void> _initializeServices() async {
  // Initialize User Service first
  Get.put<UserService>(UserService(), permanent: true);
  
  // Initialize Tournament Service
  Get.put<TournamentService>(TournamentService(), permanent: true);
  
  // Initialize Auth Controller after UserService
  Get.put<AuthController>(AuthController(), permanent: true);
}