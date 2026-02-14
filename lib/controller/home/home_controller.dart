import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  StreamSubscription? chatSubscription;

  void listenToChats({
    required Function(List<Map<String, dynamic>>) onChatsUpdated,
    required Function(bool) onLoadingChanged,
  }) {
    onLoadingChanged(true);

    chatSubscription = firestore
        .collection("chats")
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((event) async {
      final chatFutures = event.docs.map((doc) async {
        final conversation = doc.data();

        final participants = conversation["participants"];
        if (participants == null || participants.length < 2) return null;

        final otherUserId =
            currentUserId == participants[0] ? participants[1] : participants[0];

        final userDoc = await firestore.collection('users').doc(otherUserId).get();

        if (!userDoc.exists) return null;

        String photoUrl = '';

        try {
          photoUrl = await FirebaseStorage.instance
              .ref('users/$otherUserId/profile.jpg')
              .getDownloadURL();
        } catch (_) {}

        return {
          "id": doc.id,
          "userId": otherUserId,
          "name": userDoc.data()?["name"] ?? "Unknown",
          "about": userDoc.data()?["about"] ?? "",
          "lastMessage": conversation["lastMessage"],
          "timestamp": conversation["lastMessageTime"],
          "photoUrl": photoUrl,
        };
      }).toList();

      final newChatsWithNulls = await Future.wait(chatFutures);
      final newChats = newChatsWithNulls.whereType<Map<String, dynamic>>().toList();

      newChats.sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp?;
        final bTimestamp = b['timestamp'] as Timestamp?;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;
        return bTimestamp.compareTo(aTimestamp);
      });

      onLoadingChanged(false);
      onChatsUpdated(newChats);
    });
  }

  void dispose() {
    chatSubscription?.cancel();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
