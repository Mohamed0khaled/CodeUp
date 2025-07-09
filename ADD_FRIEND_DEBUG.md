# Debug: Add Friend Test

## Testing Steps

1. **Open the app in debug mode**
2. **Navigate to Friends screen**
3. **Try to add a friend**
4. **Check console logs for:**
   - "Adding friend: [uid] - [name]"
   - "Add friend result: [true/false]"
   - Any error messages or stack traces

## Expected Debug Output

```
Flutter: Adding friend: someuid123 - John Doe
Flutter: Add friend result: true
Flutter: Friend added to local state successfully
```

## Common Error Sources

1. **Firestore Permission Issues**
   - User doesn't have write access to user_social collection
   - Security rules preventing friend operations

2. **Authentication Issues**
   - User not properly authenticated
   - Session expired

3. **Data Structure Issues**
   - Missing user_social document
   - Invalid data format in Firestore

4. **Network Issues**
   - No internet connection
   - Firestore timeout

## Debugging Commands

Run the app and watch console output:
```bash
flutter run --debug
```

If the app crashes, check:
```bash
flutter logs
```

## Minimal Test Function

Add this to friends screen for testing:
```dart
void _testAddFriendMinimal() async {
  try {
    debugPrint('Testing basic add friend functionality...');
    
    final testUser = UserData(
      uid: 'test123',
      email: 'test@example.com',
      username: 'testuser',
      displayName: 'Test User',
    );
    
    debugPrint('Test user created: ${testUser.uid}');
    
    // Test the service directly
    final result = await userService.addFriend(
      friendUid: testUser.uid,
      friendUsername: testUser.username ?? testUser.email,
    );
    
    debugPrint('Direct service call result: $result');
    
  } catch (e, stack) {
    debugPrint('Test error: $e');
    debugPrint('Test stack: $stack');
  }
}
```
