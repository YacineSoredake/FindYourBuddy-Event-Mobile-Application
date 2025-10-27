import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/crud/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  User? _userModel;
  Map<String, dynamic>? _stats;
  List<dynamic>? _likedEvents;

  Map<String, dynamic>? get userData => _userData;
  User? get userModel => _userModel;
  Map<String, dynamic>? get stats => _stats;
  List<dynamic>? get likedEvents => _likedEvents;

  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      final data = await ProfileService.fetchUserById(userId);

      _userData = data['user'];
      _userModel = User.fromJson(data['user']);
      _stats = data['stats'];
      _likedEvents = data['likedEvents'];
      notifyListeners();
      return data;
    } catch (e) {
      debugPrint('❌ Error fetching user by ID: $e');
      rethrow;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updatedData = await ProfileService.updateUserProfile(
        updates: updates,
      );

      if (updatedData != null) {
        _userData = updatedData;
        _userModel = User.fromJson(updatedData);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ Error updating profile: $e');
      return false;
    }
  }
}
