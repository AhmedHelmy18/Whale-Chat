import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> createUserDocument({required String uid, required String name, required String email}) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'name': name,
    'email': email,
    'last conversation': [],
    'fcm token': await FirebaseMessaging.instance.getToken(),
  });
}
