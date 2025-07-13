import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TournamentService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable list of tournaments
  final RxList<Map<String, dynamic>> tournaments = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTournaments();
  }

  // Load tournaments from Firestore
  Future<void> loadTournaments() async {
    try {
      isLoading.value = true;
      
      final QuerySnapshot snapshot = await _firestore
          .collection('tournaments')
          .orderBy('createdAt', descending: true)
          .get();
      
      tournaments.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      
    } catch (e) {
      print('Error loading tournaments: $e');
      Get.snackbar('Error', 'Failed to load tournaments');
    } finally {
      isLoading.value = false;
    }
  }

  // Get tournament by ID
  Future<Map<String, dynamic>?> getTournamentById(String tournamentId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting tournament: $e');
      Get.snackbar('Error', 'Failed to load tournament details');
      return null;
    }
  }

  // Join tournament
  Future<bool> joinTournament(String tournamentId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login to join tournaments');
        return false;
      }

      final DocumentReference tournamentRef = _firestore
          .collection('tournaments')
          .doc(tournamentId);

      // Use transaction to safely update participant count and add user
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot tournamentSnapshot = await transaction.get(tournamentRef);
        
        if (!tournamentSnapshot.exists) {
          throw Exception('Tournament not found');
        }

        final tournamentData = tournamentSnapshot.data() as Map<String, dynamic>;
        final int currentParticipants = tournamentData['participants'] ?? 0;
        final int maxParticipants = tournamentData['maxParticipants'] ?? 0;
        final List<dynamic> subscribers = List.from(tournamentData['subscribers'] ?? []);

        // Check if user is already joined
        if (subscribers.contains(user.uid)) {
          throw Exception('You are already joined to this tournament');
        }

        // Check if tournament is full
        if (currentParticipants >= maxParticipants) {
          throw Exception('Tournament is full');
        }

        // Add user to subscribers and increment participant count
        subscribers.add(user.uid);
        transaction.update(tournamentRef, {
          'participants': currentParticipants + 1,
          'subscribers': subscribers,
        });

        // Add tournament to user's joined tournaments
        transaction.set(
          _firestore.collection('users').doc(user.uid).collection('joinedTournaments').doc(tournamentId),
          {
            'tournamentId': tournamentId,
            'joinedAt': FieldValue.serverTimestamp(),
          }
        );
      });

      Get.snackbar('Success', 'Successfully joined the tournament!');
      await loadTournaments(); // Refresh tournaments list
      return true;

    } catch (e) {
      print('Error joining tournament: $e');
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // Check if user has joined a tournament
  Future<bool> hasUserJoinedTournament(String tournamentId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('joinedTournaments')
          .doc(tournamentId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking tournament membership: $e');
      return false;
    }
  }

  // Get user's joined tournaments
  Future<List<Map<String, dynamic>>> getUserJoinedTournaments() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return [];

      final QuerySnapshot joinedSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('joinedTournaments')
          .get();

      final List<String> tournamentIds = joinedSnapshot.docs
          .map((doc) => doc.id)
          .toList();

      if (tournamentIds.isEmpty) return [];

      final List<Map<String, dynamic>> userTournaments = [];
      
      // Get tournament details for each joined tournament
      for (String tournamentId in tournamentIds) {
        final tournament = await getTournamentById(tournamentId);
        if (tournament != null) {
          userTournaments.add(tournament);
        }
      }

      return userTournaments;
    } catch (e) {
      print('Error getting user tournaments: $e');
      return [];
    }
  }

  // Listen to tournament updates in real-time
  Stream<List<Map<String, dynamic>>> getTournamentsStream() {
    return _firestore
        .collection('tournaments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
