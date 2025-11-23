import 'package:firebase_auth/firebase_auth.dart';
import 'package:whale_chat/services/user_service.dart';

Future<void> createUserData(String name, String email) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await createUserDocument(uid: user.uid, name: name, email: email);
    }
  }