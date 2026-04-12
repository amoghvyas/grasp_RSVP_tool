import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/arena_model.dart';
import '../models/reader_state.dart';

class ArenaFirebaseService {
  static const _dbUrl = String.fromEnvironment('FB_DB_URL');

  // Singleton pattern for Scholarly reliability
  static final ArenaFirebaseService _instance = ArenaFirebaseService._internal();
  factory ArenaFirebaseService() => _instance;
  ArenaFirebaseService._internal();

  FirebaseDatabase get _db {
    try {
      // Force the regional database URL with a clean root-only trim
      final cleanUrl = _dbUrl.trim().replaceAll(RegExp(r'/+$'), '');
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: cleanUrl.isEmpty ? null : cleanUrl,
      );
    } catch (e) {
      throw 'Firebase connectivity failure. Please verify your Scholarly Secrets.';
    }
  }

  DatabaseReference _roomRef(String roomId) => _db.ref('arena_rooms/$roomId');

  Future<void> createRoom(ArenaRoom room) async {
    await _roomRef(room.id).set(room.toMap());
  }

  Future<void> updateRoomTopic(String roomId, String newTopic) async {
    await _roomRef(roomId).update({'documentTitle': newTopic});
  }

  Future<void> updateRoomQuestions(String roomId, List<InteractiveQuiz> questions) async {
    await _roomRef(roomId).update({
      'questions': questions.map((q) => q.toMap()).toList(),
    });
  }

  Future<void> joinRoom(String roomId, ArenaPlayer player) async {
    await _roomRef(roomId).child('players').child(player.id).set(player.toMap());
  }

  Future<void> startRoom(String roomId) async {
    await _roomRef(roomId).update({
      'isStarted': true,
      'startTimeMs': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> submitScore(String roomId, String playerId, int score, int correct) async {
    final playerRef = _roomRef(roomId).child('players').child(playerId);
    await playerRef.update({
      'score': ServerValue.increment(score),
      'correctAnswers': ServerValue.increment(correct),
      'status': 'finished',
    });
  }

  Stream<ArenaRoom?> streamRoom(String roomId) {
    return _roomRef(roomId).onValue.map((event) {
      final snapshot = event.snapshot.value;
      if (snapshot == null) return null;
      return ArenaRoom.fromMap(snapshot as Map<dynamic, dynamic>);
    });
  }

  Future<bool> roomExists(String roomId) async {
    final snapshot = await _roomRef(roomId).get();
    return snapshot.exists;
  }
}
