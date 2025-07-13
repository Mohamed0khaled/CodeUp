import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:codeup/services/user_service.dart';
import 'package:codeup/widgets/profile_image_widget.dart';
import 'package:get/get.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late AnimationController _scaleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _showFullRankings = false;
  final userService = Get.find<UserService>();
  List<Map<String, dynamic>> _globalLeaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    
    // Start trophy rotation
    _rotateController.repeat();

    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return fullName;
    final spaceIndex = fullName.indexOf(' ');
    return spaceIndex != -1 ? fullName.substring(0, spaceIndex) : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildTopChampions(),
                        ),
                        const SizedBox(height: 24),
                        _buildFullRankings(),
                        const SizedBox(height: 24),
                        _buildYourProgress(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Algorithm Sprint',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _loadLeaderboardData();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopChampions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              RotationTransition(
                turns: _rotateAnimation,
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TOP CHAMPIONS',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _isLoading 
                ? [
                    const SizedBox(width: 70, height: 70, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2)),
                    const SizedBox(width: 80, height: 80, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 3)),
                    const SizedBox(width: 70, height: 70, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2)),
                  ]
                : [
                    if (_globalLeaderboard.length > 1) _buildChampionItem(
                      _getFirstName(_globalLeaderboard[1]['displayName'] ?? _globalLeaderboard[1]['username'] ?? 'Player'), 
                      '${_globalLeaderboard[1]['xpPoints']}', 
                      2, 
                      const Color(0xFF64748B),
                      profileImageUrl: _globalLeaderboard[1]['uid'] == userService.currentUserId 
                          ? userService.bestProfileImageUrl 
                          : _globalLeaderboard[1]['profileImageUrl'],
                    ) else _buildChampionItem('Player 2', '0', 2, const Color(0xFF64748B)),
                    if (_globalLeaderboard.isNotEmpty) _buildChampionItem(
                      _getFirstName(_globalLeaderboard[0]['displayName'] ?? _globalLeaderboard[0]['username'] ?? 'Player'), 
                      '${_globalLeaderboard[0]['xpPoints']}', 
                      1, 
                      Colors.amber,
                      profileImageUrl: _globalLeaderboard[0]['uid'] == userService.currentUserId 
                          ? userService.bestProfileImageUrl 
                          : _globalLeaderboard[0]['profileImageUrl'],
                    ) else _buildChampionItem('Player 1', '0', 1, Colors.amber),
                    if (_globalLeaderboard.length > 2) _buildChampionItem(
                      _getFirstName(_globalLeaderboard[2]['displayName'] ?? _globalLeaderboard[2]['username'] ?? 'Player'), 
                      '${_globalLeaderboard[2]['xpPoints']}', 
                      3, 
                      const Color(0xFFCD7F32),
                      profileImageUrl: _globalLeaderboard[2]['uid'] == userService.currentUserId 
                          ? userService.bestProfileImageUrl 
                          : _globalLeaderboard[2]['profileImageUrl'],
                    ) else _buildChampionItem('Player 3', '0', 3, const Color(0xFFCD7F32)),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildChampionItem(String name, String points, int rank, Color color, {String? profileImageUrl}) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 800 + (rank * 200)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: SizedBox(
              width: rank == 1 ? 85 : 75, // Reduced fixed width for each champion item
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        width: rank == 1 ? 80 : 70,
                        height: rank == 1 ? 80 : 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: rank == 1 
                                ? [Colors.amber, Colors.orange]
                                : rank == 2
                                    ? [const Color(0xFF64748B), const Color(0xFF475569)]
                                    : [const Color(0xFFCD7F32), const Color(0xFFA0522D)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: ProfileImageWidget(
                            imageUrl: profileImageUrl,
                            fallbackText: name,
                            size: rank == 1 ? 80 : 70,
                            borderWidth: 0,
                            backgroundColor: Colors.transparent,
                            textColor: Colors.white,
                            fontSize: rank == 1 ? 28 : 24,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: rank == 1 ? -5 : 0,
                        child: Container(
                          width: rank == 1 ? 30 : 25,
                          height: rank == 1 ? 30 : 25,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0A0E1A),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: rank == 1
                                ? const Icon(
                                    Icons.crop,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Fixed height container for name to prevent layout shifts
                  SizedBox(
                    height: 20, // Fixed height for name
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    points,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'points',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullRankings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Global Rankings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_globalLeaderboard.length} players',
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Show leaderboard entries (skipping top 3 already shown above)
          if (!_isLoading) ...[
            ...(_globalLeaderboard.skip(3).map((user) => 
              _buildRankingItem(
                user['displayName'] ?? user['username'] ?? 'Anonymous',
                user['userLevel'] ?? 'Level 1',
                '${user['xpPoints']}',
                user['rank'] ?? 0,
                _getColorForRank(user['rank'] ?? 0),
                isCurrentUser: user['uid'] == userService.currentUserId,
                profileImageUrl: user['uid'] == userService.currentUserId 
                    ? userService.bestProfileImageUrl 
                    : user['profileImageUrl'],
              )
            ).toList()),
            
            // Show current user if not in top rankings
            if (userService.userRank > 10) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Your Position',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                  ],
                ),
              ),
              Obx(() => _buildRankingItem(
                userService.currentUser?.displayName ?? userService.currentUser?.username ?? 'You',
                userService.currentUser?.userLevel ?? 'Level 1',
                '${userService.xpPoints}',
                userService.userRank,
                const Color(0xFF8B5CF6),
                isCurrentUser: true,
                profileImageUrl: userService.bestProfileImageUrl,
              )),
            ],
          ] else ...[
            // Loading state
            ...List.generate(4, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _showFullRankings = !_showFullRankings;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showFullRankings ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showFullRankings ? 'Show Less' : 'Load More Rankings',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildRankingItem(String name, String level, String points, int rank, Color color, {bool isCurrentUser = false, String? profileImageUrl}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (rank * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentUser 
                      ? color.withOpacity(0.4)
                      : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ProfileImageWidget(
                    imageUrl: profileImageUrl,
                    fallbackText: name,
                    size: 40,
                    borderWidth: 0,
                    backgroundColor: color.withOpacity(0.2),
                    textColor: Colors.white,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: isCurrentUser ? color : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '●',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        points,
                        style: TextStyle(
                          color: isCurrentUser ? color : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'points',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ));
        },
      );
  }

  Widget _buildYourProgress() {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.2),
            const Color(0xFF059669).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'YOUR PROGRESS',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userService.xpPoints}',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total XP Points',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() => Icon(
                          userService.userRank <= _globalLeaderboard.length ? Icons.star : Icons.trending_up,
                          color: const Color(0xFF10B981),
                          size: 20,
                        )),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          '#${userService.userRank}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    Text(
                      'Global Rank',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Future<void> _loadLeaderboardData() async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });
      
      // Get real leaderboard data from UserService
      final leaderboardData = await userService.getLeaderboard(limit: 50);
      
      if (!mounted) return;
      
      // Convert UserData objects to Map format for easier use
      final List<Map<String, dynamic>> leaderboard = [];
      for (int i = 0; i < leaderboardData.length; i++) {
        final user = leaderboardData[i];
        leaderboard.add({
          'username': user.username,
          'displayName': user.displayName,
          'xpPoints': user.xpPoints,
          'userLevel': user.userLevel,
          'rank': i + 1,
          'isVerified': user.isVerified,
          'uid': user.uid,
          'profileImageUrl': user.profileImageUrl,
        });
      }
      
      // Update user's current rank
      await userService.fetchUserRank();
      
      if (!mounted) return;
      
      setState(() {
        _globalLeaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getColorForRank(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return const Color(0xFF64748B);
      case 3: return const Color(0xFFCD7F32);
      case 4: return const Color(0xFFEC4899);
      case 5: return const Color(0xFF06B6D4);
      case 6: return const Color(0xFF10B981);
      case 7: return const Color(0xFFEF4444);
      default: return Color.fromRGBO(
        ((rank * 47) % 255), 
        ((rank * 73) % 255), 
        ((rank * 97) % 255), 
        1.0
      );
    }
  }
}