/// User Data Model for CodeUp Application
class UserData {
  final String uid;
  final String email;
  final String? username;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? profileImagePath;
  final String? userId;
  final String? userLevel;
  final int xpPoints;
  final int rank;
  final bool isPremiumUser;
  final bool isVerified;
  final int friendsCount;
  final int followersCount;
  final int followingCount;
  final String profileVisibility;
  final bool showEmail;
  final bool showRealName;
  final bool allowFriendRequests;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActiveAt;
  final String accountStatus;

  UserData({
    required this.uid,
    required this.email,
    this.username,
    this.displayName,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.profileImagePath,
    this.userId,
    this.userLevel,
    this.xpPoints = 0,
    this.rank = 0,
    this.isPremiumUser = false,
    this.isVerified = false,
    this.friendsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.profileVisibility = 'public',
    this.showEmail = false,
    this.showRealName = false,
    this.allowFriendRequests = true,
    this.createdAt,
    this.updatedAt,
    this.lastActiveAt,
    this.accountStatus = 'active',
  });

  /// Create UserData from Firestore document
  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      username: data['username'],
      displayName: data['displayName'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      profileImageUrl: data['profileImageUrl'],
      profileImagePath: data['profileImagePath'],
      userId: data['userId'],
      userLevel: data['userLevel'],
      xpPoints: data['xpPoints'] ?? 0,
      rank: data['rank'] ?? 0,
      isPremiumUser: data['isPremiumUser'] ?? false,
      isVerified: data['isVerified'] ?? false,
      friendsCount: data['friendsCount'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      profileVisibility: data['profileVisibility'] ?? 'public',
      showEmail: data['showEmail'] ?? false,
      showRealName: data['showRealName'] ?? false,
      allowFriendRequests: data['allowFriendRequests'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      lastActiveAt: data['lastActiveAt']?.toDate(),
      accountStatus: data['accountStatus'] ?? 'active',
    );
  }

  /// Convert UserData to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'profileImagePath': profileImagePath,
      'userId': userId,
      'userLevel': userLevel,
      'xpPoints': xpPoints,
      'rank': rank,
      'isPremiumUser': isPremiumUser,
      'isVerified': isVerified,
      'friendsCount': friendsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'profileVisibility': profileVisibility,
      'showEmail': showEmail,
      'showRealName': showRealName,
      'allowFriendRequests': allowFriendRequests,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastActiveAt': lastActiveAt,
      'accountStatus': accountStatus,
    };
  }

  /// Get best available profile image URL
  String? get bestProfileImageUrl {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return profileImageUrl;
    }
    return null;
  }

  /// Get display text for UI
  String get displayText {
    return displayName ?? username ?? firstName ?? email;
  }

  /// Copy with method for immutable updates
  UserData copyWith({
    String? uid,
    String? email,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    String? accountStatus,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      userId: userId ?? this.userId,
      userLevel: userLevel ?? this.userLevel,
      xpPoints: xpPoints ?? this.xpPoints,
      rank: rank ?? this.rank,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      isVerified: isVerified ?? this.isVerified,
      friendsCount: friendsCount ?? this.friendsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showEmail: showEmail ?? this.showEmail,
      showRealName: showRealName ?? this.showRealName,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }

  @override
  String toString() {
    return 'UserData(uid: $uid, email: $email, displayName: $displayName, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

/// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final DateTime earnedAt;
  final int xpReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.earnedAt,
    required this.xpReward,
  });

  factory Achievement.fromFirestore(Map<String, dynamic> data) {
    return Achievement(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      earnedAt: data['earnedAt']?.toDate() ?? DateTime.now(),
      xpReward: data['xpReward'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'earnedAt': earnedAt,
      'xpReward': xpReward,
    };
  }
}

/// Activity Model
class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  factory Activity.fromFirestore(Map<String, dynamic> data) {
    return Activity(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'type': type,
    };
  }
}
