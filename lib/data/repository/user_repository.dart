import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whale_chat/data/model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromDoc(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromDoc(doc);
      }
      return null;
    });
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      return snapshot.docs.map((doc) => UserModel.fromDoc(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String about,
    String? imageUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'about': about,
      };
      if (imageUrl != null) {
        data['image'] = imageUrl;
      }

      await _functions.httpsCallable('updateProfile').call(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadProfileImage(String uid, File file) async {
    try {
      final ref = _storage.ref('users/$uid/profile.jpg');
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
