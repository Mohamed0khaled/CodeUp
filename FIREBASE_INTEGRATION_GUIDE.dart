/// 🚀 Firebase Integration Guide for CodeUp App
/// 
/// This guide shows how to use the comprehensive Firebase services
/// throughout your application.

// ====================================================================
// SETUP INSTRUCTIONS
// ====================================================================

/*
1. Add these dependencies to your pubspec.yaml:

dependencies:
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0
  firebase_core: ^2.24.2
  get: ^4.6.6
  logger: ^2.0.2+1

2. The services are automatically initialized in main.dart

3. Use UserService throughout your app like this:
*/

import 'package:codeup/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ====================================================================
// USAGE EXAMPLES
// ====================================================================

class ExampleUsage {
  final UserService _userService = UserService.to;

  /// Example: Initialize new user after registration
  Future<void> handleNewUserRegistration(String email, String username) async {
    final success = await _userService.initializeNewUser(
      email: email,
      username: username,
      displayName: username,
    );
    
    if (success) {
      print('✅ New user initialized successfully');
      // Navigate to dashboard or profile setup
      Get.offAllNamed('/dashboard');
    } else {
      print('❌ Failed to initialize new user');
    }
  }

  /// Example: Update user profile
  Future<void> updateUserProfile() async {
    final success = await _userService.updateProfile(
      username: 'newUsername',
      displayName: 'New Display Name',
      firstName: 'John',
      lastName: 'Doe',
    );
    
    if (success) {
      Get.snackbar('Success', 'Profile updated successfully');
    }
  }

  /// Example: Update app settings
  Future<void> updateAppSettings() async {
    // Update notification settings
    await _userService.updateNotificationSettings(
      enabled: true,
      pushNotifications: true,
      soundNotifications: false,
    );
    
    // Update app preferences
    await _userService.updatePreferences(
      language: 'Spanish',
      theme: 'dark',
      soundEffects: true,
    );
    
    // Update privacy settings
    await _userService.updatePrivacySettings(
      profileVisibility: 'friends',
      showOnlineStatus: false,
    );
  }

  /// Example: Add user activity
  Future<void> logUserActivity() async {
    await _userService.addActivity(
      type: 'challenge_completed',
      data: {
        'challengeId': 'challenge_123',
        'xpEarned': 150,
        'timeTaken': 300, // seconds
        'difficulty': 'medium',
      },
    );
  }

  /// Example: Add achievement
  Future<void> grantAchievement() async {
    await _userService.addAchievement(
      id: 'first_challenge',
      name: 'First Steps',
      description: 'Complete your first challenge',
      xpReward: 100,
    );
  }

  /// Example: Social features
  Future<void> handleSocialActions() async {
    // Add a friend
    await _userService.addFriend(
      friendUid: 'friend_uid_123',
      friendUsername: 'FriendName',
    );
    
    // Search for users
    final users = await _userService.searchUsers(
      query: 'john',
      limit: 10,
    );
    
    for (final user in users) {
      print('Found user: ${user.username} (${user.email})');
    }
  }

  /// Example: Support features
  Future<void> handleSupport() async {
    // Create support ticket
    final ticketId = await _userService.createSupportTicket(
      subject: 'App Issue',
      message: 'I am experiencing problems with...',
    );
    
    if (ticketId != null) {
      print('Support ticket created: $ticketId');
    }
    
    // Submit bug report
    final bugId = await _userService.submitBugReport(
      description: 'App crashes when I try to...',
      severity: 'high',
      deviceInfo: {
        'platform': 'iOS',
        'version': '14.5',
        'deviceModel': 'iPhone 12',
      },
    );
    
    if (bugId != null) {
      print('Bug report submitted: $bugId');
    }
  }

  /// Example: Create backup
  Future<void> createDataBackup() async {
    final success = await _userService.createBackup();
    if (success) {
      Get.snackbar('Success', 'Backup created successfully');
    }
  }
}

// ====================================================================
// WIDGET EXAMPLES
// ====================================================================

/// Example: Reactive UI using GetX
class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<UserService>(
      builder: (userService) {
        if (userService.isLoading) {
          return const CircularProgressIndicator();
        }
        
        if (!userService.isAuthenticated) {
          return const Text('Please sign in');
        }
        
        return Column(
          children: [
            Text('Welcome, ${userService.displayName}!'),
            Text('Level: ${userService.userLevel}'),
            Text('XP: ${userService.xpPoints}'),
            Text('Friends: ${userService.friendsCount}'),
            Text('Achievements: ${userService.achievements.length}'),
            if (userService.isPremium)                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PRO'),
                ),
          ],
        );
      },
    );
  }
}

/// Example: Settings screen using reactive data
class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<UserService>(
      builder: (service) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text('Notifications'),
              value: service.notificationsEnabled,
              onChanged: (value) {
                service.updateNotificationSettings(enabled: value);
              },
            ),
            SwitchListTile(
              title: const Text('Sound Effects'),
              value: service.soundEffectsEnabled,
              onChanged: (value) {
                service.updatePreferences(soundEffects: value);
              },
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: Text(service.language),
              onTap: () => _showLanguageSelector(service),
            ),
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(service.theme),
              onTap: () => _showThemeSelector(service),
            ),
          ],
        );
      },
    );
  }
  
  void _showLanguageSelector(UserService service) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Japanese'];
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            title: Text(lang),
            onTap: () {
              service.updatePreferences(language: lang);
              Get.back();
            },
          )).toList(),
        ),
      ),
    );
  }
  
  void _showThemeSelector(UserService service) {
    final themes = ['light', 'dark', 'auto'];
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) => ListTile(
            title: Text(theme.toUpperCase()),
            onTap: () {
              service.updatePreferences(theme: theme);
              Get.back();
            },
          )).toList(),
        ),
      ),
    );
  }
}

/// Example: Activity feed widget
class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<UserService>(
      builder: (userService) {
        final activities = userService.recentActivities;
        
        if (activities.isEmpty) {
          return const Center(
            child: Text('No recent activities'),
          );
        }
        
        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              leading: _getActivityIcon(activity['type']),
              title: Text(_getActivityTitle(activity)),
              subtitle: Text(_getActivityTime(activity['timestamp'])),
              trailing: activity['xpEarned'] != null
                  ? Text('+${activity['xpEarned']} XP')
                  : null,
            );
          },
        );
      },
    );
  }
  
  Icon _getActivityIcon(String type) {
    switch (type) {
      case 'challenge_completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'friend_added':
        return const Icon(Icons.person_add, color: Colors.blue);
      case 'achievement_earned':
        return const Icon(Icons.star, color: Colors.amber);
      default:
        return const Icon(Icons.info);
    }
  }
  
  String _getActivityTitle(Map<String, dynamic> activity) {
    switch (activity['type']) {
      case 'challenge_completed':
        return 'Completed challenge';
      case 'friend_added':
        return 'Added new friend';
      case 'achievement_earned':
        return 'Earned achievement: ${activity['name']}';
      default:
        return 'Activity';
    }
  }
  
  String _getActivityTime(dynamic timestamp) {
    // Convert Firestore timestamp to readable time
    // Implementation depends on your timestamp format
    return 'Recently';
  }
}

// ====================================================================
// CONTROLLER INTEGRATION EXAMPLES
// ====================================================================

/// Example: Integrating with your existing controllers
class SettingsControllerIntegration extends GetxController {
  final UserService _userService = UserService.to;
  
  // Use reactive data from UserService instead of local state
  bool get notificationsEnabled => _userService.notificationsEnabled;
  bool get soundEffectsEnabled => _userService.soundEffectsEnabled;
  String get selectedLanguage => _userService.language;
  String get userName => _userService.displayName;
  String get userId => _userService.currentUserId ?? '';
  String get userLevel => _userService.userLevel;
  bool get isPremiumUser => _userService.isPremium;
  bool get isVerified => _userService.isVerified;
  bool get twoFactorEnabled => _userService.twoFactorEnabled;
  
  // Update methods that use UserService
  Future<void> toggleNotifications(bool value) async {
    await _userService.updateNotificationSettings(enabled: value);
  }
  
  Future<void> toggleSoundEffects(bool value) async {
    await _userService.updatePreferences(soundEffects: value);
  }
  
  Future<void> changeLanguage(String language) async {
    await _userService.updatePreferences(language: language);
  }
  
  Future<bool> toggleTwoFactorAuth(bool enable) async {
    return await _userService.updateSecuritySettings(twoFactorEnabled: enable);
  }
  
  Future<void> logout() async {
    // Sign out from Firebase Auth (handled by AuthController)
    // Reset UserService state
    _userService.resetService();
  }
  
  Future<bool> deleteAccount(String password) async {
    // Delete all user data
    final success = await _userService.deleteAllUserData();
    if (success) {
      _userService.resetService();
    }
    return success;
  }
}

// ====================================================================
// BEST PRACTICES
// ====================================================================

/*
✅ DO's:
1. Always check if user is authenticated before calling UserService methods
2. Use GetX reactive patterns (GetX<UserService>) for real-time UI updates
3. Handle errors gracefully and show user-friendly messages
4. Use the convenience getters for common data access
5. Call updateLastActive() when user performs actions
6. Create backups periodically for important user data

❌ DON'Ts:
1. Don't call Firebase methods directly - use UserService instead
2. Don't store sensitive data in local state - rely on Firestore
3. Don't forget to handle offline scenarios
4. Don't ignore error handling in async operations
5. Don't make too many simultaneous Firebase calls

🔧 Performance Tips:
1. Use streams for real-time data that changes frequently
2. Cache frequently accessed data locally using GetX reactive variables
3. Implement pagination for large datasets
4. Use batch operations for multiple related updates
5. Consider using Firestore offline persistence for better UX

🔐 Security Notes:
1. Implement proper Firestore security rules
2. Validate all user inputs before saving
3. Never trust client-side data for critical operations
4. Use Firebase Auth for authentication, not custom solutions
5. Regularly audit user permissions and data access
*/
