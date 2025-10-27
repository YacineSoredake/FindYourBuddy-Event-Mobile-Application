import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/event_provider.dart';
import 'package:frontend/services/cloud/firebase_helper.dart';
import 'package:frontend/services/crud/auth_service.dart';
import 'package:frontend/core/storage.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  //  State
  User? _user;
  Timer? _verificationTimer;
  bool _loading = false;
  String? _errorMessage;
  int _currentStep = 0;

  // Registration
  String? _email, _password, _name;
  File? _avatar;
  final List<String> _fields = [];

  // Email verification flags
  bool _verificationSent = false;
  bool _verificationDone = false;

  // Getters
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  bool get verificationSent => _verificationSent;
  bool get verificationDone => _verificationDone;
  int get currentStep => _currentStep;
  List<String> get fields => List.unmodifiable(_fields);

  static const int totalSteps = 5;
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step.clamp(0, totalSteps - 1);
    notifyListeners();
  }

  void setEmail(String v) => _update(() => _email = v);
  void setPassword(String v) => _update(() => _password = v);
  void setName(String v) => _update(() => _name = v);
  void setAvatar(File f) => _update(() => _avatar = f);

  void toggleField(String value) => _update(() {
    _fields.contains(value) ? _fields.remove(value) : _fields.add(value);
  });

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    clearError();
    await _runSafe(() async {
      await FirebaseHelper.createAndSendVerification(
        _email!,
        _password ?? '123456',
      );
      _verificationSent = true;
      _startVerificationCheckTimer(context);
    });
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    clearError();
    await _runSafe(() async {
      await FirebaseHelper.resendVerification();
      _restartVerificationTimer(context);
    });
  }

  Future<void> checkEmailVerified([BuildContext? context]) async {
    await _runSafe(() async {
      final verified = await FirebaseHelper.isEmailVerified();
      if (verified) {
        _verificationDone = true;
        _verificationTimer?.cancel();
        if (context != null) nextStep();
      }
    });
  }

  void _startVerificationCheckTimer(BuildContext context) {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await checkEmailVerified(context);
    });
  }

  void _restartVerificationTimer(BuildContext context) {
    _verificationDone = false;
    _verificationTimer?.cancel();
    _startVerificationCheckTimer(context);
  }

  Future<void> submitRegistration(BuildContext context) async {
    clearError();
    if ([_email, _password, _name, _avatar].contains(null)) {
      _errorMessage = "All fields are required before submitting.";
      notifyListeners();
      return;
    }

    await _runSafe(() async {
      _user = await AuthService.register(
        name: _name!,
        email: _email!,
        password: _password!,
        fields: _fields,
        image: _avatar!,
      );
      resetRegistration();
      clearError(); // ✅ clear any registration error before navigation
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  Future<void> initApp(BuildContext context) async {
    clearError();
    await loadUser();
    final route = _user != null ? '/main' : '/login';
    clearError();
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> loadUser() async {
    clearError();
    await _runSafe(() async {
      final token = await Storage.getAccessToken();
      if (token != null) _user = await AuthService.currentUser();
    });
  }

  Future<void> login(String email, String password) async {
    clearError();
    await _runSafe(() async {
      _user = await AuthService.login(email, password);
    }, errorMsg: "Invalid email or password");
  }

  Future<void> logout(BuildContext context) async {
    clearError();
    _user = null;
    context.read<EventProvider>().clear();
    clearError();
    Navigator.pushReplacementNamed(context, '/login');
    notifyListeners();
  }

  void resetRegistration() {
    _email = _password = _name = null;
    _avatar = null;
    _fields.clear();
    _verificationSent = _verificationDone = false;
    _currentStep = 0;
    notifyListeners();
  }

  void reset() {
    resetRegistration();
    _user = null;
    clearError(); // ✅ ensure reset also clears messages
    notifyListeners();
  }

  Future<void> _runSafe(Future<void> Function() fn, {String? errorMsg}) async {
    _setLoading(true);
    try {
      _errorMessage = null;
      await fn();
    } catch (e) {
      _errorMessage = errorMsg ?? e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _update(void Function() action) {
    action();
    notifyListeners();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }
}
