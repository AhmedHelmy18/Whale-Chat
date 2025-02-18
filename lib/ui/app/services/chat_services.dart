import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> loadChats() async {
    List<Map<String, dynamic>> chats = [];

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        return chats;
      }

      List<dynamic> lastConversations = userDoc.get("last conversation") ?? [];

      for (var doc in lastConversations) {
        var conversationRef =
            await _firestore.collection('conversations').doc(doc).get();

        if (!conversationRef.exists) continue;

        var participants = conversationRef.data()?["participants"];
        if (participants == null || participants.length < 2) continue;

        String otherUserId = _auth.currentUser!.uid == participants[0]
            ? participants[1]
            : participants[0];

        var participantData =
            await _firestore.collection('users').doc(otherUserId).get();

        var lastMessageSnapshot = await _firestore
            .collection('conversations')
            .doc(doc)
            .collection('messages')
            .orderBy('time', descending: true)
            .limit(1)
            .get();

        String lastMessage = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first["text"]
            : "No messages yet";
        Timestamp lastMessageTime = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first["time"]
            : Timestamp.now();

        chats.add({
          "id": doc,
          "name": participantData.data()?["name"] ?? "Unknown",
          "userId": participantData.id,
          "lastMessage": lastMessage,
          "timestamp": lastMessageTime,
          "bio": participantData.data()?["bio"] ?? "",
        });
      }
    } catch (e) {
      log("Error loading chats: $e");
    }

    return chats;
  }
}
