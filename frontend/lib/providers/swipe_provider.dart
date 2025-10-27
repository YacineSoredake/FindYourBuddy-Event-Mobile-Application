import 'package:flutter/material.dart';
import 'package:frontend/models/buddy.dart';
import '../../services/crud/swipe_service.dart';

class SwipeProvider extends ChangeNotifier {
  bool _loading = false;
  String? _lastStatus;
  List<Buddy> _matches = [];
  String? _errorMessage;

  bool get loading => _loading;
  String? get lastStatus => _lastStatus;
  List<Buddy> get matches => _matches;
  String? get errorMessage => _errorMessage;

  /// Handle swipe action (like or dislike)
  Future<void> handleSwipe({
    required String eventId,
    required String targetId,
    required bool liked,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await SwipeService.handleSwipe(
        eventId: eventId,
        targetId: targetId,
        liked: liked,
      );

      _lastStatus = result;
    } catch (e) {
      _errorMessage = 'Swipe failed: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMatchedBuddies() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _matches = await SwipeService.fetchMatchedBuddies();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ✅ Small helper to refresh matches (safe version)
  Future<void> refreshMatches() async {
    try {
      _matches = await SwipeService.fetchMatchedBuddies();
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing matches: $e");
    }
  }

  void clearStatus() {
    _lastStatus = null;
    notifyListeners();
  }
}
