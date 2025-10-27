import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import '../../core/api.dart';
import '../../core/storage.dart';
import '../../models/user.dart';
import '../../exceptions/auth_exception.dart';

class AuthService {
  static Future<User?> login(String email, String password) async {
    try {
      final response = await Api.dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );
      final accessToken = response.data["accessToken"];
      final refreshToken = response.data["refreshToken"];
      final userJson = response.data["user"];

      if (accessToken == null || userJson == null) {
        throw LoginException("Invalid response format");
      }
      await Storage.saveAccessToken(accessToken);
      await Storage.saveRefreshToken(refreshToken);
      return User.fromJson(userJson);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?["message"] ?? "Unknown login error";
      throw LoginException(errorMsg);
    }
  }

  static Future<User?> register({
    required String name,
    required String email,
    required String password,
    required List<String> fields,
    required File image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'fields': fields,
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response = await Api.dio.post(
        "/auth/register",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 201 || response.data['success'] != true) {
        final msg = response.data['message'] ?? 'Registration failed';
        throw RegisterException(msg);
      }

      final accessToken = response.data["accessToken"];
      final refreshToken = response.data["refreshToken"];

      if (accessToken != null) {
        await Storage.saveAccessToken(accessToken);
        await Storage.saveRefreshToken(refreshToken);
      }

      if (response.data["user"] != null) {
        return User.fromJson(response.data["user"]);
      }

      return null;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?["message"] ?? "Unknown register error";
      throw RegisterException(errorMsg);
    } catch (e) {
      throw RegisterException("Unexpected error: $e");
    }
  }

  static User? loggedInUser;

  static Future<User?> currentUser() async {
    try {
      final response = await Api.dio.get("/auth/me");
      loggedInUser = User.fromJson(response.data["user"]);
      return loggedInUser;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?["message"] ?? "Unknown profile error";
      throw LoginException(errorMsg);
    }
  }

  static Future<User?> fetchUserById(String userId) async {
    try {
      final res = await Api.dio.get("/$userId");
      if (res.statusCode == 200) {
        return User.fromJson(res.data['user']);
      } else {
        log("Failed to fetch user: ${res.data.toString()}");
      }
    } catch (e) {
      log("Error fetching user: $e");
    }
    throw Exception("User not found");
  }

  static Future<void> logout() async {
    loggedInUser = null;
    await Storage.clearToken();
  }
}
