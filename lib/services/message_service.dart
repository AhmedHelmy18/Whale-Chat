import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MessageService {
  MessageService({
    required this.userId,
    required this.conversationId,
  });

  final String conversationId;
  final String userId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> sendTextAndImages(
      {required String text, required List<File> images}) async {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;

    final cleanText = text.trim();
    if (cleanText.isEmpty && images.isEmpty) return;

    final List<String> imageUrls = [];

    if (images.isNotEmpty) {
      for (final file in images) {
        final fileName =
            "${DateTime.now().millisecondsSinceEpoch}_$senderId.jpg";
        final ref = _storage.ref("chats/$conversationId/images/$fileName");
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    }

    String type;
    if (imageUrls.isNotEmpty && cleanText.isNotEmpty) {
      type = 'text_with_image';
    } else if (imageUrls.isNotEmpty) {
      type = 'image';
    } else {
      type = 'text';
    }

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      await functions.httpsCallable('sendMessage').call({
        'chatId': conversationId,
        'content': cleanText,
        'type': type,
        'imageUrls': imageUrls,
      });
    } catch (e) {
      log("Error sending message via CF: $e");
    }
  }

  Future<void> markMessagesAsSeen() async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      await functions.httpsCallable('updateMessageStatus').call({
        'chatId': conversationId,
        'status': 'seen',
      });
    } catch (e) {
      log("Error marking seen via CF: $e");
    }
  }

  Future<void> updateDeliveredForIncoming() async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      await functions.httpsCallable('updateMessageStatus').call({
        'chatId': conversationId,
        'status': 'delivered',
      });
    } catch (e) {
      log("Error marking delivered via CF: $e");
    }
  }

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
}
