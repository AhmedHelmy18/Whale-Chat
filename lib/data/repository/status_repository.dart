import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whale_chat/model/status/status.dart';

class StatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<List<Status>> getStatuses() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    return _firestore
        .collection('statuses')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final allOtherStatuses = snapshot.docs
          .map((doc) => Status.fromFirestore(doc))
          .where((status) => status.userId != currentUserId)
          .toList();

      // Use a map to ensure each user ID appears only once, preventing duplicate heroes.
      // We take the first occurrence because the list is ordered by creation time descending.
      final uniqueUserStatuses = <String, Status>{};
      for (final status in allOtherStatuses) {
        if (!uniqueUserStatuses.containsKey(status.userId)) {
          uniqueUserStatuses[status.userId] = status;
        }
      }
      
      return uniqueUserStatuses.values.toList();
    });
  }

  Stream<Status?> getMyStatus() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value(null);

    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    return _firestore
        .collection('statuses')
        .where('userId', isEqualTo: currentUserId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Status.fromFirestore(snapshot.docs.first);
    });
  }

  Stream<String?> getCurrentUserImageUrl() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data()?['image'];
      }
      return null;
    });
  }

  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  Future<void> addStatus({
    required StatusType type,
    required String content,
    String? caption,
    File? imageFile,
    String? backgroundColor,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    String finalContent = content;

    if (imageFile != null && type == StatusType.image) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('statuses/${currentUser.uid}/$fileName');
      await ref.putFile(imageFile);
      finalContent = await ref.getDownloadURL();
    }

    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
    final statusQuery = await _firestore
        .collection('statuses')
        .where('userId', isEqualTo: currentUser.uid)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    final newItem = StatusItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: finalContent,
      type: type,
      caption: caption,
      timestamp: DateTime.now(),
      viewedBy: [],
      backgroundColor: backgroundColor,
    );

    if (statusQuery.docs.isNotEmpty) {
      final statusDoc = statusQuery.docs.first;
      final status = Status.fromFirestore(statusDoc);
      final updatedItems = [...status.statusItems, newItem];

      await statusDoc.reference.update({
        'statusItems': updatedItems.map((item) => item.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(), // Update timestamp to bring to top
      });
    } else {
      // Fetch user profile for name and image
      String userName = 'User';
      String? userProfileImage;
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          userName = data?['name'] ?? 'User';
          userProfileImage = data?['image'];
        }
      } catch (e) {
        // Fallback to defaults
      }

      await _firestore.collection('statuses').add({
        'userId': currentUser.uid,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'statusItems': [newItem.toMap()],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> markStatusAsViewed(String statusId, String statusItemId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final statusDoc =
        await _firestore.collection('statuses').doc(statusId).get();
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

  Future<void> deleteStatusItem(String statusId, String itemId) async {
    final statusDoc =
        await _firestore.collection('statuses').doc(statusId).get();
    if (!statusDoc.exists) return;

    final status = Status.fromFirestore(statusDoc);
    final updatedItems =
        status.statusItems.where((item) => item.id != itemId).toList();

    if (updatedItems.isEmpty) {
      await deleteStatus(statusId);
    } else {
      await statusDoc.reference.update({
        'statusItems': updatedItems.map((item) => item.toMap()).toList(),
      });
    }
  }
}
