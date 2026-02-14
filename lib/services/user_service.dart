import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createUserDocument({
  required String uid,
  required String name,
  required String email,
}) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final docSnapshot = await userRef.get();

  if (!docSnapshot.exists) {
    await userRef.set({
      'id': uid,
      'name': name,
      'email': email,
      'about': "Hey there! I am using Whale Chat.",
      'image': "",
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'isOnline': false,
      'pushToken': "",
    });
  } else {
    // If the document already exists (e.g. created by Cloud Function),
    // ensure name and email are up to date.
    await userRef.update({
      'name': name,
      'email': email,
    });
  }
}
