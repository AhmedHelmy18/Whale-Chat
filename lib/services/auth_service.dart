import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Signup
  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Weak password.';
      if (e.code == 'email-already-in-use') return 'Email already used.';
      return e.message;
    }
  }

  // Login
  Future<String?> login(
      {required String email, required String password}) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('users').doc(credential.user!.uid).update({
        'fcm token': await messaging.getToken(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'User not found.';
      if (e.code == 'wrong-password') return 'Wrong password.';
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await auth.signOut();
  }

  // Forget password
  Future<String?> forgetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
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
