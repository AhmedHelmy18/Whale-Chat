import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> loadChats() async {
    List<Map<String, dynamic>> chats = [];
    Set<String> processedUserIds = {};

    try {
      String currentUserId = _auth.currentUser!.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(currentUserId).get();

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

        String otherUserId = currentUserId == participants[0]
            ? participants[1]
            : participants[0];

        // 🔹 Prevent duplicate conversations for the same userId
        String conversationKey = currentUserId.compareTo(otherUserId) < 0
            ? "$currentUserId-$otherUserId"
            : "$otherUserId-$currentUserId";

        if (processedUserIds.contains(conversationKey)) {
          continue;
        }
        processedUserIds.add(conversationKey);

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
