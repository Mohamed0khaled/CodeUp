import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:codeup/services/tournament_service.dart';
import 'dart:math';

class TournamentDetailsScreen extends StatefulWidget {
  final String tournamentId;
  
  const TournamentDetailsScreen({
    Key? key,
    required this.tournamentId,
  }) : super(key: key);

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _countdownController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countdownAnimation;
  late Animation<double> _floatingAnimation;

  final TournamentService _tournamentService = Get.find<TournamentService>();
  
  bool _isJoined = false;
  bool _isJoining = false;
  Map<String, dynamic>? tournamentData;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTournamentData();
    _checkIfJoined();
  }

  Future<void> _loadTournamentData() async {
    final data = await _tournamentService.getTournamentById(widget.tournamentId);
    if (data != null) {
      setState(() {
        tournamentData = data;
      });
    }
  }

  Future<void> _checkIfJoined() async {
    final isJoined = await _tournamentService.hasUserJoinedTournament(widget.tournamentId);
    setState(() {
      _isJoined = isJoined;
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _countdownController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _countdownAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _countdownController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _countdownController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _countdownController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (tournamentData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1D29),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF06B6D4),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: Container(
        decoration: _buildTechBackground(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildTournamentCard(),
                          const SizedBox(height: 24),
                          _buildCountdownTimer(),
                          const SizedBox(height: 24),
                          _buildPrizePool(),
                          const SizedBox(height: 24),
                          _buildParticipants(),
                          const SizedBox(height: 24),
                          _buildRulesAndFormat(),
                          const SizedBox(height: 24),
                          _buildJoinButton(),
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
      ),
    );
  }

  BoxDecoration _buildTechBackground() {
    return BoxDecoration(
      gradient: const RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: [
          Color(0xFF2D3748),
          Color(0xFF1A1D29),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOURNAMENT DETAILS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Join the competition',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Floating settings icon
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, sin(_floatingAnimation.value * 2 * pi) * 2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.share,
                    color: Color(0xFF06B6D4),
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientForDifficulty(tournamentData!['difficulty'] ?? 'Medium'),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getGradientForDifficulty(tournamentData!['difficulty'] ?? 'Medium')[0].withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.code,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Text(
                  'OPEN',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tournamentData!['title'] ?? 'Tournament',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatStartDate(tournamentData!['startDate']),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule,
                color: Color(0xFF06B6D4),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'TIME TO START',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit('02', 'DAYS'),
              _buildTimeUnit('14', 'HOURS'),
              _buildTimeUnit('37', 'MINS'),
              _buildTimeUnit('42', 'SECS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return AnimatedBuilder(
      animation: _countdownAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: label == 'SECS' ? _countdownAnimation.value : 1.0,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrizePool() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'PRIZE POOL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '\$${(tournamentData!['prizePool'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Total Prize Money',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: _buildPrizeWidgets(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrizeWidgets() {
    final prizes = tournamentData!['prizes'];
    if (prizes == null) {
      // Create default prizes based on prizePool
      final prizePool = tournamentData!['prizePool'] ?? 0;
      final firstPrize = ((tournamentData!['prizes']?['first'] ?? 50) / 100 * prizePool).round();
      final secondPrize = ((tournamentData!['prizes']?['second'] ?? 30) / 100 * prizePool).round();
      final thirdPrize = ((tournamentData!['prizes']?['third'] ?? 20) / 100 * prizePool).round();
      
      return [
        _buildPrizeItem('1st Place', firstPrize, const Color(0xFFFFD700), Icons.looks_one),
        _buildPrizeItem('2nd Place', secondPrize, const Color(0xFFC0C0C0), Icons.looks_two),
        _buildPrizeItem('3rd Place', thirdPrize, const Color(0xFFCD7F32), Icons.looks_3),
      ];
    }
    
    // If prizes is a map with first/second/third percentages
    if (prizes is Map && prizes.containsKey('first')) {
      final prizePool = tournamentData!['prizePool'] ?? 0;
      final firstPrize = ((prizes['first'] ?? 50) / 100 * prizePool).round();
      final secondPrize = ((prizes['second'] ?? 30) / 100 * prizePool).round();
      final thirdPrize = ((prizes['third'] ?? 20) / 100 * prizePool).round();
      
      return [
        _buildPrizeItem('1st Place', firstPrize, const Color(0xFFFFD700), Icons.looks_one),
        _buildPrizeItem('2nd Place', secondPrize, const Color(0xFFC0C0C0), Icons.looks_two),
        _buildPrizeItem('3rd Place', thirdPrize, const Color(0xFFCD7F32), Icons.looks_3),
      ];
    }
    
    // If prizes is a list (legacy format)
    if (prizes is List) {
      return prizes.map<Widget>((prize) {
        return _buildPrizeItem(
          prize['position'] ?? 'Prize',
          prize['amount'] ?? 0,
          prize['color'] ?? const Color(0xFFFFD700),
          prize['icon'] ?? Icons.emoji_events,
        );
      }).toList();
    }
    
    return [];
  }

  Widget _buildPrizeItem(String position, int amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              position,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipants() {
    final participants = tournamentData!['subscribers'] ?? [];
    final totalParticipants = tournamentData!['participants'] ?? 0;
    final maxParticipants = tournamentData!['maxParticipants'] ?? 100;
    final percentage = (totalParticipants / maxParticipants * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people,
                color: Color(0xFF06B6D4),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'PARTICIPANTS ($totalParticipants/$maxParticipants)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalParticipants / maxParticipants,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'All users currently registered',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...participants.take(3).map((participant) => _buildParticipantItem(participant)).toList(),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // Show all participants
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Center(
                child: Text(
                  'View All Participants',
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(Map<String, dynamic> participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                participant['avatar'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      participant['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (participant['badge'] != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: participant['badge'] == 1 
                              ? const Color(0xFFFFD700)
                              : participant['badge'] == 2 
                                  ? const Color(0xFFC0C0C0)
                                  : const Color(0xFFCD7F32),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${participant['badge']}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Rank ${participant['rank']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Level ${participant['level']}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${participant['rank']} XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRulesAndFormat() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rule,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'RULES & FORMAT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildRulesList(),
        ],
      ),
    );
  }

  Widget _buildRuleItem(Map<String, dynamic> rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              rule['icon'],
              color: const Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rule['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      rule['description'],
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rule['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _joinTournament,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isJoining)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isJoined ? 'JOINED' : _isJoining ? 'JOINING...' : 'JOIN TOURNAMENT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinTournament() async {
    if (_isJoined || _isJoining) return;

    HapticFeedback.lightImpact();
    
    setState(() {
      _isJoining = true;
    });

    // Join tournament using Firebase
    final success = await _tournamentService.joinTournament(widget.tournamentId);

    if (mounted) {
      setState(() {
        _isJoining = false;
        _isJoined = success;
      });
      
      if (success) {
        // Reload tournament data to update participant count
        await _loadTournamentData();
      }
    }
  }

  List<Color> _getGradientForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return [const Color(0xFF10B981), const Color(0xFF06B6D4)];
      case 'medium':
        return [const Color(0xFF3B82F6), const Color(0xFF06B6D4)];
      case 'hard':
        return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
      case 'expert':
        return [const Color(0xFFEF4444), const Color(0xFFF59E0B)];
      default:
        return [const Color(0xFF3B82F6), const Color(0xFF06B6D4)];
    }
  }

  String _formatStartDate(dynamic startDate) {
    if (startDate == null) return 'TBD';
    if (startDate is String) {
      try {
        final date = DateTime.parse(startDate);
        return 'Starts ${_formatDate(date)}';
      } catch (e) {
        return startDate;
      }
    }
    return startDate.toString();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<Widget> _buildRulesList() {
    final rules = tournamentData!['rules'];
    if (rules == null) {
      // Create default rules
      return [
        _buildRuleItem({
          'title': 'Duration',
          'description': '${tournamentData!['duration'] ?? 3} Hours',
          'subtitle': 'You have time to complete all problems.',
          'icon': Icons.schedule,
        }),
        _buildRuleItem({
          'title': 'Language',
          'description': tournamentData!['language'] ?? 'Any',
          'subtitle': 'Use your preferred programming language.',
          'icon': Icons.code,
        }),
        _buildRuleItem({
          'title': 'Difficulty',
          'description': tournamentData!['difficulty'] ?? 'Medium',
          'subtitle': 'Problems range in difficulty level.',
          'icon': Icons.trending_up,
        }),
      ];
    }
    
    if (rules is List) {
      return rules.map<Widget>((rule) => _buildRuleItem(rule)).toList();
    }
    
    return [];
  }
}
