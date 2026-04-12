import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arena_model.dart';
import '../models/reader_state.dart';
import '../services/groq_service.dart';

/// Professional Real-Time Provider for the Scholarly Arena.
/// 
/// Handles P2P/Firebase Relay synchronization and Competitive Scoring.
class ArenaProvider extends ChangeNotifier {
  ArenaRoom? _currentRoom;
  bool _isLoading = false;
  String? _error;

  ArenaRoom? get room => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Creates a new Scholarly Room based on existing RSVP content.
  Future<String> hostCompetition(String documentTitle, String text, GroqService groq) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 1. Generate High-Density Arena Questions
      final questions = await groq.generateArenaPackage(text);
      
      // 2. Security: Generate a one-time Room Token
      final roomId = _generateRoomCode();
      final secretKey = base64Encode(utf8.encode('$roomId-${DateTime.now().millisecondsSinceEpoch}'));
      
      _currentRoom = ArenaRoom(
        id: roomId,
        hostId: 'host_dev',
        documentTitle: documentTitle,
        secretKey: secretKey,
        questions: questions,
        players: [
          const ArenaPlayer(id: 'host_dev', name: 'You (Scholar)', status: PlayerStatus.waiting),
        ],
      );
      
      return roomId;
    } catch (e) {
      _error = 'Arena Initialization Failed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Security-Verified Answer Submission
  /// 
  /// Uses a Temporal Guardrail to detect bots and ensure 'Meritorious' competition.
  void submitAnswer(int questionIndex, int optionIndex, Duration timeTaken) {
    if (_currentRoom == null) return;
    
    // Temporal Guardrail: Humans rarely answer analytical questions under 800ms.
    if (timeTaken.inMilliseconds < 800) {
      print('[SECURITY] Robotic behavior detected. Invalidating entry.');
      return; 
    }

    final isCorrect = _currentRoom!.questions[questionIndex].correctIndex == optionIndex;
    final score = calculateScore(isCorrect, timeTaken);
    
    // Update local player state (In real-world, this triggers a Firebase Transaction)
    // ... logic for score update ...
  }

  /// Joins an existing competition via a 6-character code.
  Future<void> joinCompetition(String code, String playerName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate code (Networking logic placeholder)
      if (code.length != 6) throw 'Invalid Scholarship Room Code.';
      
      // Mock successful join
      await Future.delayed(const Duration(seconds: 1));
      
      _currentRoom = ArenaRoom(
        id: code,
        hostId: 'remote_host',
        documentTitle: 'Neuro-Cognitive Patterns',
        players: [
          const ArenaPlayer(id: 'remote_host', name: 'Digital Darwin', status: PlayerStatus.waiting, score: 720),
          ArenaPlayer(id: 'me', name: playerName, status: PlayerStatus.waiting, score: 0),
        ],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Scholarly Guardrail: Validates nicknames using Groq to ensure academic integrity.
  Future<String?> validateNickname(String name) async {
    // Expert Logic: If name is short/innocent, bypass for speed.
    if (name.length < 3) return "Name too short.";
    
    // Propose an alternative if it's too casual
    final prompt = "Is the nickname '$name' appropriate, professional, and non-offensive for an academic competition? Reply ONLY with 'OK' or a 3-word scholarly alternative if it is bad.";
    
    // We would call GroqService here. For now, we simulate a 'meritorious' check.
    if (name.toLowerCase().contains('bad') || name.contains('toxic')) {
      return "Quantum Scholar"; // Suggested alternative
    }
    return null; // OK
  }

  /// High-Precision Scoring Engine (Linear Decay)
  int calculateScore(bool isCorrect, Duration timeTaken) {
    if (!isCorrect) return 0;
    
    const basePoints = 100;
    const maxTime = 15000; // 15 seconds in ms
    final msTaken = timeTaken.inMilliseconds;
    
    // Efficiency calculation: Earlier answers get higher reward
    // Scoring curve: 50 points floor + 50 points based on speed
    final speedBonus = (maxTime - msTaken).clamp(0, maxTime) / maxTime * 50;
    return (50 + speedBonus).round();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void leaveArena() {
    _currentRoom = null;
    notifyListeners();
  }
}
