import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _functions.httpsCallable('createAccount').call({
        'email': email,
        'password': password,
        'name': name,
      });

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _auth.currentUser?.sendEmailVerification();

      return null;
    } on FirebaseFunctionsException catch (e) {
      return e.message;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'User not found.';
      if (e.code == 'wrong-password') return 'Wrong password.';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'fcm token': token,
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'User not found.';
      if (e.code == 'wrong-password') return 'Wrong password.';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> forgetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email.';
      }
      return e.message ?? 'Something went wrong.';
    } catch (e) {
      return e.toString();
    }
  }
}
