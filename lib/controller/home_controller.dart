import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      var lastConversations = event.data()?["last conversation"];

      if (lastConversations == null || lastConversations.isEmpty) {
        onLoadingChanged(false);
        onChatsUpdated([]);
        return;
      }

      List<Map<String, dynamic>> newChats = [];

      for (var doc in lastConversations) {
        if (doc == null || doc.isEmpty) continue;

        var conversationRef =
        await firestore.collection('conversations').doc(doc["id"]).get();
        if (!conversationRef.exists) continue;

        var participants = conversationRef.data()?["participants"];
        if (participants == null || participants.length < 2) continue;

        String otherUserId =
        currentUserId == participants[0] ? participants[1] : participants[0];

        var participantData =
        await firestore.collection('users').doc(otherUserId).get();

        newChats.add({
          "id": doc["id"],
          "name": participantData.data()?["name"] ?? "Unknown",
          "userId": participantData.id,
          "lastMessage": doc["last message"],
          "timestamp": doc["last message time"],
          "bio": participantData.data()?["bio"] ?? "No bio available"
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
