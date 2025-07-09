import 'package:codeup/models/fireStore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// 🎯 User Service Manager
/// 
/// A comprehensive service that integrates with FirestoreService
/// to provide easy-to-use methods for user data management
/// throughout the application
class UserService extends GetxService {
  static UserService get to => Get.find();
  
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Reactive user data
  final Rx<UserData?> _currentUser = Rx<UserData?>(null);
  final RxMap<String, dynamic> _userSettings = RxMap<String, dynamic>();
  final RxMap<String, dynamic> _userActivity = RxMap<String, dynamic>();
  final RxMap<String, dynamic> _userSocial = RxMap<String, dynamic>();
  
  // Reactive rank cache
  final RxInt _cachedUserRank = 1.obs;
  final RxInt _cachedXpForNextRank = 0.obs;
  
  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  
  // Getters
  UserData? get currentUser => _currentUser.value;
  Map<String, dynamic> get userSettings => _userSettings;
  Map<String, dynamic> get userActivity => _userActivity;
  Map<String, dynamic> get userSocial => _userSocial;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    
    // Setup authentication state listener first
    _setupAuthListener();
    
    // Initialize service if user is already authenticated
    if (isAuthenticated) {
      await _initializeService();
    }
  }
  
  /// Initialize the service
  Future<void> _initializeService() async {
    if (!isAuthenticated) return;
    
    _isLoading.value = true;
    
    try {
      // Load user data
      await loadUserData();
      
      // Set up real-time listeners
      _setupListeners();
      
      // Update last active
      await updateLastActive();
      
      _isInitialized.value = true;
    } catch (e) {
      debugPrint('Error initializing UserService: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Load all user data
  Future<void> loadUserData() async {
    if (!isAuthenticated) return;
    
    try {
      // Load user profile
      final profileData = await _firestoreService.getCurrentUserProfile();
      if (profileData != null) {
        _currentUser.value = UserData.fromFirestore(profileData);
      }
      
      // Load user settings
      final settingsData = await _firestoreService.getUserSettings(currentUserId!);
      if (settingsData != null) {
        _userSettings.assignAll(settingsData);
      }
      
      // Load user activity
      final activityData = await _firestoreService.getUserActivity(currentUserId!);
      if (activityData != null) {
        _userActivity.assignAll(activityData);
      }
      
      // Load user social
      final socialData = await _firestoreService.getUserSocial(currentUserId!);
      if (socialData != null) {
        _userSocial.assignAll(socialData);
      }
      
      // Fetch user's current rank
      await fetchUserRank();
      await fetchXpForNextRank();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }
  
  /// Set up real-time listeners
  void _setupListeners() {
    if (!isAuthenticated) return;
    
    // Listen to user profile changes
    _firestoreService.streamUserProfile(currentUserId!).listen(
      (profileData) {
        if (profileData != null) {
          _currentUser.value = UserData.fromFirestore(profileData);
        }
      },
      onError: (error) => debugPrint('Profile stream error: $error'),
    );
    
    // Listen to user settings changes
    _firestoreService.streamUserSettings(currentUserId!).listen(
      (settingsData) {
        if (settingsData != null) {
          _userSettings.assignAll(settingsData);
        }
      },
      onError: (error) => debugPrint('Settings stream error: $error'),
    );
  }
  
  /// Listen to authentication state changes
  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User signed in
        if (!_isInitialized.value) {
          // First time initialization
          await _initializeService();
        } else {
          // User already initialized but might need refresh (e.g., after Google login)
          await refreshUserData();
        }
      } else {
        // User signed out, clear data
        _clearUserData();
      }
    });
  }
  
  /// Clear user data when signed out
  void _clearUserData() {
    _currentUser.value = null;
    _userSettings.clear();
    _userActivity.clear();
    _userSocial.clear();
    _cachedUserRank.value = 1;
    _cachedXpForNextRank.value = 0;
    _isInitialized.value = false;
  }
  
  // ====================================================================
  // USER PROFILE METHODS
  // ====================================================================
  
  /// Initialize new user
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
  
  /// Update user profile
  Future<bool> updateProfile({
    String? username,
    String? displayName,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.createOrUpdateUserProfile(
        uid: currentUserId!,
        email: _auth.currentUser!.email!,
        username: username,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
  
  /// Update only the user's display name in Firestore and locally.
  /// Returns true if successful, false otherwise.
  Future<bool> updateDisplayName(String newDisplayName) async {
    if (!isAuthenticated) return false;
    try {
      await _firestoreService.createOrUpdateUserProfile(
        uid: currentUserId!,
        email: _auth.currentUser!.email!,
        displayName: newDisplayName,
      );
      // Update local state
      if (_currentUser.value != null) {
        _currentUser.value = _currentUser.value!.copyWith(displayName: newDisplayName);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating display name: $e');
      return false;
    }
  }
  
  /// Update last active
  Future<void> updateLastActive() async {
    if (!isAuthenticated) return;
    
    try {
      await _firestoreService.updateLastActive();
    } catch (e) {
      debugPrint('Error updating last active: $e');
    }
  }
  
  /// Update the user's profile image by uploading a local image to Firebase Storage and updating Firestore.
  /// Returns the new image URL if successful, null otherwise.
  /// NOTE: This requires Firebase Storage which is a paid service.
  /// Alternative: Store as base64 string in Firestore (see updateProfileImageAsBase64)
  @Deprecated('Use updateProfileImageAsBase64() instead. Firebase Storage is a paid service.')
  Future<String?> updateProfileImage() async {
    // Disabled to prevent errors for users without Firebase Storage subscription
    return null;
  }
  
  /// Update profile image by converting to base64 and storing in Firestore
  /// This is a free alternative to Firebase Storage
  Future<String?> updateProfileImageAsBase64() async {
    if (!isAuthenticated) return null;
    
    try {
      // Pick image from gallery
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 60, // Lower quality to reduce size
        maxWidth: 300,    // Smaller size for base64 storage
        maxHeight: 300,
      );
      
      if (pickedFile == null) return null;
      
      final file = File(pickedFile.path);
      
      // Convert to base64
      final bytes = await file.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      // Check size (Firestore has 1MB document limit)
      if (base64String.length > 900000) { // Leave some room for other fields
        debugPrint('Image too large for Firestore storage (${base64String.length} characters)');
        return null;
      }
      
      // Update Firestore profile with base64 string
      await _firestoreService.createOrUpdateUserProfile(
        uid: currentUserId!,
        email: _auth.currentUser!.email!,
        profileImageUrl: base64String,
      );
      
      // Update local state
      if (_currentUser.value != null) {
        _currentUser.value = _currentUser.value!.copyWith(profileImageUrl: base64String);
      }
      
      debugPrint('Profile image updated as base64 string');
      return base64String;
    } catch (e) {
      debugPrint('Error updating profile image as base64: $e');
      return null;
    }
  }
  
  /// Upload profile image from a file object
  /// This method is useful when you already have a File object and want to upload it
  /// Returns the download URL if successful, null otherwise.
  Future<String?> uploadProfileImageFromFile(File imageFile) async {
    if (!isAuthenticated) return null;
    
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist');
        return null;
      }
      
      // Validate file size (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        debugPrint('Image file too large: ${fileSize / (1024 * 1024)} MB');
        return null;
      }
      
      final userId = currentUserId!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance.ref().child('user_profile_images/$userId-$timestamp.jpg');
      
      debugPrint('Uploading image to: user_profile_images/$userId-$timestamp.jpg');
      
      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': timestamp.toString(),
        },
      );
      
      final uploadTask = await storageRef.putFile(imageFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      debugPrint('Upload successful, download URL: $downloadUrl');
      
      // Update Firestore profile
      await _firestoreService.createOrUpdateUserProfile(
        uid: userId,
        email: _auth.currentUser!.email!,
        profileImageUrl: downloadUrl,
      );
      
      // Update local state
      if (_currentUser.value != null) {
        _currentUser.value = _currentUser.value!.copyWith(profileImageUrl: downloadUrl);
      }
      
      debugPrint('Profile image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image from file: $e');
      // Log more details about the error
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      return null;
    }
  }
  
  /// Update user profile (for existing users)
  Future<bool> updateUserProfile({
    String? username,
    String? displayName,
    String? profileImageUrl,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.createOrUpdateUserProfile(
        uid: currentUserId!,
        email: _auth.currentUser!.email!,
        username: username,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
      );
      
      // Reload user data to reflect changes
      await loadUserData();
      
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }
  
  // ====================================================================
  // USER SETTINGS METHODS
  // ====================================================================
  
  /// Update notification settings
  Future<bool> updateNotificationSettings({
    bool? enabled,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? soundNotifications,
    bool? friendRequests,
    bool? levelUp,
    bool? achievements,
    bool? challenges,
    bool? messages,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      final notifications = Map<String, dynamic>.from(_userSettings['notifications'] ?? {});
      
      if (enabled != null) notifications['enabled'] = enabled;
      if (pushNotifications != null) notifications['pushNotifications'] = pushNotifications;
      if (emailNotifications != null) notifications['emailNotifications'] = emailNotifications;
      if (soundNotifications != null) notifications['soundNotifications'] = soundNotifications;
      if (friendRequests != null) notifications['friendRequests'] = friendRequests;
      if (levelUp != null) notifications['levelUp'] = levelUp;
      if (achievements != null) notifications['achievements'] = achievements;
      if (challenges != null) notifications['challenges'] = challenges;
      if (messages != null) notifications['messages'] = messages;
      
      await _firestoreService.updateUserSetting(
        currentUserId!,
        'notifications',
        notifications,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      return false;
    }
  }
  
  /// Update app preferences
  Future<bool> updatePreferences({
    String? language,
    String? theme,
    bool? soundEffects,
    bool? animations,
    bool? autoSave,
    String? dataUsage,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      final preferences = Map<String, dynamic>.from(_userSettings['preferences'] ?? {});
      
      if (language != null) preferences['language'] = language;
      if (theme != null) preferences['theme'] = theme;
      if (soundEffects != null) preferences['soundEffects'] = soundEffects;
      if (animations != null) preferences['animations'] = animations;
      if (autoSave != null) preferences['autoSave'] = autoSave;
      if (dataUsage != null) preferences['dataUsage'] = dataUsage;
      
      await _firestoreService.updateUserSetting(
        currentUserId!,
        'preferences',
        preferences,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      return false;
    }
  }
  
  /// Update privacy settings
  Future<bool> updatePrivacySettings({
    String? profileVisibility,
    bool? showOnlineStatus,
    String? allowMessages,
    bool? showActivity,
    bool? dataSharing,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      final privacy = Map<String, dynamic>.from(_userSettings['privacy'] ?? {});
      
      if (profileVisibility != null) privacy['profileVisibility'] = profileVisibility;
      if (showOnlineStatus != null) privacy['showOnlineStatus'] = showOnlineStatus;
      if (allowMessages != null) privacy['allowMessages'] = allowMessages;
      if (showActivity != null) privacy['showActivity'] = showActivity;
      if (dataSharing != null) privacy['dataSharing'] = dataSharing;
      
      await _firestoreService.updateUserSetting(
        currentUserId!,
        'privacy',
        privacy,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      return false;
    }
  }
  
  /// Update security settings
  Future<bool> updateSecuritySettings({
    bool? twoFactorEnabled,
    bool? loginAlerts,
    int? sessionTimeout,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      final security = Map<String, dynamic>.from(_userSettings['security'] ?? {});
      
      if (twoFactorEnabled != null) security['twoFactorEnabled'] = twoFactorEnabled;
      if (loginAlerts != null) security['loginAlerts'] = loginAlerts;
      if (sessionTimeout != null) security['sessionTimeout'] = sessionTimeout;
      
      await _firestoreService.updateUserSetting(
        currentUserId!,
        'security',
        security,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating security settings: $e');
      return false;
    }
  }
  
  // ====================================================================
  // USER ACTIVITY METHODS
  // ====================================================================
  
  /// Add user activity
  Future<bool> addActivity({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.addUserActivity(
        uid: currentUserId!,
        type: type,
        data: data,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error adding activity: $e');
      return false;
    }
  }
  
  /// Add achievement
  Future<bool> addAchievement({
    required String id,
    required String name,
    required String description,
    required int xpReward,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.addUserAchievement(
        uid: currentUserId!,
        id: id,
        name: name,
        description: description,
        xpReward: xpReward,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error adding achievement: $e');
      return false;
    }
  }
  
  /// Update user stats
  Future<bool> updateStats({
    int? totalSessions,
    int? totalTimeSpent,
    int? averageSessionTime,
    int? longestSession,
    int? dailyStreak,
    int? longestStreak,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      final stats = Map<String, dynamic>.from(_userActivity['stats'] ?? {});
      
      if (totalSessions != null) stats['totalSessions'] = totalSessions;
      if (totalTimeSpent != null) stats['totalTimeSpent'] = totalTimeSpent;
      if (averageSessionTime != null) stats['averageSessionTime'] = averageSessionTime;
      if (longestSession != null) stats['longestSession'] = longestSession;
      if (dailyStreak != null) stats['dailyStreak'] = dailyStreak;
      if (longestStreak != null) stats['longestStreak'] = longestStreak;
      
      await _firestoreService.createOrUpdateUserActivity(
        uid: currentUserId!,
        stats: stats,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating stats: $e');
      return false;
    }
  }
  
  // ====================================================================
  // USER SOCIAL METHODS
  // ====================================================================
  
  /// Add friend
  Future<bool> addFriend({
    required String friendUid,
    required String friendUsername,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.addFriend(
        uid: currentUserId!,
        friendUid: friendUid,
        friendUsername: friendUsername,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error adding friend: $e');
      return false;
    }
  }
  
  /// Get user's friends list
  Future<List<UserData>> getFriends() async {
    if (!isAuthenticated) return [];
    
    try {
      final socialData = await _firestoreService.getUserSocial(currentUserId!);
      if (socialData == null) return [];
      
      final friends = List<Map<String, dynamic>>.from(socialData['friends'] ?? []);
      final friendsData = <UserData>[];
      
      // Get full user data for each friend
      for (final friend in friends) {
        final friendUid = friend['uid'];
        final friendProfile = await _firestoreService.getUserProfile(friendUid);
        if (friendProfile != null) {
          friendsData.add(UserData.fromFirestore(friendProfile));
        }
      }
      
      return friendsData;
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return [];
    }
  }
  
  /// Get suggested friends (users with similar interests or activity)
  Future<List<UserData>> getSuggestedFriends({int limit = 10}) async {
    if (!isAuthenticated) return [];
    
    try {
      // Get users with similar skill levels or recent activity
      final allUsers = await searchUsers(query: '', limit: 50);
      final currentUser = this.currentUser;
      
      if (currentUser == null) return [];
      
      // Get current user's friends to exclude them
      final friends = await getFriends();
      final friendUids = friends.map((f) => f.uid).toSet();
      
      // Filter and sort suggested friends
      final suggestions = allUsers
          .where((user) => user.uid != currentUserId && !friendUids.contains(user.uid))
          .where((user) => _isSimilarSkillLevel(currentUser, user))
          .take(limit)
          .toList();
      
      return suggestions;
    } catch (e) {
      debugPrint('Error getting suggested friends: $e');
      return [];
    }
  }
  
  /// Check if two users have similar skill levels
  bool _isSimilarSkillLevel(UserData user1, UserData user2) {
    final level1 = int.tryParse(user1.userLevel ?? '1') ?? 1;
    final level2 = int.tryParse(user2.userLevel ?? '1') ?? 1;
    final levelDiff = (level1 - level2).abs();
    return levelDiff <= 2; // Suggest users within 2 levels
  }
  
  /// Check if user is friend
  Future<bool> isFriend(String userId) async {
    if (!isAuthenticated) return false;
    
    try {
      final socialData = await _firestoreService.getUserSocial(currentUserId!);
      if (socialData == null) return false;
      
      final friends = List<Map<String, dynamic>>.from(socialData['friends'] ?? []);
      return friends.any((friend) => friend['uid'] == userId);
    } catch (e) {
      debugPrint('Error checking if user is friend: $e');
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend({
    required String friendUid,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.removeFriend(
        uid: currentUserId!,
        friendUid: friendUid,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return false;
    }
  }
  
  // ====================================================================
  // USER SUPPORT METHODS
  // ====================================================================
  
  /// Create support ticket
  Future<String?> createSupportTicket({
    required String subject,
    required String message,
  }) async {
    if (!isAuthenticated) return null;
    
    try {
      final ticketId = await _firestoreService.createSupportTicket(
        uid: currentUserId!,
        subject: subject,
        message: message,
      );
      
      return ticketId;
    } catch (e) {
      debugPrint('Error creating support ticket: $e');
      return null;
    }
  }
  
  /// Submit bug report
  Future<String?> submitBugReport({
    required String description,
    String severity = 'medium',
    Map<String, dynamic>? deviceInfo,
  }) async {
    if (!isAuthenticated) return null;
    
    try {
      final bugId = await _firestoreService.submitBugReport(
        uid: currentUserId!,
        description: description,
        severity: severity,
        deviceInfo: deviceInfo,
      );
      
      return bugId;
    } catch (e) {
      debugPrint('Error submitting bug report: $e');
      return null;
    }
  }
  
  // ====================================================================
  // USER DEVICE METHODS
  // ====================================================================
  
  /// Register current device
  Future<bool> registerDevice({
    required String deviceId,
    required String name,
    required String platform,
    required String version,
    required String appVersion,
    String? fcmToken,
    bool trusted = false,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.registerUserDevice(
        uid: currentUserId!,
        deviceId: deviceId,
        name: name,
        platform: platform,
        version: version,
        appVersion: appVersion,
        fcmToken: fcmToken,
        trusted: trusted,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error registering device: $e');
      return false;
    }
  }
  
  /// Update device last used
  Future<void> updateDeviceLastUsed(String deviceId) async {
    if (!isAuthenticated) return;
    
    try {
      await _firestoreService.updateDeviceLastUsed(
        uid: currentUserId!,
        deviceId: deviceId,
      );
    } catch (e) {
      debugPrint('Error updating device last used: $e');
    }
  }
  
  // ====================================================================
  // USER BACKUP METHODS
  // ====================================================================
  
  /// Create backup
  Future<bool> createBackup() async {
    if (!isAuthenticated) return false;
    
    try {
      final backupData = {
        'profile': _currentUser.value?.toMap(),
        'settings': _userSettings,
        'activity': _userActivity,
        'social': _userSocial,
      };
      
      await _firestoreService.createUserBackup(
        uid: currentUserId!,
        backupData: backupData,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }
  
  // ====================================================================
  // UTILITY METHODS
  // ====================================================================
  
  /// Search users
  Future<List<UserData>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    try {
      final results = await _firestoreService.searchUsers(
        query: query,
        limit: limit,
      );
      
      return results.map((data) => UserData.fromFirestore(data)).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }
  
  /// Delete all user data
  Future<bool> deleteAllUserData() async {
    if (!isAuthenticated) return false;
    
    try {
      await _firestoreService.deleteAllUserData(currentUserId!);
      
      // Clear local data
      _currentUser.value = null;
      _userSettings.clear();
      _userActivity.clear();
      _userSocial.clear();
      
      return true;
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      return false;
    }
  }
  
  /// Reset service state
  void resetService() {
    _currentUser.value = null;
    _userSettings.clear();
    _userActivity.clear();
    _userSocial.clear();
    _cachedUserRank.value = 1;
    _cachedXpForNextRank.value = 0;
    _isLoading.value = false;
    _isInitialized.value = false;
  }
  
  // ====================================================================
  // CONVENIENCE GETTERS
  // ====================================================================
  
  /// Get current user's display name
  String get displayName => _currentUser.value?.displayName ?? _currentUser.value?.username ?? 'User';
  
  /// Get current user's username
  String get username => _currentUser.value?.username ?? 'user';
  
  /// Get current user's email
  String get email => _currentUser.value?.email ?? '';
  
  /// Get current user's XP points
  int get xpPoints => _currentUser.value?.xpPoints ?? 0;
  
  /// Get current user's level
  String get userLevel => _currentUser.value?.userLevel ?? 'Level 1';
  
  /// Check if user is premium
  bool get isPremium => _currentUser.value?.isPremiumUser ?? false;
  
  /// Check if user is verified
  bool get isVerified => _currentUser.value?.isVerified ?? false;
  
  /// Get current user's profile image URL
  String? get profileImageUrl => _currentUser.value?.profileImageUrl;
  
  /// Get OAuth provider profile image URL (Google, GitHub, etc.)
  String? get oauthProviderImageUrl {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    // Check if user has a photo URL from OAuth provider
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      debugPrint('OAuth provider image found: ${user.photoURL}');
      return user.photoURL;
    }
    
    // Check provider data for profile images
    for (final userInfo in user.providerData) {
      if (userInfo.photoURL != null && userInfo.photoURL!.isNotEmpty) {
        debugPrint('Provider ${userInfo.providerId} image found: ${userInfo.photoURL}');
        return userInfo.photoURL;
      }
    }
    
    return null;
  }
  
  /// Get the best available profile image URL with priority:
  /// 1. User's uploaded custom image (if available) - highest priority
  /// 2. OAuth provider image (Google/GitHub) - fallback if no custom image
  /// 3. null (will fallback to initials) - final fallback
  String? get bestProfileImageUrl {
    // First priority: User's custom uploaded image
    final customImage = _currentUser.value?.profileImageUrl;
    if (customImage != null && customImage.isNotEmpty) {
      return customImage;
    }
    
    // Second priority: OAuth provider image (Google/GitHub)
    final oauthImage = oauthProviderImageUrl;
    if (oauthImage != null && oauthImage.isNotEmpty) {
      return oauthImage;
    }
    
    // Third priority: null (will show initials)
    return null;
  }

  /// Get notification settings
  bool get notificationsEnabled => _userSettings['notifications']?['enabled'] ?? true;
  bool get soundNotificationsEnabled => _userSettings['notifications']?['soundNotifications'] ?? true;
  bool get pushNotificationsEnabled => _userSettings['notifications']?['pushNotifications'] ?? true;
  
  /// Get app preferences
  String get language => _userSettings['preferences']?['language'] ?? 'English';
  String get theme => _userSettings['preferences']?['theme'] ?? 'dark';
  bool get soundEffectsEnabled => _userSettings['preferences']?['soundEffects'] ?? true;
  bool get animationsEnabled => _userSettings['preferences']?['animations'] ?? true;
  
  /// Get privacy settings
  String get profileVisibility => _userSettings['privacy']?['profileVisibility'] ?? 'public';
  bool get showOnlineStatus => _userSettings['privacy']?['showOnlineStatus'] ?? true;
  
  /// Get security settings
  bool get twoFactorEnabled => _userSettings['security']?['twoFactorEnabled'] ?? false;
  bool get loginAlertsEnabled => _userSettings['security']?['loginAlerts'] ?? true;
  
  /// Get user stats
  int get totalSessions => _userActivity['stats']?['totalSessions'] ?? 0;
  int get totalTimeSpent => _userActivity['stats']?['totalTimeSpent'] ?? 0;
  int get dailyStreak => _userActivity['stats']?['dailyStreak'] ?? 0;
  int get longestStreak => _userActivity['stats']?['longestStreak'] ?? 0;
  
  /// Get user progress
  int get completedChallenges => _userActivity['progress']?['completedChallenges'] ?? 0;
  int get totalChallenges => _userActivity['progress']?['totalChallenges'] ?? 0;
  String get skillLevel => _userActivity['progress']?['skillLevel'] ?? 'Beginner';
  int get badgesEarned => _userActivity['progress']?['badgesEarned'] ?? 0;
  
  /// Get social stats
  int get friendsCount => _userSocial['socialStats']?['friendsCount'] ?? 0;
  int get followersCount => _currentUser.value?.isPremiumUser == true ? 892 : 0;
  int get followingCount => _currentUser.value?.isPremiumUser == true ? 234 : 0;
  List<dynamic> get friends => _userSocial['friends'] ?? [];
  
  /// Get recent activities
  List<dynamic> get recentActivities => _userActivity['recentActivity'] ?? [];
  
  /// Get achievements
  List<dynamic> get achievements => _userActivity['achievements'] ?? [];
  
  /// Get the user's rank as their actual position among all app users based on XP points.
  /// Returns the numeric rank (1st, 2nd, 3rd, etc.) among all users.
  /// This is cached locally and updated when user data loads.
  int get userRank => _cachedUserRank.value;
  
  /// Fetch and update the user's current rank from Firestore
  Future<int> fetchUserRank() async {
    if (!isAuthenticated) return 1;
    
    try {
      final rank = await _firestoreService.getUserRank(currentUserId!);
      _cachedUserRank.value = rank;
      return rank;
    } catch (e) {
      debugPrint('Error fetching user rank: $e');
      return _cachedUserRank.value;
    }
  }

  /// Get XP required to reach the next rank position.
  /// This calculates XP needed to surpass the user above in the leaderboard.
  int get xpForNextRank => _cachedXpForNextRank.value;
  
  /// Fetch XP required for next rank from leaderboard data
  Future<int> fetchXpForNextRank() async {
    if (!isAuthenticated) return 0;
    
    try {
      // Get leaderboard to find the user above us
      final leaderboard = await _firestoreService.getLeaderboard(limit: userRank + 10);
      
      if (leaderboard.isEmpty || userRank <= 1) {
        _cachedXpForNextRank.value = 0; // Already at top or no data
        return 0;
      }
      
      // Find the user at the rank above us (rank - 1)
      if (userRank - 1 <= leaderboard.length) {
        final userAbove = leaderboard[userRank - 2]; // 0-indexed
        final xpAbove = userAbove['xpPoints'] ?? 0;
        final currentXP = xpPoints;
        _cachedXpForNextRank.value = (xpAbove - currentXP) + 1; // +1 to surpass
        return _cachedXpForNextRank.value;
      }
      
      _cachedXpForNextRank.value = 0;
      return 0;
    } catch (e) {
      debugPrint('Error fetching XP for next rank: $e');
      return _cachedXpForNextRank.value;
    }
  }

  /// Get leaderboard data
  Future<List<UserData>> getLeaderboard({int limit = 100}) async {
    try {
      final results = await _firestoreService.getLeaderboard(limit: limit);
      return results.map((data) => UserData.fromFirestore(data)).toList();
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Update user's rank after XP changes
  Future<void> updateRankAfterXPChange() async {
    await fetchUserRank();
    await fetchXpForNextRank();
  }

  /// Calculate rank progress as a percentage (0.0 to 1.0).
  /// Based on progress towards the next rank position.
  double get rankProgress {
    if (userRank <= 1) return 1.0; // Already at top
    
    final xpNeeded = xpForNextRank;
    if (xpNeeded <= 0) return 1.0; // Already at top or error
    
    // Get a reasonable progress calculation
    // This is a simplified version - you might want to make it more sophisticated
    final currentXP = xpPoints;
    if (currentXP <= 0) return 0.0;
    
    // Calculate progress based on XP gap
    // Use a logarithmic scale to make progress feel more achievable
    final progressFactor = 1.0 - (xpNeeded / (currentXP + xpNeeded).toDouble());
    return progressFactor.clamp(0.0, 1.0);
  }

  /// Check if user exists in the database
  Future<bool> checkUserExists({required String email}) async {
    try {
      final userProfile = await _firestoreService.getUserProfileByEmail(email);
      return userProfile != null;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }

  /// Force refresh user data (public method)
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;
    
    _isLoading.value = true;
    
    try {
      await loadUserData();
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}