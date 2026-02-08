import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/services/auth_service.dart';

class AuthController {
  final AuthService authService = AuthService();

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final error = await authService.signUp(email: email, password: password);
    if (error != null) return error;
    return null;
  }

  Future<bool> isEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final error = await authService.login(email: email, password: password);
    if (error != null) return error;
    return null;
  }

  Future<void> logout() async {
    await authService.logout();
  }

  Future<String?> forgetPassword({required String email}) async {
    final error = await authService.forgetPassword(email: email);
    if (error != null) return error;
    return null;
  }
}
