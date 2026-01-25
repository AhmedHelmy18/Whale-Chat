import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MessageService {
  MessageService({
    required this.userId,
    required this.conversationId,
  });

  final String conversationId;
  final String userId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> sendTextAndImages({
    required String text,
    required List<File> images,
  }) async {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;

    final cleanText = text.trim();
    if (cleanText.isEmpty && images.isEmpty) return;

    final List<String> imageUrls = [];

    if (images.isNotEmpty) {
      for (final file in images) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}_$senderId.jpg";
        final ref = _storage.ref("chats/$conversationId/images/$fileName");
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    }

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'text': cleanText,
      'sender': senderId,
      'time': FieldValue.serverTimestamp(),
      'status': 'sent',
      'type': imageUrls.isNotEmpty ? 'media' : 'text',
      'imageUrls': imageUrls,
    });

    String lastMessage = '';
    if (imageUrls.isNotEmpty && cleanText.isNotEmpty) {
      lastMessage = "📷 Photo + Message";
    } else if (imageUrls.isNotEmpty) {
      lastMessage = "📷 Photo";
    } else {
      lastMessage = cleanText;
    }

    await _updateLastConversation(lastMessage: lastMessage);
  }

  Future<void> markMessagesAsSeen() async {
    final myId = _auth.currentUser?.uid;
    if (myId == null) return;

    final snapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('status', isEqualTo: 'delivered')
        .where('sender', isNotEqualTo: myId)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'seen'});
    }

    await batch.commit();
  }

  Future<void> updateDeliveredForIncoming() async {
    final myId = _auth.currentUser?.uid;
    if (myId == null) return;

    final snapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('status', isEqualTo: 'sent')
        .where('sender', isNotEqualTo: myId)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'delivered'});
    }

    await batch.commit();
  }

  Future<void> _updateLastConversation({required String lastMessage}) async {
    final myId = _auth.currentUser?.uid;
    if (myId == null) return;

    final now = Timestamp.now();

    await _setLastConversationForUser(
      targetUserId: myId,
      lastMessage: lastMessage,
      time: now,
    );

    await _setLastConversationForUser(
      targetUserId: userId,
      lastMessage: lastMessage,
      time: now,
    );
  }

  Future<void> _setLastConversationForUser({
    required String targetUserId,
    required String lastMessage,
    required Timestamp time,
  }) async {
    final userRef = _firestore.collection('users').doc(targetUserId);
    final doc = await userRef.get();

    final List<Map<String, dynamic>> newList = [
      {
        'id': conversationId,
        'last message': lastMessage,
        'last message time': time,
      }
    ];

    if (doc.exists) {
      final data = doc.data();
      final list = data?['last conversation'];

      if (list is List) {
        for (final item in list) {
          final map = Map<String, dynamic>.from(item);
          if (map['id'] != conversationId) {
            newList.add(map);
          }
        }
      }
    }

    await userRef.set({'last conversation': newList}, SetOptions(merge: true));
  }
}
