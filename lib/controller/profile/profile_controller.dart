import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController {
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      log("Error getting user data: $e");
      return null;
    }
  }
}
