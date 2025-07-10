import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Match Controller
/// Manages match creation, joining, and game state
class MatchController extends GetxController {
  static MatchController get to => Get.find();
  
  // Match state
  final RxString _currentRoomCode = ''.obs;
  final RxBool _isInMatch = false.obs;
  final RxBool _isCreatingMatch = false.obs;
  final RxBool _isJoiningMatch = false.obs;
  final RxList<Map<String, dynamic>> _recentMatches = <Map<String, dynamic>>[].obs;
  
  // Match settings
  final RxString _selectedDifficulty = 'Medium'.obs;
  final RxString _selectedLanguage = 'Dart'.obs;
  final RxInt _matchDuration = 10.obs; // minutes
  
  // Getters
  String get currentRoomCode => _currentRoomCode.value;
  bool get isInMatch => _isInMatch.value;
  bool get isCreatingMatch => _isCreatingMatch.value;
  bool get isJoiningMatch => _isJoiningMatch.value;
  List<Map<String, dynamic>> get recentMatches => _recentMatches;
  String get selectedDifficulty => _selectedDifficulty.value;
  String get selectedLanguage => _selectedLanguage.value;
  int get matchDuration => _matchDuration.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadRecentMatches();
  }
  
  /// Generate a random room code
  String generateRoomCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))
    ));
  }
  
  /// Create a new match
  Future<String> createMatch() async {
    try {
      _isCreatingMatch.value = true;
      
      // Generate room code
      final roomCode = generateRoomCode();
      
      // Simulate API call to create match
      await Future.delayed(const Duration(seconds: 1));
      
      _currentRoomCode.value = roomCode;
      _isInMatch.value = true;
      
      return roomCode;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create match: $e');
      rethrow;
    } finally {
      _isCreatingMatch.value = false;
    }
  }
  
  /// Join an existing match
  Future<bool> joinMatch(String roomCode) async {
    try {
      _isJoiningMatch.value = true;
      
      // Validate room code
      if (roomCode.length != 6) {
        Get.snackbar('Invalid Code', 'Room code must be 6 characters');
        return false;
      }
      
      // Simulate API call to join match
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate match found/not found
      if (roomCode == 'NOTFND') {
        Get.snackbar('Not Found', 'Match not found or expired');
        return false;
      }
      
      _currentRoomCode.value = roomCode;
      _isInMatch.value = true;
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to join match: $e');
      return false;
    } finally {
      _isJoiningMatch.value = false;
    }
  }
  
  /// Leave current match
  void leaveMatch() {
    _currentRoomCode.value = '';
    _isInMatch.value = false;
  }
  
  /// Add match to recent matches
  void addRecentMatch({
    required String opponent,
    required bool won,
    required int xpChange,
  }) {
    final match = {
      'opponent': opponent,
      'result': won ? 'Won' : 'Lost',
      'xp': '${won ? '+' : ''}$xpChange XP',
      'time': 'Just now',
      'resultColor': won ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      'icon': won ? Icons.check_circle : Icons.cancel,
      'timestamp': DateTime.now(),
    };
    
    _recentMatches.insert(0, match);
    
    // Keep only last 10 matches
    if (_recentMatches.length > 10) {
      _recentMatches.removeLast();
    }
    
    _saveRecentMatches();
  }
  
  /// Load recent matches from storage
  void _loadRecentMatches() {
    // TODO: Load from local storage or API
    // For now, add some sample data
    _recentMatches.assignAll([
      {
        'opponent': 'CodeNinja',
        'result': 'Won',
        'xp': '+50 XP',
        'time': '2 minutes ago',
        'resultColor': const Color(0xFF10B981),
        'icon': Icons.check_circle,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
      },
      {
        'opponent': 'DevMaster',
        'result': 'Lost',
        'xp': '-10 XP',
        'time': '1 hour ago',
        'resultColor': const Color(0xFFEF4444),
        'icon': Icons.cancel,
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
    ]);
  }
  
  /// Save recent matches to storage
  void _saveRecentMatches() {
    // TODO: Save to local storage
  }
  
  /// Update match settings
  void updateDifficulty(String difficulty) {
    _selectedDifficulty.value = difficulty;
  }
  
  void updateLanguage(String language) {
    _selectedLanguage.value = language;
  }
  
  void updateMatchDuration(int duration) {
    _matchDuration.value = duration;
  }
  
  /// Get formatted time for match history
  String getFormattedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
