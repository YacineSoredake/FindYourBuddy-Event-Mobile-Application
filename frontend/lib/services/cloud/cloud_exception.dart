class CloudException implements Exception {
  final String message;
  CloudException([this.message = 'An unknown cloud exception occurred.']);

  @override
  String toString() => 'CloudException: $message';
}

class CloudRegistrationException extends CloudException {
  CloudRegistrationException([super.message = "firebase user creation failed"]);
}

class SendVerificationEmailException extends CloudException {
  SendVerificationEmailException([
    super.message = "send Verification email failed",
  ]);
}
