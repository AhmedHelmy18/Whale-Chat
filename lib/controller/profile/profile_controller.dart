import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileController {
  Future<Map<String, dynamic>?> getUserDataWithImage(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;

      try {
        final ref = FirebaseStorage.instance.ref('users/$userId/profile.jpg');
        final imageUrl = await ref.getDownloadURL();
        data['profileImage'] = imageUrl;
      } catch (_) {
        data['profileImage'] = null;
      }

      return data;
    } catch (e) {
      log("Error fetching user data: $e");
      return null;
    }
  }
}
