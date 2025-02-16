import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  const ChatService({
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

    List<String> lastMessages = [conversationId];
    if (historyConversation.exists) {
      for (var convId in historyConversation.data()?['last conversation']) {
        if (convId != conversationId) {
          lastMessages.add(convId);
        }
      }
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'last conversation': lastMessages});

    historyConversation = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    lastMessages = [conversationId];
    for (var convId in historyConversation.data()?['last conversation']) {
      if (convId != conversationId) {
        lastMessages.add(convId);
      }
    }
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'last conversation': lastMessages,
    });
    messageController.clear();
  }

  // mark messages as seen
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
