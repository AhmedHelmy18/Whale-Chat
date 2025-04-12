import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageService {
  const MessageService({
    required this.userId,
    required this.conversationId,
  });

  final String conversationId;
  final String userId;

  Future<void> sendMessage(TextEditingController messageController) async {
    if (messageController.text.trim().isEmpty) return;

    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'text': messageController.text.trim(),
      'sender': FirebaseAuth.instance.currentUser!.uid,
      'time': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
    var historyConversation = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<Map<String, dynamic>> lastMessages = [
      {
        'id': conversationId,
        'last message': messageController.text.trim(),
        'last message time': Timestamp.now()
      }
    ];
    if (historyConversation.exists) {
      for (var conv in historyConversation.data()?['last conversation']) {
        if (conv["id"] != conversationId) {
          lastMessages.add(conv);
        }
      }
    }

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'last conversation': lastMessages,
      });
    } catch (e) {
      print(e);
    }

    historyConversation =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    lastMessages = [
      {
        'id': conversationId,
        'last message': messageController.text.trim(),
        'last message time': Timestamp.now()
      }
    ];
    if (historyConversation.exists) {
      for (var conv in historyConversation.data()?['last conversation']) {
        if (conv["id"] != conversationId) {
          lastMessages.add(conv);
        }
      }
    }
    try {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'last conversation': lastMessages,
      });
    } catch (e) {
      print(e);
    }
    await FirebaseFunctions.instance.httpsCallable("sendNotification").call({
      "userId": userId,
      "message": messageController.text.trim(),
    });
    messageController.clear();
  }

  Future<void> markMessagesAsSeen() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('status', isEqualTo: 'delivered')
        .where('sender', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'seen'});
    }
    await batch.commit();
  }

  // show if see the message or not
  Icon getMessageStatusIcon(String status) {
    if (status == 'sent') {
      return Icon(Icons.check, color: Colors.grey, size: 16);
    } else if (status == 'delivered') {
      return Icon(Icons.done_all, color: Colors.grey, size: 16);
    } else if (status == 'seen') {
      return Icon(Icons.done_all, color: Colors.blue, size: 16);
    }
    return Icon(Icons.check, color: Colors.grey, size: 16);
  }

  // scroll messages to bottom
  void scrollToBottom(ScrollController scrollController) {
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }
}
