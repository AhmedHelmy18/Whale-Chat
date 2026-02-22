import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whale_chat/data/model/chat_model.dart';
import 'package:whale_chat/data/model/message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection("chats")
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromDoc(doc)).toList();

      final seen = <String>{};
      final unique = <ChatModel>[];
      for (final chat in chats) {
        final otherId = chat.participants.firstWhere(
          (id) => id != userId,
          orElse: () => chat.id,
        );
        if (seen.add(otherId)) unique.add(chat);
      }
      return unique;
    });
  }

  Stream<List<Message>> getMessages(String conversationId, String myId) {
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromDoc(doc: doc, myId: myId);
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    required List<File> images,
  }) async {
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

    await _functions.httpsCallable('sendMessage').call({
      'chatId': conversationId,
      'content': cleanText,
      'type': type,
      'imageUrls': imageUrls,
    });
  }

  Future<void> updateMessageStatus({
    required String conversationId,
    required String status,
  }) async {
    await _functions.httpsCallable('updateMessageStatus').call({
      'chatId': conversationId,
      'status': status,
    });
  }

  Future<String?> createChat(String participantId) async {
    try {
      final result = await _functions.httpsCallable('createChat').call({
        'participantId': participantId,
      });
      return result.data['chatId'];
    } catch (e) {
      return null;
    }
  }
}
