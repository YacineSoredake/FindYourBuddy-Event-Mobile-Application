import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:frontend/core/api.dart';

class ProfileService {
  static Future<Map<String, dynamic>> fetchUserById(String userId) async {
    try {
      final res = await Api.dio.get("/users/$userId");

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        return data;
      } else {
        debugPrint("❌ Failed to fetch user: ${res.data}");
        throw Exception("Failed to fetch user");
      }
    } catch (e) {
      log("⚠️ Error fetching user: $e");
      throw Exception("Error fetching user");
    }
  }

  static Future<Map<String, dynamic>?> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      final res = await Api.dio.put("/users", data: updates);

      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['user'];
      }

      log('❌ Failed to update user: ${res.data}');
      return null;
    } catch (e) {
      log('⚠️ Error updating profile: $e');
      return null;
    }
  }
}
