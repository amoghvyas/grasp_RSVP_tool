import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/arena_model.dart';
import '../models/reader_state.dart';

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
  Future<String> hostCompetition(String documentTitle, List<RecallQuestion> questions) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate high-fidelity room generation
    await Future.delayed(const Duration(milliseconds: 800));
    
    final roomId = _generateRoomCode();
    _currentRoom = ArenaRoom(
      id: roomId,
      hostId: 'host_dev', // Temporary ID
      documentTitle: documentTitle,
      players: [
        const ArenaPlayer(id: 'host_dev', name: 'You (Scholar)', status: PlayerStatus.waiting),
      ],
    );
    
    _isLoading = false;
    notifyListeners();
    return roomId;
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
          const ArenaPlayer(id: 'remote_host', name: 'Digital Darwin', status: PlayerStatus.waiting),
          ArenaPlayer(id: 'me', name: playerName, status: PlayerStatus.waiting),
        ],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
