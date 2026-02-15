import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
          photoUrl = await FirebaseStorage.instance
              .ref('users/${doc.id}/profile.jpg')
              .getDownloadURL();
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

  Future<String> getOrCreateConversation(String userId1, String userId2) async {
    // Note: The Cloud Function `createChat` expects `participantId` (the OTHER user).
    // It assumes the caller is the current user.
    // userId1 or userId2 must be the current user.

    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    if (currentUser == null) throw Exception("User not logged in");

    final otherUserId = userId1 == currentUser ? userId2 : userId1;

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final result = await functions.httpsCallable('createChat').call({
        'participantId': otherUserId,
      });

      return result.data['chatId'];
    } catch (e) {
      log("Error creating chat via CF: $e");
      rethrow;
    }
  }
}
