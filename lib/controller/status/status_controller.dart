import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:whale_chat/model/status/status.dart';

class StatusController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Status>> getStatuses() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    return _firestore.collection('statuses')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('createdAt', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Status.fromFirestore(doc))
          .where((status) => status.userId != currentUserId)
          .toList();
    });
  }

  Stream<Status?> getMyStatus() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value(null);

    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    return _firestore
        .collection('statuses')
        .where('userId', isEqualTo: currentUserId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Status.fromFirestore(snapshot.docs.first);
    });
  }

  Future<void> addStatus({
    required StatusType type,
    required String content,
    String? caption,
    File? imageFile,
    String? backgroundColor,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    String finalContent = content;

    if (imageFile != null && type == StatusType.image) {
      finalContent = await _uploadStatusImage(imageFile, currentUser.uid);
    }

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';
    final userProfileImage = userDoc.data()?['profileImage'];

    final statusItem = StatusItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: finalContent,
      type: type,
      caption: caption,
      timestamp: DateTime.now(),
      viewedBy: [],
      backgroundColor: backgroundColor,
    );

    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
    final existingStatus = await _firestore
        .collection('statuses')
        .where('userId', isEqualTo: currentUser.uid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .limit(1)
        .get();

    if (existingStatus.docs.isNotEmpty) {
      final doc = existingStatus.docs.first;
      final status = Status.fromFirestore(doc);
      final updatedItems = [...status.statusItems, statusItem];

      await doc.reference.update({
        'statusItems': updatedItems.map((item) => item.toMap()).toList(),
      });
    } else {
      final newStatus = Status(
        id: '',
        userId: currentUser.uid,
        userName: userName,
        userProfileImage: userProfileImage,
        statusItems: [statusItem],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('statuses').add(newStatus.toMap());
    }
  }

  Future<String> _uploadStatusImage(File imageFile, String userId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('statuses/$userId/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> markStatusAsViewed(String statusId, String statusItemId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final statusDoc = await _firestore.collection('statuses').doc(statusId).get();
    if (!statusDoc.exists) return;

    final status = Status.fromFirestore(statusDoc);
    final updatedItems = status.statusItems.map((item) {
      if (item.id == statusItemId && !item.viewedBy.contains(currentUserId)) {
        return StatusItem(
          id: item.id,
          content: item.content,
          type: item.type,
          caption: item.caption,
          timestamp: item.timestamp,
          viewedBy: [...item.viewedBy, currentUserId],
          backgroundColor: item.backgroundColor,
        );
      }
      return item;
    }).toList();

    await statusDoc.reference.update({
      'statusItems': updatedItems.map((item) => item.toMap()).toList(),
    });
  }

  Future<void> deleteStatus(String statusId) async {
    await _firestore.collection('statuses').doc(statusId).delete();
  }

  Future<void> deleteOldStatuses() async {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
    final oldStatuses = await _firestore
        .collection('statuses')
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoffTime))
        .get();

    for (var doc in oldStatuses.docs) {
      await doc.reference.delete();
    }
  }
}