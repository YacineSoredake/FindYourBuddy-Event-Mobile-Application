import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import '../models/event.dart';
import '../services/crud/event_service.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _loading = false;
  String? _error;
  Map<String, bool> _interestStatus = {};
  List<User> _buddies = [];

  List<Event> get events => _events;
  List<User> get buddies => _buddies;
  bool get loading => _loading;
  String? get error => _error;
  Map<String, bool> get interestStatus => _interestStatus;

  Future<void> fetchEvents({bool forceRefresh = false}) async {
    if (_events.isNotEmpty && !forceRefresh) return;
    _loading = true;
    notifyListeners();

    try {
      _events = await EventService.fetchEvents();

      _interestStatus.clear();
      for (var event in _events) {
        _interestStatus[event.id] = event.isInterested;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createEvent({
    required String title,
    required String category,
    required String description,
    required String date,
    required Map<String, dynamic> location,
    List<File>? images,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final created = await EventService.createEvent(
        title: title,
        category: category,
        description: description,
        date: date,
        location: location,
        images: images,
      );

      if (created) {
        log('✅ Event created successfully');
      }
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Provider error: $_error');
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markInterest(String eventId) async {
    try {
      final marked = await EventService.markInterest(eventId: eventId);
      if (marked) {
        _interestStatus[eventId] = true;
        log('✅ Interest marked for $eventId');
      }
    } catch (e) {
      debugPrint('❌ Mark Interest Error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> unmarkInterest(String eventId) async {
    try {
      final unmarked = await EventService.unmarkInterest(eventId: eventId);
      if (unmarked) {
        _interestStatus[eventId] = false;
        log('❌ Interest unmarked for $eventId');
      }
    } catch (e) {
      debugPrint('❌ Unmark Interest Error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchExploreBuddies() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final buddies = await EventService.exploreBuddies();
      _buddies = buddies;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _events.clear();
    _interestStatus.clear();
    _error = null;
    _loading = false;
    notifyListeners();
  }
}
