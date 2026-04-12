import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/arena_model.dart';

class ArenaFirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  
  // Singleton pattern for Scholarly reliability
  static final ArenaFirebaseService _instance = ArenaFirebaseService._internal();
  factory ArenaFirebaseService() => _instance;
  ArenaFirebaseService._internal();

  DatabaseReference _roomRef(String roomId) => _db.ref('arena_rooms/$roomId');

  Future<void> createRoom(ArenaRoom room) async {
    await _roomRef(room.id).set(room.toMap());
  }

  Future<void> updateRoomTopic(String roomId, String newTopic) async {
    await _roomRef(roomId).update({'documentTitle': newTopic});
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
