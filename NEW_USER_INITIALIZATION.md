# New User Initialization Implementation

## Overview
The application now has robust logic to check for new user existence and initialize them properly during email/password signup, as well as OAuth signups (Google, GitHub).

## Implementation Details

### 1. AuthController Logic (`lib/controllers/auth/authController.dart`)

#### Email/Password Signup
```dart
Future<AuthResult> signUpWithEmailPassword({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    // 1. Check if user already exists in Firestore
    final userExists = await userService.checkUserExists(email: email.trim());
    if (userExists) {
      // Show error and return early
      AuthErrorHandler.showError(context, 'email-already-in-use', 
        'An account with this email already exists. Please sign in instead.');
      return AuthResult(additionalInfo: 'email-already-in-use');
    }

    // 2. Create Firebase Auth account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 3. Initialize new user in Firestore
    if (credential.user != null) {
      await userService.initializeNewUser(
        email: credential.user!.email!,
        displayName: credential.user!.displayName, // Will be null for email/password signup
      );
    }

    return AuthResult(user: credential.user, isNewUser: true);
  } catch (e) {
    // Handle errors...
  }
}
```

#### OAuth Signup (Google/GitHub)
```dart
// Check if user exists after OAuth authentication
final email = userCredential.user?.email;
if (email != null && !(await userService.checkUserExists(email: email))) {
  // Initialize new user
  await userService.initializeNewUser(
    email: email,
    displayName: userCredential.user?.displayName,
  );
  return AuthResult(user: userCredential.user, isNewUser: true);
}
```

### 2. UserService Methods (`lib/services/user_service.dart`)

#### Check User Existence
```dart
Future<bool> checkUserExists({required String email}) async {
  try {
    final userProfile = await _firestoreService.getUserProfileByEmail(email);
    return userProfile != null;
  } catch (e) {
    debugPrint('Error checking user existence: $e');
    return false;
  }
}
```

#### Initialize New User
```dart
Future<bool> initializeNewUser({
  required String email,
  String? username,
  String? displayName,
  String? profileImageUrl,
}) async {
  if (!isAuthenticated) return false;
  
  try {
    await _firestoreService.initializeNewUser(
      uid: currentUserId!,
      email: email,
      username: username,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
    );
    
    // Reload user data
    await loadUserData();
    
    return true;
  } catch (e) {
    debugPrint('Error initializing new user: $e');
    return false;
  }
}
```

### 3. FirestoreService Implementation (`lib/models/fireStore.dart`)

#### Get User Profile by Email
```dart
Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
  try {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }

    return null;
  } catch (e) {
    _logger.e('Error getting user profile by email: $e');
    throw FirestoreException('Failed to get user profile by email: $e');
  }
}
```

#### Initialize New User in Firestore
```dart
Future<void> initializeNewUser({
  required String uid,
  required String email,
  String? username,
  String? displayName,
  String? profileImageUrl,
}) async {
  try {
    final batch = _firestore.batch();
    
    // Initialize user profile with default values
    final userRef = _firestore.collection('users').doc(uid);
    batch.set(userRef, {
      'uid': uid,
      'email': email,
      'username': username ?? 'User${uid.substring(0, 6)}',
      'displayName': displayName ?? 'New User',
      'profileImageUrl': profileImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'accountStatus': 'active',
      'xpPoints': 0,
      'userLevel': 'Level 1',
      'rank': 0,
      // ... more default values
    });
    
    // Initialize user settings
    final settingsRef = _firestore.collection('user_settings').doc(uid);
    batch.set(settingsRef, {
      // Default settings...
    });
    
    // Initialize user activity
    final activityRef = _firestore.collection('user_activity').doc(uid);
    batch.set(activityRef, {
      // Default activity data...
    });
    
    // Initialize user social
    final socialRef = _firestore.collection('user_social').doc(uid);
    batch.set(socialRef, {
      // Default social data...
    });
    
    await batch.commit();
  } catch (e) {
    // Handle errors...
  }
}
```

## Flow Diagram

```
User Signup Request
        ↓
Check if email exists in Firestore
        ↓
   [Email exists?]
    ↙        ↘
  YES         NO
    ↓          ↓
Show error  Create Firebase Auth account
    ↓          ↓
  Return    Initialize user in Firestore
             ↓
         Show success message
             ↓
         Return success result
```

## Key Features

### 1. **Duplicate Prevention**
- Before creating any new account, the system checks if a user with that email already exists in Firestore
- Prevents duplicate accounts and provides clear feedback to users

### 2. **Comprehensive Initialization**
- New users are initialized with complete default data across multiple Firestore collections:
  - `users` - Profile and basic information
  - `user_settings` - Notification and preference settings
  - `user_activity` - Progress and statistics tracking
  - `user_social` - Social features and connections

### 3. **OAuth Integration**
- Works seamlessly with Google and GitHub OAuth providers
- Automatically extracts profile information from OAuth providers when available
- Handles both new and existing OAuth users

### 4. **Error Handling**
- Comprehensive error handling with user-friendly messages
- Graceful degradation when services are unavailable
- Proper logging for debugging

### 5. **Profile Image Integration**
- Automatically uses OAuth provider profile images when available
- Integrates with the existing profile image priority system:
  1. Custom uploaded image (base64 in Firestore)
  2. OAuth provider image
  3. User initials fallback

## Testing

A basic test structure is provided in `test/auth_initialization_test.dart` that demonstrates how to test the initialization logic with mocked dependencies.

## Benefits

1. **User Experience**: Seamless account creation with immediate access to all app features
2. **Data Consistency**: All users have the same data structure from day one
3. **Maintainability**: Centralized initialization logic that's easy to update
4. **Scalability**: Batch operations for efficient Firestore usage
5. **Security**: Proper validation and error handling prevents edge cases

## Future Enhancements

1. **Welcome Tour**: Could trigger a welcome flow for new users
2. **Analytics**: Track new user registration and conversion rates
3. **A/B Testing**: Different initialization strategies for different user segments
4. **Progressive Profiling**: Gradual collection of user information over time
