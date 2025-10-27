import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  // ====== TOKEN ======
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("refresh_access", token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_access");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ====== INTRO ======
  static Future<void> setSeenIntro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_intro", value);
  }

  static Future<bool?> getSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("seen_intro");
  }
}
