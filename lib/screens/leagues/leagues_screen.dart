import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:codeup/routes.dart';
import 'dart:math';

class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({Key? key}) : super(key: key);

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatingAnimation;

  // Mock league data
  final List<Map<String, dynamic>> _leagues = [
    {
      'id': 1,
      'title': 'Algorithm Sprint',
      'subtitle': 'Weekly coding challenge',
      'startDate': '2024-11-15',
      'prizePool': 5000,
      'participants': 128,
      'maxParticipants': 200,
      'difficulty': 'Medium',
      'duration': '3 Hours',
      'language': 'Any',
      'status': 'Open',
      'timeLeft': {'days': 2, 'hours': 14, 'minutes': 37, 'seconds': 42},
      'gradient': [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      'icon': Icons.speed,
      'prizes': [
        {'position': '1st Place', 'amount': 2500, 'color': Color(0xFFFFD700)},
        {'position': '2nd Place', 'amount': 1500, 'color': Color(0xFFC0C0C0)},
        {'position': '3rd Place', 'amount': 1000, 'color': Color(0xFFCD7F32)},
      ],
      'rules': [
        'Duration: 3 Hours',
        'Language: Any',
        'Scoring: Speed + Accuracy',
        'Difficulty: Easy to Hard',
      ],
      'participants_list': [
        {'name': 'CodeMaster', 'rank': 2847, 'level': 12},
        {'name': 'AlgoQueen', 'rank': 1653, 'level': 15},
        {'name': 'ByteNinja', 'rank': 892, 'level': 18},
      ]
    },
    {
      'id': 2,
      'title': 'Data Structure Masters',
      'subtitle': 'Advanced DS challenges',
      'startDate': '2024-11-20',
      'prizePool': 8000,
      'participants': 89,
      'maxParticipants': 150,
      'difficulty': 'Hard',
      'duration': '4 Hours',
      'language': 'C++/Java',
      'status': 'Open',
      'timeLeft': {'days': 7, 'hours': 8, 'minutes': 23, 'seconds': 15},
      'gradient': [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      'icon': Icons.account_tree,
      'prizes': [
        {'position': '1st Place', 'amount': 4000, 'color': Color(0xFFFFD700)},
        {'position': '2nd Place', 'amount': 2500, 'color': Color(0xFFC0C0C0)},
        {'position': '3rd Place', 'amount': 1500, 'color': Color(0xFFCD7F32)},
      ],
      'rules': [
        'Duration: 4 Hours',
        'Language: C++/Java',
        'Scoring: Speed + Accuracy',
        'Difficulty: Medium to Hard',
      ],
      'participants_list': [
        {'name': 'TreeMaster', 'rank': 1234, 'level': 20},
        {'name': 'GraphGuru', 'rank': 567, 'level': 22},
        {'name': 'HashHero', 'rank': 2341, 'level': 16},
      ]
    },
    {
      'id': 3,
      'title': 'Web Dev Championship',
      'subtitle': 'Full-stack challenge',
      'startDate': '2024-11-25',
      'prizePool': 12000,
      'participants': 156,
      'maxParticipants': 300,
      'difficulty': 'Expert',
      'duration': '6 Hours',
      'language': 'JavaScript',
      'status': 'Open',
      'timeLeft': {'days': 12, 'hours': 5, 'minutes': 41, 'seconds': 28},
      'gradient': [Color(0xFF10B981), Color(0xFF06B6D4)],
      'icon': Icons.web,
      'prizes': [
        {'position': '1st Place', 'amount': 6000, 'color': Color(0xFFFFD700)},
        {'position': '2nd Place', 'amount': 4000, 'color': Color(0xFFC0C0C0)},
        {'position': '3rd Place', 'amount': 2000, 'color': Color(0xFFCD7F32)},
      ],
      'rules': [
        'Duration: 6 Hours',
        'Language: JavaScript',
        'Scoring: Functionality + Design',
        'Difficulty: Advanced',
      ],
      'participants_list': [
        {'name': 'ReactRanger', 'rank': 445, 'level': 25},
        {'name': 'NodeNinja', 'rank': 1123, 'level': 19},
        {'name': 'VueVirtuoso', 'rank': 778, 'level': 21},
      ]
    },
    {
      'id': 4,
      'title': 'Mobile Dev Battle',
      'subtitle': 'Cross-platform coding',
      'startDate': '2024-12-01',
      'prizePool': 15000,
      'participants': 67,
      'maxParticipants': 250,
      'difficulty': 'Expert',
      'duration': '8 Hours',
      'language': 'Flutter/React Native',
      'status': 'Registration',
      'timeLeft': {'days': 18, 'hours': 12, 'minutes': 15, 'seconds': 7},
      'gradient': [Color(0xFFEF4444), Color(0xFFF59E0B)],
      'icon': Icons.phone_android,
      'prizes': [
        {'position': '1st Place', 'amount': 7500, 'color': Color(0xFFFFD700)},
        {'position': '2nd Place', 'amount': 5000, 'color': Color(0xFFC0C0C0)},
        {'position': '3rd Place', 'amount': 2500, 'color': Color(0xFFCD7F32)},
      ],
      'rules': [
        'Duration: 8 Hours',
        'Language: Flutter/React Native',
        'Scoring: Functionality + UI/UX',
        'Difficulty: Expert',
      ],
      'participants_list': [
        {'name': 'FlutterFly', 'rank': 223, 'level': 28},
        {'name': 'ReactRocket', 'rank': 334, 'level': 26},
        {'name': 'DartDevil', 'rank': 156, 'level': 30},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
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

    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
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
    _shimmerController.repeat();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          _buildStatsOverview(),
                          const SizedBox(height: 24),
                          _buildLeaguesGrid(),
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
                  'LEAGUES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Compete in coding tournaments',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Floating decorative elements
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, sin(_floatingAnimation.value * 2 * pi) * 3),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFF59E0B),
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

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D3748),
            Color(0xFF1A1D29),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events,
              value: '4',
              label: 'Active Leagues',
              color: const Color(0xFFF59E0B),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money,
              value: '\$40K',
              label: 'Total Prizes',
              color: const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.people,
              value: '440',
              label: 'Participants',
              color: const Color(0xFF06B6D4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLeaguesGrid() {
    return Column(
      children: _leagues.map((league) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _buildLeagueCard(league),
      )).toList(),
    );
  }

  Widget _buildLeagueCard(Map<String, dynamic> league) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        RouteHelper.goToTournamentDetails(tournamentId: league['id']);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (league['gradient'][0] as Color).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: league['gradient'],
                  ),
                ),
              ),
              
              // Shimmer effect
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(_shimmerAnimation.value * 200, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Card content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            league['icon'],
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: league['status'] == 'Open' 
                                ? const Color(0xFF10B981).withOpacity(0.2)
                                : const Color(0xFFF59E0B).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: league['status'] == 'Open' 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          child: Text(
                            league['status'],
                            style: TextStyle(
                              color: league['status'] == 'Open' 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title and subtitle
                    Text(
                      league['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      league['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Prize pool and participants
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Prize Pool',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${league['prizePool'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Participants',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${league['participants']}/${league['maxParticipants']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Time countdown
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Starts in: ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${league['timeLeft']['days']}d ${league['timeLeft']['hours']}h ${league['timeLeft']['minutes']}m',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            league['difficulty'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
