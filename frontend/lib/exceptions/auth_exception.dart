class AuthException implements Exception {
  final String message;
  AuthException([this.message = "Authentication error"]);

  @override
  String toString() => message;
}

class LoginException extends AuthException {
  LoginException([super.message = "Login failed"]);
}

class RegisterException extends AuthException {
  RegisterException([super.message = "Register failed"]);
}

class ProfileException extends AuthException {
  ProfileException([super.message = "Profile failed"]);
}
