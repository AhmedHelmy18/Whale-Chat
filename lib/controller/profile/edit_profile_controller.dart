import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final ImagePicker _picker = ImagePicker();

  Future<void> getData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        nameController.text = data?['name'] ?? "";
        bioController.text = data?['bio'] ?? "";
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<bool> updateField({required String field}) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (field == 'name') {
        updateData['name'] = nameController.text;
      } else if (field == 'bio') {
        updateData['bio'] = bioController.text;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> uploadProfileImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return false;
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');

      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<String?> getProfileImageUrl() async {
    try {
      final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
      await ref.getMetadata();
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
