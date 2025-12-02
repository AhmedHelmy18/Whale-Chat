import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  ChatService() {
    loading();
  }

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  Set<String> processedUserIds = {};

  ValueNotifier<List<Map<String, dynamic>>> chats = ValueNotifier([]);

  void loading() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .listen(
      (event) async {
        List<Map<String, dynamic>> updatedChats = [];

        for (var doc in event.data()?["last conversation"]) {
          var conversationRef =
              await fireStore.collection('conversations').doc(doc).get();

          if (!conversationRef.exists) continue;

          var participants = conversationRef.data()?["participants"];
          if (participants == null || participants.length < 2) continue;

          String otherUserId = currentUserId == participants[0]
              ? participants[1]
              : participants[0];

          String conversationKey = currentUserId.compareTo(otherUserId) < 0
              ? "$currentUserId-$otherUserId"
              : "$otherUserId-$currentUserId";

          if (processedUserIds.contains(conversationKey)) {
            continue;
          }

          processedUserIds.add(conversationKey);

          var participantData =
              await fireStore.collection('users').doc(otherUserId).get();

          var lastMessageSnapshot = await FirebaseFirestore.instance
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

          updatedChats.add({
            "id": doc,
            "name": participantData.data()?["name"],
            "userId": participantData.id,
            "lastMessage": lastMessage,
            "timestamp": lastMessageTime,
            "bio": participantData.data()?["bio"]
          });
        }

        chats.value = updatedChats;
      },
    );
  }
}
