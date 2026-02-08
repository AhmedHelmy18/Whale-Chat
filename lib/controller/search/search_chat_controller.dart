import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SearchUserController {
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      return Future.wait(snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) async {
        final data = doc.data();

        String photoUrl = '';

        try {
          photoUrl = await FirebaseStorage.instance.ref('users/${doc.id}/profile.jpg').getDownloadURL();
        } catch (_) {}

        return {
          'userId': doc.id,
          'name': data['name'] ?? 'Unknown',
          'bio': data['bio'] ?? '',
          'photoUrl': photoUrl,
        };
      }).toList());
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<String> getOrCreateConversation(
      String userId1, String userId2) async {
    final ids = [userId1, userId2]..sort();
    final chatId = ids.join('_');

    final doc = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatId)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatId)
          .set({'participants': ids});
    }

    return chatId;
  }
}
