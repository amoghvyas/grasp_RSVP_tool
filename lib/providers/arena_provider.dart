import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arena_model.dart';
import '../models/reader_state.dart';
import '../services/groq_service.dart';
import '../services/arena_firebase_service.dart';

/// Optimized Real-Time Provider for the Scholarly Arena.
/// 
/// IMPLEMENTS OPTIMISTIC HANDSHAKE:
/// 1. Instant Room Creation (Lobby access in <1s)
/// 2. Background AI Synthesis (Non-blocking)
/// 3. Strict 30s Timeouts
class ArenaProvider extends ChangeNotifier {
  final ArenaFirebaseService _firebase = ArenaFirebaseService();
  StreamSubscription? _roomSub;
  
  ArenaRoom? _currentRoom;
  bool _isLoading = false;
  String? _error;
  final String _myId = 'scholar_${Random().nextInt(9999)}';

  ArenaRoom? get room => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get myId => _myId;

  @override
  void dispose() {
    _roomSub?.cancel();
    super.dispose();
  }

  /// REWRITTEN LOGIC: Optimistic Hosting
  /// 1. Immediately creates a shell room in Firebase to allow instant Lobby entry.
  /// 2. Initiates background AI synthesis.
  Future<String> hostCompetitionOptimistic(String documentTitle, String text, GroqService groq) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final roomId = _generateRoomCode();
      final secretKey = base64Encode(utf8.encode('$roomId-${DateTime.now().millisecondsSinceEpoch}'));
      
      // 1. Instant Shell Creation
      final shellRoom = ArenaRoom(
        id: roomId,
        hostId: _myId,
        documentTitle: documentTitle,
        secretKey: secretKey,
        questions: [], // Initially empty to prevent blocking
        players: [
          ArenaPlayer(id: _myId, name: 'You (Host)', status: PlayerStatus.waiting),
        ],
      );

      // Timeout protected Firebase Handshake
      await _firebase.createRoom(shellRoom).timeout(const Duration(seconds: 15));
      _syncToRoom(roomId);

      // 2. Background Task: AI Synthesis
      // We do not 'await' this before returning the ID.
      _backgroundSynthesis(roomId, text, groq);
      
      return roomId;
    } catch (e) {
      _error = 'Handshake Failed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _backgroundSynthesis(String roomId, String text, GroqService groq) async {
    try {
      final questions = await groq.generateArenaPackage(text);
      await _firebase.updateRoomQuestions(roomId, questions);
    } catch (e) {
      print('[SCHOLARLY WARN] Background synthesis failed: $e');
      // Potential retry logic or local fallback
    }
  }

  /// Real-time Synchronization Loop
  void _syncToRoom(String roomId) {
    _roomSub?.cancel();
    _roomSub = _firebase.streamRoom(roomId).listen((room) {
      _currentRoom = room;
      notifyListeners();
    });
  }

  Future<void> updateRoomTopic(String newTopic) async {
    if (_currentRoom == null || _currentRoom!.hostId != _myId) return;
    await _firebase.updateRoomTopic(_currentRoom!.id, newTopic);
  }

  Future<void> joinCompetition(String code, String playerName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final exists = await _firebase.roomExists(code).timeout(const Duration(seconds: 10));
      if (!exists) throw 'Scholarship Room Not Found.';
      
      final player = ArenaPlayer(id: _myId, name: playerName);
      await _firebase.joinRoom(code, player);
      _syncToRoom(code);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startCompetition() async {
    if (_currentRoom == null || _currentRoom!.hostId != _myId) return;
    await _firebase.startRoom(_currentRoom!.id);
  }

  void submitAnswer(int questionIndex, int optionIndex, Duration timeTaken) async {
    if (_currentRoom == null) return;
    
    if (timeTaken.inMilliseconds < 800) {
      print('[SECURITY] Robotic behavior detected.');
      return; 
    }

    final isCorrect = _currentRoom!.questions[questionIndex].correctIndex == optionIndex;
    final score = calculateScore(isCorrect, timeTaken);
    
    await _firebase.submitScore(
      _currentRoom!.id, 
      _myId, 
      score, 
      isCorrect ? 1 : 0
    );
  }

  Future<String?> validateNickname(String name) async {
    if (name.length < 3) return "Name too short.";
    if (name.toLowerCase().contains('bad') || name.contains('toxic')) {
      return "Quantum Scholar"; 
    }
    return null; 
  }

  int calculateScore(bool isCorrect, Duration timeTaken) {
    if (!isCorrect) return 0;
    
    const maxTime = 15000;
    final msTaken = timeTaken.inMilliseconds;
    final speedBonus = (maxTime - msTaken).clamp(0, maxTime) / maxTime * 50;
    return (50 + speedBonus).round();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void leaveArena() {
    _roomSub?.cancel();
    _currentRoom = null;
    notifyListeners();
  }
}
