import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/data/repository/auth_repository.dart';
import 'package:whale_chat/view_model/auth_view_model.dart';

// Manual Mock for AuthRepository
class MockAuthRepository implements AuthRepository {
  bool signUpCalled = false;
  bool loginCalled = false;
  bool logoutCalled = false;
  bool forgetPasswordCalled = false;

  String? signUpResult;
  String? loginResult;
  String? forgetPasswordResult;

  @override
  User? get currentUser => null;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    signUpCalled = true;
    return signUpResult;
  }

  @override
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    loginCalled = true;
    return loginResult;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<String?> forgetPassword({required String email}) async {
    forgetPasswordCalled = true;
    return forgetPasswordResult;
  }
}

void main() {
  group('AuthViewModel', () {
    late MockAuthRepository mockAuthRepository;
    late AuthViewModel authViewModel;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authViewModel = AuthViewModel(authRepository: mockAuthRepository);
    });

    test('Initial state should have isLoading as false and error as null', () {
      expect(authViewModel.isLoading, false);
      expect(authViewModel.error, null);
    });

    group('signUp', () {
      test('signUp updates isLoading properly on success', () async {
        mockAuthRepository.signUpResult = null; // Success scenario

        bool isLoadingWasTrue = false;
        authViewModel.addListener(() {
          if (authViewModel.isLoading) {
            isLoadingWasTrue = true;
          }
        });

        final result = await authViewModel.signUp(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(mockAuthRepository.signUpCalled, true);
        expect(result, null);
        expect(authViewModel.error, null);
        expect(isLoadingWasTrue, true); // Loading was true during the process
        expect(authViewModel.isLoading, false); // Loading is false after completion
      });

      test('signUp updates isLoading and error properly on failure', () async {
        mockAuthRepository.signUpResult = 'Sign up failed'; // Failure scenario

        final result = await authViewModel.signUp(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
        );

        expect(mockAuthRepository.signUpCalled, true);
        expect(result, 'Sign up failed');
        expect(authViewModel.error, 'Sign up failed');
        expect(authViewModel.isLoading, false);
      });
    });

    group('login', () {
      test('login updates isLoading properly on success', () async {
        mockAuthRepository.loginResult = null;

        bool isLoadingWasTrue = false;
        authViewModel.addListener(() {
          if (authViewModel.isLoading) {
            isLoadingWasTrue = true;
          }
        });

        final result = await authViewModel.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(mockAuthRepository.loginCalled, true);
        expect(result, null);
        expect(authViewModel.error, null);
        expect(isLoadingWasTrue, true);
        expect(authViewModel.isLoading, false);
      });

      test('login updates isLoading and error properly on failure', () async {
        mockAuthRepository.loginResult = 'Login failed';

        final result = await authViewModel.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(mockAuthRepository.loginCalled, true);
        expect(result, 'Login failed');
        expect(authViewModel.error, 'Login failed');
        expect(authViewModel.isLoading, false);
      });
    });

    group('logout', () {
      test('logout calls repository logout', () async {
        await authViewModel.logout();
        expect(mockAuthRepository.logoutCalled, true);
      });
    });

    group('forgetPassword', () {
      test('forgetPassword updates isLoading properly on success', () async {
        mockAuthRepository.forgetPasswordResult = null;

        bool isLoadingWasTrue = false;
        authViewModel.addListener(() {
          if (authViewModel.isLoading) {
            isLoadingWasTrue = true;
          }
        });

        final result = await authViewModel.forgetPassword(
          email: 'test@example.com',
        );

        expect(mockAuthRepository.forgetPasswordCalled, true);
        expect(result, null);
        expect(authViewModel.error, null);
        expect(isLoadingWasTrue, true);
        expect(authViewModel.isLoading, false);
      });

      test('forgetPassword updates isLoading and error properly on failure', () async {
        mockAuthRepository.forgetPasswordResult = 'Password reset failed';

        final result = await authViewModel.forgetPassword(
          email: 'test@example.com',
        );

        expect(mockAuthRepository.forgetPasswordCalled, true);
        expect(result, 'Password reset failed');
        expect(authViewModel.error, 'Password reset failed');
        expect(authViewModel.isLoading, false);
      });
    });
  });
}
