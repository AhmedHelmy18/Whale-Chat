import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Signup
  Future<String?> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      // 1. Call Cloud Function to create user and Firestore doc
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      await functions.httpsCallable('createAccount').call({
        'email': email,
        'password': password,
        'name': name,
      });

      // 2. Sign in the user on the client side
      // The Cloud Function created the user, but we need to sign them in locally
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Send verification email (client side is easiest as we have the User object now)
      await auth.currentUser?.sendEmailVerification();

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
