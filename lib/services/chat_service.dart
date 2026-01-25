import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  ChatService() {
    loading();
  }

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  ValueNotifier<List<Map<String, dynamic>>> chats = ValueNotifier([]);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  void loading() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    _subscription = fireStore
        .collection("users")
        .doc(currentUserId)
        .snapshots()
        .listen((event) async {
      final data = event.data();
      final lastConversation = data?["last conversation"];

      if (lastConversation == null || lastConversation.isEmpty) {
        chats.value = [];
        return;
      }

      List<Map<String, dynamic>> updatedChats = [];

      for (var conv in lastConversation) {
        if (conv == null) continue;

        final Map<String, dynamic> convMap =
        Map<String, dynamic>.from(conv as Map);

        final String conversationId = convMap["id"]?.toString() ?? "";
        if (conversationId.isEmpty) continue;

        final conversationRef =
        await fireStore.collection('conversations').doc(conversationId).get();

        if (!conversationRef.exists) continue;

        final participants = conversationRef.data()?["participants"];
        if (participants == null || participants.length < 2) continue;

        final String otherUserId = currentUserId == participants[0]
            ? participants[1]
            : participants[0];

        final participantData =
        await fireStore.collection('users').doc(otherUserId).get();

        updatedChats.add({
          "id": conversationId,
          "name": participantData.data()?["name"] ?? "Unknown",
          "userId": participantData.id,
          "lastMessage": convMap["last message"] ?? "",
          "timestamp": convMap["last message time"] ?? Timestamp.now(),
          "bio": participantData.data()?["bio"] ?? "",
        });
      }

      updatedChats.sort((a, b) {
        final Timestamp t1 = a["timestamp"] ?? Timestamp.now();
        final Timestamp t2 = b["timestamp"] ?? Timestamp.now();
        return t2.compareTo(t1);
      });

      chats.value = updatedChats;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
