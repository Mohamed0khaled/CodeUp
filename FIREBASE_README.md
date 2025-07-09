# 🔥 Firebase Integration Documentation

## Overview

This document provides comprehensive information about the Firebase integration in the CodeUp app, including the data structure, services, and usage patterns.

## 📁 File Structure

```
lib/
├── models/
│   └── fireStore.dart           # Core Firestore service with all CRUD operations
├── services/
│   └── user_service.dart        # High-level user service with reactive state
└── FIREBASE_INTEGRATION_GUIDE.dart  # Usage examples and best practices
```

## 🏗️ Data Architecture

### Collections Overview

1. **`users/{uid}`** - User profiles and basic information
2. **`user_settings/{uid}`** - App preferences, notifications, privacy settings
3. **`user_activity/{uid}`** - Activity stats, progress, achievements
4. **`user_social/{uid}`** - Friends, social stats, groups
5. **`user_support/{uid}`** - Support tickets, bug reports
6. **`user_devices/{uid}`** - Registered devices, FCM tokens
7. **`user_backup/{uid}`** - Data backups and recovery

### Data Models

#### User Profile
```dart
{
  uid: "user_unique_id",
  email: "user@example.com", 
  username: "CodeMaster47",
  displayName: "Mohamed Ali",
  profileImageUrl: "gs://bucket/profile_images/uid.jpg",
  userLevel: "Level 47",
  xpPoints: 15420,
  isPremiumUser: true,
  isVerified: true,
  friendsCount: 156,
  createdAt: timestamp,
  lastActiveAt: timestamp,
  accountStatus: "active"
}
```

#### User Settings
```dart
{
  notifications: {
    enabled: true,
    pushNotifications: true,
    emailNotifications: false,
    soundNotifications: true,
    friendRequests: true,
    levelUp: true,
    achievements: true
  },
  preferences: {
    language: "English",
    theme: "dark", 
    soundEffects: true,
    animations: true,
    autoSave: true
  },
  privacy: {
    profileVisibility: "public",
    showOnlineStatus: true,
    allowMessages: "friends",
    showActivity: true
  },
  security: {
    twoFactorEnabled: false,
    loginAlerts: true,
    sessionTimeout: 30,
    trustedDevices: []
  }
}
```

## 🚀 Quick Start

### 1. Service Initialization

The services are automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await _initializeServices();
  
  runApp(AppConfig.getApp());
}

Future<void> _initializeServices() async {
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<UserService>(UserService(), permanent: true);
}
```

### 2. Basic Usage

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userService = UserService.to;
    
    return GetX<UserService>(
      builder: (service) {
        if (!service.isAuthenticated) {
          return SignInPrompt();
        }
        
        return Column(
          children: [
            Text('Welcome, ${service.displayName}!'),
            Text('Level: ${service.userLevel}'),
            Text('XP: ${service.xpPoints}'),
          ],
        );
      },
    );
  }
}
```

## 📱 Common Use Cases

### User Registration Flow

```dart
// 1. After successful Firebase Auth registration
final userService = UserService.to;

// 2. Initialize user data in Firestore
await userService.initializeNewUser(
  email: email,
  username: username,
  displayName: displayName,
);

// 3. Navigate to main app
Get.offAllNamed('/dashboard');
```

### Profile Updates

```dart
await userService.updateProfile(
  username: 'newUsername',
  displayName: 'New Name',
  profileImageUrl: 'new_image_url',
);
```

### Settings Management

```dart
// Update notifications
await userService.updateNotificationSettings(
  enabled: true,
  pushNotifications: false,
);

// Update preferences  
await userService.updatePreferences(
  language: 'Spanish',
  theme: 'light',
);

// Update privacy
await userService.updatePrivacySettings(
  profileVisibility: 'friends',
  showOnlineStatus: false,
);
```

### Activity Tracking

```dart
// Log user activity
await userService.addActivity(
  type: 'challenge_completed',
  data: {
    'challengeId': 'challenge_123',
    'xpEarned': 150,
    'timeTaken': 300,
  },
);

// Grant achievement
await userService.addAchievement(
  id: 'first_challenge',
  name: 'First Steps', 
  description: 'Complete your first challenge',
  xpReward: 100,
);
```

### Social Features

```dart
// Add friend
await userService.addFriend(
  friendUid: 'friend_uid',
  friendUsername: 'FriendName',
);

// Search users
final users = await userService.searchUsers(
  query: 'john',
  limit: 10,
);
```

## 🎯 Reactive UI Patterns

### Using GetX Reactive Widgets

```dart
class UserStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<UserService>(
      builder: (userService) {
        return Card(
          child: Column(
            children: [
              Text('XP: ${userService.xpPoints}'),
              Text('Level: ${userService.userLevel}'),
              Text('Friends: ${userService.friendsCount}'),
              Text('Achievements: ${userService.achievements.length}'),
              LinearProgressIndicator(
                value: userService.xpPoints / 1000,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Settings Toggle Example

```dart
class SettingsTile extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return GetX<UserService>(
      builder: (service) {
        return SwitchListTile(
          title: Text('Notifications'),
          value: service.notificationsEnabled,
          onChanged: (value) async {
            await service.updateNotificationSettings(enabled: value);
            
            Get.snackbar(
              'Settings Updated',
              'Notifications ${value ? 'enabled' : 'disabled'}',
            );
          },
        );
      },
    );
  }
}
```

## 🔐 Security Considerations

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_settings/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_activity/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_social/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_support/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_devices/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /user_backup/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Data Validation

Always validate data before saving:

```dart
// Example validation in FirestoreService
Future<void> updateUserProfile(Map<String, dynamic> data) async {
  // Validate required fields
  if (data['email'] == null || data['email'].isEmpty) {
    throw FirestoreException('Email is required');
  }
  
  // Validate email format
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(data['email'])) {
    throw FirestoreException('Invalid email format');
  }
  
  // Validate username length
  if (data['username'] != null && data['username'].length < 3) {
    throw FirestoreException('Username must be at least 3 characters');
  }
  
  // Proceed with update...
}
```

## 📊 Performance Optimization

### Caching Strategy

```dart
class UserService extends GetxService {
  // Cache frequently accessed data
  final RxMap<String, UserData> _userCache = RxMap<String, UserData>();
  
  Future<UserData?> getUserData(String uid) async {
    // Check cache first
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }
    
    // Fetch from Firestore
    final data = await _firestoreService.getUserProfile(uid);
    if (data != null) {
      final userData = UserData.fromFirestore(data);
      _userCache[uid] = userData;
      return userData;
    }
    
    return null;
  }
}
```

### Batch Operations

```dart
// Example: Update multiple user stats at once
await _firestoreService.createOrUpdateUserActivity(
  uid: uid,
  stats: {
    'totalSessions': newSessionCount,
    'totalTimeSpent': newTimeSpent,
    'lastSession': FieldValue.serverTimestamp(),
  },
  progress: {
    'completedChallenges': newChallengeCount,
    'xpPoints': newXpTotal,
  },
);
```

## 🔄 Data Synchronization

### Real-time Updates

The `UserService` automatically sets up listeners for real-time data synchronization:

```dart
void _setupListeners() {
  // Profile changes
  _firestoreService.streamUserProfile(currentUserId!).listen(
    (profileData) {
      if (profileData != null) {
        _currentUser.value = UserData.fromFirestore(profileData);
      }
    },
  );
  
  // Settings changes  
  _firestoreService.streamUserSettings(currentUserId!).listen(
    (settingsData) {
      if (settingsData != null) {
        _userSettings.assignAll(settingsData);
      }
    },
  );
}
```

### Offline Support

Enable Firestore offline persistence:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(MyApp());
}
```

## 🧪 Testing

### Unit Testing Firebase Services

```dart
void main() {
  group('UserService Tests', () {
    late UserService userService;
    
    setUp(() {
      userService = UserService();
    });
    
    test('should update user profile successfully', () async {
      // Mock Firebase Auth
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');
      
      // Test profile update
      final result = await userService.updateProfile(
        username: 'testuser',
        displayName: 'Test User',
      );
      
      expect(result, true);
    });
  });
}
```

## 🚨 Error Handling

### Custom Exception Handling

```dart
try {
  await userService.updateProfile(username: 'newUsername');
} catch (e) {
  if (e is FirestoreException) {
    // Handle Firestore-specific errors
    Get.snackbar('Error', e.message);
  } else {
    // Handle general errors
    Get.snackbar('Error', 'An unexpected error occurred');
  }
}
```

## 📈 Analytics Integration

### Track User Events

```dart
// Track important user actions
await userService.addActivity(
  type: 'feature_used',
  data: {
    'feature': 'profile_update',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'platform': Platform.isIOS ? 'iOS' : 'Android',
  },
);
```

## 🔄 Migration Guide

### Updating Existing Controllers

Replace direct Firestore calls with UserService:

```dart
// OLD WAY ❌
class SettingsController extends ChangeNotifier {
  bool _notificationsEnabled = true;
  
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'notifications': value});
    notifyListeners();
  }
}

// NEW WAY ✅
class SettingsController extends GetxController {
  final UserService _userService = UserService.to;
  
  bool get notificationsEnabled => _userService.notificationsEnabled;
  
  Future<void> toggleNotifications(bool value) async {
    await _userService.updateNotificationSettings(enabled: value);
    // No need to call update() - GetX handles reactivity automatically
  }
}
```

## 🎯 Best Practices

1. **Always check authentication** before calling UserService methods
2. **Use reactive patterns** with GetX for real-time UI updates  
3. **Handle errors gracefully** with try-catch blocks
4. **Cache frequently accessed data** to reduce Firestore reads
5. **Use batch operations** for multiple related updates
6. **Validate all user inputs** before saving to Firestore
7. **Implement proper security rules** for data protection
8. **Create regular backups** of important user data
9. **Monitor performance** and optimize heavy operations
10. **Test offline scenarios** to ensure good UX

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Flutter Firebase Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)

---

Made with ❤️ for the CodeUp project
