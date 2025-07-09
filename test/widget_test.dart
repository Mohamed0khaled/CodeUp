import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:codeup/routes.dart';

// Mock Firebase for testing
void setupFirebaseAuthMocks() {
  // You can add Firebase mocking here if needed
}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
  });

  testWidgets('App loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(AppConfig.getApp());
    
    // Verify that splash screen loads
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // You can add more specific tests for your splash screen here
    await tester.pumpAndSettle();
  });
  
  group('Route Navigation Tests', () {
    testWidgets('Initial route should be splash', (WidgetTester tester) async {
      await tester.pumpWidget(AppConfig.getApp());
      
      // Check if initial route is correct
      expect(Get.currentRoute, equals('/splash'));
    });
  });
}
