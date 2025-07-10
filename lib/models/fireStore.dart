import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:codeup/models/user_data.dart';

/// 🔥 Firebase Firestore Service
/// 
/// Comprehensive service for managing all user data in Firestore
/// Provides CRUD operations for all user-related collections
/// with proper error handling and data validation
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  /// Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ====================================================================
  // USER PROFILE MANAGEMENT
  // ====================================================================

  /// Create or update user profile
  Future<void> createOrUpdateUserProfile({
    required String uid,
    required String email,
    String? username,
    String? displayName,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? profileImagePath,
    String? userId,
    String? userLevel,
    int? xpPoints,
    int? rank,
    bool? isPremiumUser,
    bool? isVerified,
    int? friendsCount,
    int? followersCount,
    int? followingCount,
    String? profileVisibility,
    bool? showEmail,
    bool? showRealName,
    bool? allowFriendRequests,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      final now = FieldValue.serverTimestamp();
      
      // Check if document exists
      final docSnapshot = await userRef.get();
      final isNewUser = !docSnapshot.exists;
      
      final userData = {
        'uid': uid,
        'email': email,
        'updatedAt': now,
        if (username != null) 'username': username,
        if (displayName != null) 'displayName': displayName,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (profileImagePath != null) 'profileImagePath': profileImagePath,
        if (userId != null) 'userId': userId,
        if (userLevel != null) 'userLevel': userLevel,
        if (xpPoints != null) 'xpPoints': xpPoints,
        if (rank != null) 'rank': rank,
        if (isPremiumUser != null) 'isPremiumUser': isPremiumUser,
        if (isVerified != null) 'isVerified': isVerified,
        if (friendsCount != null) 'friendsCount': friendsCount,
        if (followersCount != null) 'followersCount': followersCount,
        if (followingCount != null) 'followingCount': followingCount,
        if (profileVisibility != null) 'profileVisibility': profileVisibility,
        if (showEmail != null) 'showEmail': showEmail,
        if (showRealName != null) 'showRealName': showRealName,
        if (allowFriendRequests != null) 'allowFriendRequests': allowFriendRequests,
      };
      
      if (isNewUser) {
        userData.addAll({
          'createdAt': now,
          'lastActiveAt': now,
          'accountStatus': 'active',
          'xpPoints': xpPoints ?? 0,
          'userLevel': userLevel ?? 'Level 1',
          'rank': rank ?? 0, // Default rank as 0
          'isPremiumUser': isPremiumUser ?? false,
          'isVerified': isVerified ?? false,
          'friendsCount': friendsCount ?? 0,
          'followersCount': followersCount ?? 0,
          'followingCount': followingCount ?? 0,
          'profileVisibility': profileVisibility ?? 'public',
          'showEmail': showEmail ?? false,
          'showRealName': showRealName ?? true,
          'allowFriendRequests': allowFriendRequests ?? true,
        });
      }
      
      await userRef.set(userData, SetOptions(merge: true));
      _logger.i('User profile ${isNewUser ? 'created' : 'updated'} successfully');
    } catch (e) {
      _logger.e('Error creating/updating user profile: $e');
      throw FirestoreException('Failed to save user profile: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      _logger.e('Error getting user profile: $e');
      throw FirestoreException('Failed to get user profile: $e');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;
    return await getUserProfile(currentUserId!);
  }

  /// Update user last active timestamp
  Future<void> updateLastActive() async {
    if (!isAuthenticated) return;
    
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Error updating last active: $e');
    }
  }

  /// Stream user profile changes
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.exists ? snapshot.data() : null;
    });
  }

  /// Get user profile by email
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

  // ====================================================================
  // USER SETTINGS MANAGEMENT
  // ====================================================================

  /// Create or update user settings
  Future<void> createOrUpdateUserSettings({
    required String uid,
    Map<String, dynamic>? notifications,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? privacy,
    Map<String, dynamic>? security,
  }) async {
    try {
      final settingsRef = _firestore.collection('user_settings').doc(uid);
      final now = FieldValue.serverTimestamp();
      
      // Check if document exists
      final docSnapshot = await settingsRef.get();
      final isNewSettings = !docSnapshot.exists;
      
      final settingsData = {
        'uid': uid,
        'updatedAt': now,
        if (notifications != null) 'notifications': notifications,
        if (preferences != null) 'preferences': preferences,
        if (privacy != null) 'privacy': privacy,
        if (security != null) 'security': security,
      };
      
      if (isNewSettings) {
        // Default settings for new users
        settingsData.addAll({
          'notifications': notifications ?? {
            'enabled': true,
            'pushNotifications': true,
            'emailNotifications': false,
            'soundNotifications': true,
            'friendRequests': true,
            'levelUp': true,
            'achievements': true,
            'challenges': true,
            'messages': true,
          },
          'preferences': preferences ?? {
            'language': 'English',
            'theme': 'dark',
            'soundEffects': true,
            'animations': true,
            'autoSave': true,
            'dataUsage': 'normal',
          },
          'privacy': privacy ?? {
            'profileVisibility': 'public',
            'showOnlineStatus': true,
            'allowMessages': 'friends',
            'showActivity': true,
            'dataSharing': false,
          },
          'security': security ?? {
            'twoFactorEnabled': false,
            'loginAlerts': true,
            'sessionTimeout': 30,
            'trustedDevices': [],
          },
        });
      }
      
      await settingsRef.set(settingsData, SetOptions(merge: true));
      _logger.i('User settings ${isNewSettings ? 'created' : 'updated'} successfully');
    } catch (e) {
      _logger.e('Error creating/updating user settings: $e');
      throw FirestoreException('Failed to save user settings: $e');
    }
  }

  /// Get user settings
  Future<Map<String, dynamic>?> getUserSettings(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['settings'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user settings: $e');
      return null;
    }
  }
  
  /// Update user setting
  Future<void> updateUserSetting(String uid, String key, dynamic value) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'settings.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('User setting updated: $key = $value');
    } catch (e) {
      _logger.e('Error updating user setting: $e');
      rethrow;
    }
  }

  /// Stream user settings changes
  Stream<Map<String, dynamic>?> streamUserSettings(String uid) {
    return _firestore.collection('user_settings').doc(uid).snapshots().map((snapshot) {
      return snapshot.exists ? snapshot.data() : null;
    });
  }

  // ====================================================================
  // USER ACTIVITY MANAGEMENT
  // ====================================================================

  /// Create or update user activity
  Future<void> createOrUpdateUserActivity({
    required String uid,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? progress,
    List<Map<String, dynamic>>? recentActivity,
    List<Map<String, dynamic>>? achievements,
  }) async {
    try {
      final activityRef = _firestore.collection('user_activity').doc(uid);
      final now = FieldValue.serverTimestamp();
      
      // Check if document exists
      final docSnapshot = await activityRef.get();
      final isNewActivity = !docSnapshot.exists;
      
      final activityData = {
        'uid': uid,
        'updatedAt': now,
        if (stats != null) 'stats': stats,
        if (progress != null) 'progress': progress,
        if (recentActivity != null) 'recentActivity': recentActivity,
        if (achievements != null) 'achievements': achievements,
      };
      
      if (isNewActivity) {
        // Default activity data for new users
        activityData.addAll({
          'stats': stats ?? {
            'totalSessions': 0,
            'totalTimeSpent': 0,
            'averageSessionTime': 0,
            'lastSession': now,
            'longestSession': 0,
            'dailyStreak': 0,
            'longestStreak': 0,
          },
          'progress': progress ?? {
            'completedChallenges': 0,
            'totalChallenges': 0,
            'skillLevel': 'Beginner',
            'badgesEarned': 0,
            'certificatesEarned': 0,
          },
          'recentActivity': recentActivity ?? [],
          'achievements': achievements ?? [],
        });
      }
      
      await activityRef.set(activityData, SetOptions(merge: true));
      _logger.i('User activity ${isNewActivity ? 'created' : 'updated'} successfully');
    } catch (e) {
      _logger.e('Error creating/updating user activity: $e');
      throw FirestoreException('Failed to save user activity: $e');
    }
  }

  /// Add new activity to user's recent activity
  Future<void> addUserActivity({
    required String uid,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final activityRef = _firestore.collection('user_activity').doc(uid);
      
      final newActivity = {
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        ...data,
      };
      
      await activityRef.update({
        'recentActivity': FieldValue.arrayUnion([newActivity]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _logger.i('Activity added successfully');
    } catch (e) {
      _logger.e('Error adding user activity: $e');
      throw FirestoreException('Failed to add activity: $e');
    }
  }

  /// Add achievement to user
  Future<void> addUserAchievement({
    required String uid,
    required String id,
    required String name,
    required String description,
    required int xpReward,
  }) async {
    try {
      final activityRef = _firestore.collection('user_activity').doc(uid);
      
      final achievement = {
        'id': id,
        'name': name,
        'description': description,
        'earnedAt': FieldValue.serverTimestamp(),
        'xpReward': xpReward,
      };
      
      await activityRef.update({
        'achievements': FieldValue.arrayUnion([achievement]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _logger.i('Achievement added successfully');
    } catch (e) {
      _logger.e('Error adding achievement: $e');
      throw FirestoreException('Failed to add achievement: $e');
    }
  }

  /// Get user activity
  Future<Map<String, dynamic>?> getUserActivity(String uid) async {
    try {
      final doc = await _firestore.collection('user_activity').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      _logger.e('Error getting user activity: $e');
      throw FirestoreException('Failed to get user activity: $e');
    }
  }

  // ====================================================================
  // USER SOCIAL MANAGEMENT
  // ====================================================================

  /// Create or update user social data
  Future<void> createOrUpdateUserSocial({
    required String uid,
    List<Map<String, dynamic>>? friends,
    Map<String, dynamic>? socialStats,
    List<Map<String, dynamic>>? groups,
  }) async {
    try {
      final socialRef = _firestore.collection('user_social').doc(uid);
      final now = FieldValue.serverTimestamp();
      
      // Check if document exists
      final docSnapshot = await socialRef.get();
      final isNewSocial = !docSnapshot.exists;
      
      final socialData = {
        'uid': uid,
        'updatedAt': now,
        if (friends != null) 'friends': friends,
        if (socialStats != null) 'socialStats': socialStats,
        if (groups != null) 'groups': groups,
      };
      
      if (isNewSocial) {
        // Default social data for new users
        socialData.addAll({
          'friends': friends ?? [],
          'socialStats': socialStats ?? {
            'friendsCount': 0,
            'friendRequestsSent': 0,
            'friendRequestsReceived': 0,
            'blockedUsers': 0,
          },
          'groups': groups ?? [],
        });
      }
      
      await socialRef.set(socialData, SetOptions(merge: true));
      _logger.i('User social data ${isNewSocial ? 'created' : 'updated'} successfully');
    } catch (e) {
      _logger.e('Error creating/updating user social: $e');
      throw FirestoreException('Failed to save user social data: $e');
    }
  }

  /// Add friend to user's friend list
  Future<void> addFriend({
    required String uid,
    required String friendUid,
    required String friendUsername,
  }) async {
    try {
      final socialRef = _firestore.collection('user_social').doc(uid);
      
      final friendData = {
        'uid': friendUid,
        'username': friendUsername,
        'addedAt': FieldValue.serverTimestamp(),
        'status': 'accepted',
      };
      
      await socialRef.update({
        'friends': FieldValue.arrayUnion([friendData]),
        'socialStats.friendsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _logger.i('Friend added successfully');
    } catch (e) {
      _logger.e('Error adding friend: $e');
      throw FirestoreException('Failed to add friend: $e');
    }
  }

  /// Remove friend from user's friend list
  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    try {
      final socialRef = _firestore.collection('user_social').doc(uid);
      final doc = await socialRef.get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final friends = List<Map<String, dynamic>>.from(data['friends'] ?? []);
        
        friends.removeWhere((friend) => friend['uid'] == friendUid);
        
        await socialRef.update({
          'friends': friends,
          'socialStats.friendsCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        _logger.i('Friend removed successfully');
      }
    } catch (e) {
      _logger.e('Error removing friend: $e');
      throw FirestoreException('Failed to remove friend: $e');
    }
  }

  /// Get user social data
  Future<Map<String, dynamic>?> getUserSocial(String uid) async {
    try {
      final doc = await _firestore.collection('user_social').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      _logger.e('Error getting user social: $e');
      throw FirestoreException('Failed to get user social data: $e');
    }
  }

  // ====================================================================
  // USER SUPPORT MANAGEMENT
  // ====================================================================

  /// Create support ticket
  Future<String> createSupportTicket({
    required String uid,
    required String subject,
    required String message,
  }) async {
    try {
      final ticketId = _firestore.collection('user_support').doc().id;
      final supportRef = _firestore.collection('user_support').doc(uid);
      
      final ticket = {
        'id': ticketId,
        'subject': subject,
        'message': message,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'responses': [],
      };
      
      await supportRef.set({
        'uid': uid,
        'tickets': FieldValue.arrayUnion([ticket]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _logger.i('Support ticket created successfully');
      return ticketId;
    } catch (e) {
      _logger.e('Error creating support ticket: $e');
      throw FirestoreException('Failed to create support ticket: $e');
    }
  }

  /// Submit bug report
  Future<String> submitBugReport({
    required String uid,
    required String description,
    String severity = 'medium',
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final bugId = _firestore.collection('user_support').doc().id;
      final supportRef = _firestore.collection('user_support').doc(uid);
      
      final bugReport = {
        'id': bugId,
        'description': description,
        'severity': severity,
        'status': 'reported',
        'createdAt': FieldValue.serverTimestamp(),
        'deviceInfo': deviceInfo ?? {},
      };
      
      await supportRef.set({
        'uid': uid,
        'bugReports': FieldValue.arrayUnion([bugReport]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _logger.i('Bug report submitted successfully');
      return bugId;
    } catch (e) {
      _logger.e('Error submitting bug report: $e');
      throw FirestoreException('Failed to submit bug report: $e');
    }
  }

  /// Get user support data
  Future<Map<String, dynamic>?> getUserSupport(String uid) async {
    try {
      final doc = await _firestore.collection('user_support').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      _logger.e('Error getting user support: $e');
      throw FirestoreException('Failed to get user support data: $e');
    }
  }

  // ====================================================================
  // USER DEVICES MANAGEMENT
  // ====================================================================

  /// Register user device
  Future<void> registerUserDevice({
    required String uid,
    required String deviceId,
    required String name,
    required String platform,
    required String version,
    required String appVersion,
    String? fcmToken,
    bool trusted = false,
  }) async {
    try {
      final devicesRef = _firestore.collection('user_devices').doc(uid);
      
      final device = {
        'deviceId': deviceId,
        'name': name,
        'platform': platform,
        'version': version,
        'appVersion': appVersion,
        'lastUsed': FieldValue.serverTimestamp(),
        'isActive': true,
        'trusted': trusted,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
      
      await devicesRef.set({
        'uid': uid,
        'devices': FieldValue.arrayUnion([device]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _logger.i('Device registered successfully');
    } catch (e) {
      _logger.e('Error registering device: $e');
      throw FirestoreException('Failed to register device: $e');
    }
  }

  /// Update device last used
  Future<void> updateDeviceLastUsed({
    required String uid,
    required String deviceId,
  }) async {
    try {
      final devicesRef = _firestore.collection('user_devices').doc(uid);
      final doc = await devicesRef.get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final devices = List<Map<String, dynamic>>.from(data['devices'] ?? []);
        
        for (var device in devices) {
          if (device['deviceId'] == deviceId) {
            device['lastUsed'] = FieldValue.serverTimestamp();
            device['isActive'] = true;
            break;
          }
        }
        
        await devicesRef.update({
          'devices': devices,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _logger.e('Error updating device last used: $e');
    }
  }

  /// Get user devices
  Future<Map<String, dynamic>?> getUserDevices(String uid) async {
    try {
      final doc = await _firestore.collection('user_devices').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      _logger.e('Error getting user devices: $e');
      throw FirestoreException('Failed to get user devices: $e');
    }
  }

  // ====================================================================
  // USER BACKUP MANAGEMENT
  // ====================================================================

  /// Create user backup
  Future<void> createUserBackup({
    required String uid,
    required Map<String, dynamic> backupData,
    String version = '1.0',
  }) async {
    try {
      final backupRef = _firestore.collection('user_backup').doc(uid);
      
      final backup = {
        'uid': uid,
        'backupData': backupData,
        'backupMetadata': {
          'version': version,
          'createdAt': FieldValue.serverTimestamp(),
          'size': backupData.toString().length,
          'checksum': backupData.hashCode.toString(),
        },
        'autoBackup': {
          'enabled': true,
          'frequency': 'daily',
          'lastBackup': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await backupRef.set(backup, SetOptions(merge: true));
      _logger.i('User backup created successfully');
    } catch (e) {
      _logger.e('Error creating user backup: $e');
      throw FirestoreException('Failed to create user backup: $e');
    }
  }

  /// Get user backup
  Future<Map<String, dynamic>?> getUserBackup(String uid) async {
    try {
      final doc = await _firestore.collection('user_backup').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      _logger.e('Error getting user backup: $e');
      throw FirestoreException('Failed to get user backup: $e');
    }
  }

  // ====================================================================
  // BATCH OPERATIONS
  // ====================================================================

  /// Initialize all user collections for a new user
  Future<void> initializeNewUser({
    required String uid,
    required String email,
    String? username,
    String? displayName,
    String? profileImageUrl,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // User Profile
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
        'isPremiumUser': false,
        'isVerified': false,
        'friendsCount': 0,
        'followersCount': 0,
        'followingCount': 0,
        'profileVisibility': 'public',
        'showEmail': false,
        'showRealName': true,
        'allowFriendRequests': true,
      });
      
      // User Settings
      final settingsRef = _firestore.collection('user_settings').doc(uid);
      batch.set(settingsRef, {
        'uid': uid,
        'notifications': {
          'enabled': true,
          'pushNotifications': true,
          'emailNotifications': false,
          'soundNotifications': true,
          'friendRequests': true,
          'levelUp': true,
          'achievements': true,
          'challenges': true,
          'messages': true,
        },
        'preferences': {
          'language': 'English',
          'theme': 'dark',
          'soundEffects': true,
          'animations': true,
          'autoSave': true,
          'dataUsage': 'normal',
        },
        'privacy': {
          'profileVisibility': 'public',
          'showOnlineStatus': true,
          'allowMessages': 'friends',
          'showActivity': true,
          'dataSharing': false,
        },
        'security': {
          'twoFactorEnabled': false,
          'loginAlerts': true,
          'sessionTimeout': 30,
          'trustedDevices': [],
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // User Activity
      final activityRef = _firestore.collection('user_activity').doc(uid);
      batch.set(activityRef, {
        'uid': uid,
        'stats': {
          'totalSessions': 0,
          'totalTimeSpent': 0,
          'averageSessionTime': 0,
          'lastSession': FieldValue.serverTimestamp(),
          'longestSession': 0,
          'dailyStreak': 0,
          'longestStreak': 0,
        },
        'progress': {
          'completedChallenges': 0,
          'totalChallenges': 0,
          'skillLevel': 'Beginner',
          'badgesEarned': 0,
          'certificatesEarned': 0,
        },
        'recentActivity': [],
        'achievements': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // User Social
      final socialRef = _firestore.collection('user_social').doc(uid);
      batch.set(socialRef, {
        'uid': uid,
        'friends': [],
        'socialStats': {
          'friendsCount': 0,
          'friendRequestsSent': 0,
          'friendRequestsReceived': 0,
          'blockedUsers': 0,
        },
        'groups': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
      _logger.i('New user initialized successfully');
    } catch (e) {
      _logger.e('Error initializing new user: $e');
      throw FirestoreException('Failed to initialize new user: $e');
    }
  }

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(String uid) async {
    try {
      final batch = _firestore.batch();
      
      // Delete from all collections
      final collections = [
        'users',
        'user_settings',
        'user_activity',
        'user_social',
        'user_support',
        'user_devices',
        'user_backup',
      ];
      
      for (final collection in collections) {
        final docRef = _firestore.collection(collection).doc(uid);
        batch.delete(docRef);
      }
      
      await batch.commit();
      _logger.i('All user data deleted successfully');
    } catch (e) {
      _logger.e('Error deleting user data: $e');
      throw FirestoreException('Failed to delete user data: $e');
    }
  }

  // ====================================================================
  // UTILITY METHODS
  // ====================================================================

  /// Check if user document exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      _logger.e('Error checking if user exists: $e');
      return false;
    }
  }

  /// Get user count
  Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.size;
    } catch (e) {
      _logger.e('Error getting user count: $e');
      return 0;
    }
  }

  /// Search users by username
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: '${query}z')
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error searching users: $e');
      return [];
    }
  }

  /// Get user's rank based on XP points among all users
  /// Returns the position (1st, 2nd, 3rd, etc.) of the user
  Future<int> getUserRank(String uid) async {
    try {
      // First get the current user's XP points
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return 1;
      
      final userData = userDoc.data()!;
      final userXP = userData['xpPoints'] ?? 0;
      
      // Count how many users have more XP points than the current user
      final higherXPQuery = await _firestore
          .collection('users')
          .where('xpPoints', isGreaterThan: userXP)
          .get();
      
      // User's rank is the count of users with higher XP + 1
      return higherXPQuery.docs.length + 1;
    } catch (e) {
      _logger.e('Error getting user rank: $e');
      return 1; // Default to rank 1 if error occurs
    }
  }

  /// Get leaderboard of top users by XP points
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('xpPoints', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error getting leaderboard: $e');
      return [];
    }
  }
}

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirestoreException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'FirestoreException: $message';
}


