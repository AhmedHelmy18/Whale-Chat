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
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .listen((event) async {
      final lastConversations = event.data()?["last conversation"];

      if (lastConversations == null || lastConversations.isEmpty) {
        onLoadingChanged(false);
        onChatsUpdated([]);
        return;
      }

      List<Map<String, dynamic>> newChats = [];

      for (var doc in lastConversations) {
        final conversation =
        await firestore.collection('conversations').doc(doc["id"]).get();

        if (!conversation.exists) continue;

        final participants = conversation.data()?["participants"];
        if (participants == null || participants.length < 2) continue;

        final otherUserId =
        currentUserId == participants[0] ? participants[1] : participants[0];

        final userDoc =
        await firestore.collection('users').doc(otherUserId).get();

        String photoUrl = '';

        try {
          photoUrl = await FirebaseStorage.instance.ref('users/$otherUserId/profile.jpg').getDownloadURL();
        } catch (_) {}

        newChats.add({
          "id": doc["id"],
          "userId": otherUserId,
          "name": userDoc.data()?["name"] ?? "Unknown",
          "bio": userDoc.data()?["bio"] ?? "",
          "lastMessage": doc["last message"],
          "timestamp": doc["last message time"],
          "photoUrl": photoUrl,
        });
      }

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
