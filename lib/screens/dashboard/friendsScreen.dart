import 'package:codeup/services/user_service.dart';
import 'package:codeup/models/fireStore.dart';
import 'package:codeup/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late TextEditingController _searchController;

  final userService = Get.find<UserService>();
  
  // State variables for real data
  List<UserData> _friends = [];
  List<UserData> _suggestedFriends = [];
  List<UserData> _searchResults = [];
  Map<String, bool> _friendStatus = {}; // Track friend status
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    
    // Load initial data
    _loadFriendsData();
  }

  Future<void> _loadFriendsData() async {
    if (!userService.isAuthenticated || !mounted) return;
    
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      
      debugPrint('Loading friends data...');
      
      // Load friends and suggested friends with individual error handling
      List<UserData> friends = [];
      List<UserData> suggestedFriends = [];
      
      try {
        friends = await userService.getFriends();
        debugPrint('Friends loaded: ${friends.length}');
      } catch (e) {
        debugPrint('Error loading friends: $e');
        friends = [];
      }
      
      try {
        suggestedFriends = await userService.getSuggestedFriends(limit: 10);
        debugPrint('Suggested friends loaded: ${suggestedFriends.length}');
      } catch (e) {
        debugPrint('Error loading suggested friends: $e');
        suggestedFriends = [];
      }
      
      if (!mounted) return;
      setState(() {
        _friends = friends;
        _suggestedFriends = suggestedFriends;
        _isLoading = false;
      });
      
      debugPrint('Friends data loaded successfully');
    } catch (e, stackTrace) {
      debugPrint('Error loading friends data: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _friends = [];
        _suggestedFriends = [];
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }
    
    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    
    try {
      final results = await userService.searchUsers(query: query.toLowerCase(), limit: 20);
      
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  Future<void> _addFriend(UserData user) async {
    // Prevent multiple simultaneous friend requests
    if (_friendStatus[user.uid] == true) {
      if (mounted) {
        Get.snackbar(
          'Info',
          'Friend request already sent or user is already a friend.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      return;
    }

    if (!mounted) return;

    try {
      debugPrint('=== ADD FRIEND DEBUG START ===');
      debugPrint('User ID: ${user.uid}');
      debugPrint('User Name: ${user.displayName ?? user.username ?? user.email}');
      debugPrint('Mounted: $mounted');
      debugPrint('Authenticated: ${userService.isAuthenticated}');
      
      // Check authentication first
      if (!userService.isAuthenticated) {
        debugPrint('ERROR: User not authenticated');
        if (mounted) {
          Get.snackbar(
            'Error',
            'You must be logged in to add friends.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }
      
      debugPrint('Calling userService.addFriend...');
      
      // Call the service method with full error wrapping
      bool success = false;
      try {
        success = await userService.addFriend(
          friendUid: user.uid,
          friendUsername: user.username ?? user.email,
        );
        debugPrint('Service call completed. Success: $success');
      } catch (serviceError, serviceStack) {
        debugPrint('SERVICE ERROR: $serviceError');
        debugPrint('SERVICE STACK: $serviceStack');
        
        if (mounted) {
          Get.snackbar(
            'Service Error',
            'Service error: ${serviceError.toString()}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }
      
      if (!mounted) {
        debugPrint('Widget unmounted after service call');
        return;
      }
      
      if (success) {
        debugPrint('Updating local state...');
        try {
          setState(() {
            _friendStatus[user.uid] = true;
            // Simple local update
            if (_suggestedFriends.contains(user)) {
              _suggestedFriends.remove(user);
            }
            if (!_friends.contains(user)) {
              _friends.add(user);
            }
          });
          debugPrint('Local state updated successfully');
        } catch (stateError, stateStack) {
          debugPrint('STATE ERROR: $stateError');
          debugPrint('STATE STACK: $stateStack');
        }
        
        // Show success message
        if (mounted) {
          Get.snackbar(
            'Success',
            'Friend added successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
        
        debugPrint('=== ADD FRIEND DEBUG SUCCESS ===');
        
      } else {
        debugPrint('Service returned false - operation failed');
        if (mounted) {
          Get.snackbar(
            'Error',
            'Failed to add friend. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
      
    } catch (e, stackTrace) {
      debugPrint('=== ADD FRIEND DEBUG ERROR ===');
      debugPrint('MAIN ERROR: $e');
      debugPrint('MAIN STACK: $stackTrace');
      
      if (mounted) {
        Get.snackbar(
          'Critical Error',
          'Unexpected error: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      debugPrint('=== ADD FRIEND DEBUG END ===');
    }
  }
  
  Future<void> _removeFriend(UserData user) async {
    try {
      debugPrint('Removing friend: ${user.uid} - ${user.displayName ?? user.username}');
      
      // Check authentication first
      if (!userService.isAuthenticated) {
        Get.snackbar(
          'Error',
          'You must be logged in to remove friends.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      final success = await userService.removeFriend(friendUid: user.uid);
      
      debugPrint('Remove friend result: $success');
      
      if (!mounted) return;
      
      if (success) {
        setState(() {
          _friendStatus[user.uid] = false;
          // Remove from local lists to update UI immediately
          _friends.removeWhere((friend) => friend.uid == user.uid);
          _suggestedFriends.removeWhere((friend) => friend.uid == user.uid);
        });
        
        // Show success message
        Get.snackbar(
          'Success',
          'Friend removed successfully!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        
        debugPrint('Friend removed from local state');
        
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove friend. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error removing friend: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        Get.snackbar(
          'Error',
          'An error occurred while removing friend: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
  
  bool _isOnline(UserData user) {
    if (user.lastActiveAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(user.lastActiveAt!);
    return difference.inMinutes < 5; // Online if active within 5 minutes
  }
  
  String _getLastSeenText(UserData user) {
    if (user.lastActiveAt == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(user.lastActiveAt!);
    
    if (difference.inMinutes < 5) return 'Online';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return 'Long time ago';
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1D29),
              Color(0xFF2D3748),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  Expanded(
                    child: _buildFriendsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Text(
            'Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Show add friend dialog or search
              _showAddFriendDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Add Friend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          _searchQuery = value;
          _searchUsers(value);
        },
        decoration: InputDecoration(
          hintText: 'Search friends...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          suffixIcon: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    final onlineFriends = _friends.where((user) => _isOnline(user)).toList();
    final offlineFriends = _friends.where((user) => !_isOnline(user)).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Online Friends
        if (onlineFriends.isNotEmpty) ...[
          _buildSectionHeader('Online', onlineFriends.length, Colors.green),
          const SizedBox(height: 12),
          ...onlineFriends.asMap().entries.map((entry) {
            final index = entry.key;
            final friend = entry.value;
            return _buildFriendCard(friend, true, index);
          }).toList(),
          const SizedBox(height: 24),
        ],
        
        // Offline Friends
        if (offlineFriends.isNotEmpty) ...[
          _buildSectionHeader('Offline', offlineFriends.length, Colors.grey),
          const SizedBox(height: 12),
          ...offlineFriends.asMap().entries.map((entry) {
            final index = entry.key;
            final friend = entry.value;
            return _buildFriendCard(friend, false, index);
          }).toList(),
          const SizedBox(height: 24),
        ],
        
        // Suggested Friends
        if (_suggestedFriends.isNotEmpty) ...[
          _buildSectionHeader('Suggested Friends', _suggestedFriends.length, Colors.blue),
          const SizedBox(height: 12),
          ..._suggestedFriends.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return _buildSuggestedFriendCard(user, index);
          }).toList(),
          const SizedBox(height: 20),
        ],
        
        // Empty state
        if (_friends.isEmpty && _suggestedFriends.isEmpty) ...[
          const SizedBox(height: 50),
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No friends yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Search for users to add as friends',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found for "$_searchQuery"',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSectionHeader('Search Results', _searchResults.length, Colors.orange),
        const SizedBox(height: 12),
        ..._searchResults.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return _buildSearchResultCard(user, index);
        }).toList(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$title ($count)',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendCard(UserData user, bool isOnline, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOnline 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOnline
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ProfileImageWidget(
                        imageUrl: user.bestProfileImageUrl,
                        fallbackText: user.displayText,
                        size: 48,
                        backgroundColor: isOnline 
                            ? const Color(0xFF3B82F6)
                            : Colors.grey.shade600,
                        fontSize: 20,
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1A1D29),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.displayName ?? user.username ?? user.email,
                                style: TextStyle(
                                  color: isOnline ? Colors.white : Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF3B82F6),
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLastSeenText(user),
                          style: TextStyle(
                            color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOnline)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Challenge friend
                            Get.snackbar(
                              'Challenge Sent',
                              'Challenge sent to ${user.displayName ?? user.username}!',
                              backgroundColor: const Color(0xFF06B6D4),
                              colorText: Colors.white,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showRemoveFriendDialog(user);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_remove,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedFriendCard(UserData user, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  ProfileImageWidget(
                    imageUrl: user.bestProfileImageUrl,
                    fallbackText: user.displayText,
                    size: 48,
                    backgroundColor: const Color(0xFF3B82F6),
                    fontSize: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.displayName ?? user.username ?? user.email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF3B82F6),
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${user.userLevel ?? '1'} • ${user.xpPoints} XP',
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _addFriend(user);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultCard(UserData user, int index) {
    final isFriend = _friends.any((friend) => friend.uid == user.uid);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  ProfileImageWidget(
                    imageUrl: user.bestProfileImageUrl,
                    fallbackText: user.displayText,
                    size: 48,
                    backgroundColor: const Color(0xFFF59E0B),
                    fontSize: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.displayName ?? user.username ?? user.email,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (user.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF3B82F6),
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${user.userLevel ?? '1'} • ${user.xpPoints} XP',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isFriend) {
                        _showRemoveFriendDialog(user);
                      } else {
                        _addFriend(user);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isFriend ? Colors.red : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isFriend ? 'Remove' : 'Add',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Add Friend',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Use the search bar above to find and add friends!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveFriendDialog(UserData user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Remove Friend',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${user.displayName ?? user.username} from your friends?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeFriend(user);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
