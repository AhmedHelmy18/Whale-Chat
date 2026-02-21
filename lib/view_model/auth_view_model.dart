import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:whale_chat/data/repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  User? get currentUser => _authRepository.currentUser;

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _error = null;
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      name: name,
    );
    _setLoading(false);
    if (result != null) {
      _error = result;
    }
    return result;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    _setLoading(false);
    if (result != null) {
      _error = result;
    }
    return result;
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  Future<String?> forgetPassword({required String email}) async {
    _setLoading(true);
    _error = null;
    final result = await _authRepository.forgetPassword(email: email);
    _setLoading(false);
    if (result != null) {
      _error = result;
    }
    return result;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
